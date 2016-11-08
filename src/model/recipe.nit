# Recipe-related material should be stored here
module recipe

import mash
import hops
import units

# Yeast used for a recipe
class Yeast
	# Brand manufacturing the yeast
	var brand: String

	# Name of the yeast
	var name: String

	# Different aliases for a Yeast type (e.g. US-05 => American Ale Yeast)
	var aliases: Array[String]

	# Attenuation level of the Yeast
	var attenuation: Float
end

# The equipment used for the recipe
class Equipment
	# Name of the equipment
	var name: String

	# Estimated efficiency of equipment used (in percentage)
	var efficiency: Float

	# Volume of the equipment
	var volume: Volume

	# Total loss due to trubs (lees) to be taken in account when predicting the final volume of beer to be bottled/kegged
	#
	# Defaults to 2 `Liters`
	var trub_losses: Volume = new Liter(2.0) is writable

	# Percentage of volume lost by boiling every hour
	#
	# Defaults to 5%
	var boil_loss = 0.05
end

# A recipe for a particular beer
class Recipe
	# Name of the recipe
	var name: String

	# All the hops used in the recipe and their use
	var hops = new Array[Hop]

	# All the malts used in the recipe and how they are used
	var malts = new Array[FermentableProfile]

	# Volume expected at the end of the brewing process
	var target_volume: Volume

	# The temperature at which the mash is expected to proceed
	#
	# Higher temperatures produce a heavier beer
	# Temperature range : 64 C to 69/70 C
	var target_mash_temp: Temperature

	# The equipment to be used for the recipe
	var equipment: Equipment

	# The yeast used in this recipe
	var yeast: Yeast

	# At end of boil, measured volume
	var measured_volume: nullable Volume = null is writable

	# At end of boil, measured gravity
	var measured_gravity: nullable Gravity = null is writable

	# At end of fermentation, measured gravity
	var final_gravity: nullable Gravity = null is writable

	# Based on malts and water quantity, estimated OG is calculated
	var estimated_og: Gravity is lazy do
		var gu_total = 0.0
		for i in malts do
			if i.fermentable.need_mash then
				gu_total += i.gu * equipment.efficiency
			else
				gu_total += i.gu
			end
		end
		return new GU(gu_total / fermenter_volume.to_us_gal.value)
	end

	# Estimated FG according to Yeast
	var estimated_fg: Gravity  is lazy do return new GU(estimated_og.to_gu.value * (1.0 - yeast.attenuation))

	# Total grain weight of recipe
	var grain_weight: Weight is lazy do
		var total_grain_weight: Weight = new Pound(0.0)
		for i in malts do
			if i.fermentable isa Grain then total_grain_weight += i.quantity
		end
		return total_grain_weight
	end

	# Based on the mash profile, computes the gravity of the wort during boil.
	var estimated_boil_gravity: Gravity is lazy do return new GU((estimated_og.to_gu.value * target_volume.to_us_gal.value) / runoff_volume.to_us_gal.value)

	# Total volume needed in fermenter at end of boil
	var fermenter_volume: Volume is lazy do return hop_loss + target_volume

	# Based on the hops described in the recipe, computes the total loss of wort due to hop-use.
	#
	# Estimate : 215ml/oz of leaf hops
	var hop_loss: Volume is lazy do
		var hop_use = new Liter(.215)
		var loss = 0.0
		for i in hops do loss += i.quantity.to_oz.value * hop_use.value
		return new Liter(loss)
	end

	# Computes the grain absorption of water
	var grain_loss: Volume is lazy do return new USGallon(grain_weight.to_lbs.value * .2)

	# Computes the water lost during boil
	var boil_loss: Volume is lazy do
		var hrly = (equipment.boil_loss * runoff_volume.to_l.value)
		return new Liter(hrly * boil_length.to_h.value)
	end

	# Length of the boil, based on the hop profiles declared in the recipe
	var boil_length: Time is lazy do
		var max = new Minute(0.0)
		for i in hops do
			if i.time.to_min.value > max.to_min.value and i.use == boil then max = i.time.to_min
		end
		return max.to_h
	end

	# Volume at start of boil
	var runoff_volume: Volume is lazy do
		var batch_size = target_volume.to_l.value
		var shrinkage = new Liter(batch_size / .96)
		return new Liter((shrinkage.value / (1.0 - (.05 * boil_length.to_h.value))) + hop_loss.to_l.value)
	end

	# Computes the maximum points/pound/gallon that can be harvested from grains
	var max_ppg: Float is lazy do
		var max = 0.0
		var x = target_volume.to_us_gal.value
		for i in malts do
			if i.fermentable isa Grain then
				var yy = (i.fermentable.potential.to_sg.value * 1000.0) - 1000.0
				var z = i.quantity.to_lbs.value
				max += (yy * z) / x
			end
		end
		return max
	end

	# Based on the measured OG, computes the effective ppg value (used for efficiency)
	var effective_ppg: nullable Float is lazy do
		var grav = measured_gravity
		var vol = measured_volume
		if grav == null or vol == null then return null
		return (((grav.to_sg.value * 1000.0) - 1000.0) * vol.to_us_gal.value) / grain_weight.to_lbs.value
	end

	# Based on estimated OG and FG, and the Yeast profile, computes the expected ABV of the recipe
	var estimated_abv: Float is lazy do
		if estimated_fg.value == 0.0 then return 0.0
		return ((1.05 * (estimated_og.to_sg.value - estimated_fg.to_sg.value)) / estimated_fg.to_sg.value) / 0.79 * 100.0
	end

	# After fermentation is complete, and final gravity has been measured, computes the effective ABV of the recipe.
	var effective_abv: nullable Float is lazy do
		var mgrav = measured_gravity
		var fgrav = final_gravity
		if mgrav == null or fgrav == null then return null
		return ((1.05 * (mgrav.to_sg.value - fgrav.to_sg.value)) / fgrav.to_sg.value) / .79 * 100.0
	end

	# Maximum gravity which could be extracted from grain
	var max_grain_gravity: Gravity is lazy do
		var max_gu = 0.0
		for i in malts do
			if i.fermentable isa Grain then
				max_gu += i.gu
			end
		end
		# print "Gravity potential : {max_gu} GU"
		return new GU(max_gu)
	end

	# Effectively extracted gravity from mash
	var effective_grain_gravity: nullable Gravity is lazy do
		var vol = measured_volume
		var grav = measured_gravity
		if vol == null or grav == null then return null
		var final_gravity = grav.to_gu.value * vol.to_us_gal.value
		for i in malts do
			if not i.fermentable isa Grain then
				final_gravity -= i.gu
			end
		end
		# print "Harvested gravity : {final_gravity} GU"
		return new GU(final_gravity)
	end

	# Computes the efficiency of the batch
	var efficiency: nullable Float is lazy do
		var grav = effective_grain_gravity
		if grav == null then return null
		return (grav.to_gu.value / max_grain_gravity.to_gu.value) * 100.0
	end

	# Volume of water to be used for the mash phase
	var mash_water: Volume is lazy do return new USQuart(1.25 * grain_weight.to_lbs.value)

	# Volume of water to be used for the sparge phase
	var sparge_water: Volume is lazy do return new Liter(runoff_volume.to_l.value - (mash_water.to_l.value - grain_loss.to_l.value))

	# Based on the `HopProfiles`, calculates the IBUs of the Recipe.
	var ibu: Float is lazy do
		var final_ibu = 0.0
		# Mathematical Constant e, Euler's number
		var e = 2.71828182845904523536028747135266249775724709369995
		var boil_grav = new SG((estimated_boil_gravity.to_sg.value + estimated_og.to_sg.value) / 2.0)
		var correction_factor = 1.0
		if boil_grav.to_sg.value > 1.050 then correction_factor = 1.0 + ((boil_grav.to_sg.value - 1.050) / .2)
		var bigness_factor = 1.65 * 0.000125.pow(boil_grav.to_sg.value - 1.0)
		for i in hops do
			if i.use == boil then
				var boil_time_factor = (1.0 - e.pow(-0.04 * i.time.to_min.value)) / 4.15
				var alpha_utilization = bigness_factor * boil_time_factor
				var mgl_added_alpha = ((i.alpha_acid/100.0) * i.quantity.to_g.value * 1000.0) / (target_volume.to_l.value * correction_factor)
				final_ibu += mgl_added_alpha * alpha_utilization
			end
		end
		return final_ibu
	end

	# Computes the colour of the final product
	var colour: Colour is lazy do
		var mcu = 0.0
		for i in malts do
			mcu += (i.quantity.to_lbs.value * i.fermentable.colour.to_srm.value) / fermenter_volume.to_us_gal.value
		end
		return new SRM(1.4922 * mcu.pow(0.6859))
	end
end
