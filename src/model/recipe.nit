# Recipe-related material should be stored here
module recipe

import mash
import hops
import units

# A recipe contains malts, hops and eventual sugars and such to be mixed to make beer !
class Recipe

	# Name of the recipe
	var name: String

	# All the hops used in the recipe and their use
	var hops = new Array[HopProfile]

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
	var equipment: nullable Equipment = null is writable

	# The yeast used in this recipe
	var yeast: nullable Yeast = null is writable

	# At end of boil, measured volume
	var measured_volume: nullable Volume = null is writable

	# At end of boil, measured gravity
	var measured_gravity: nullable Gravity = null is writable

	# At end of fermentation, measured gravity
	var final_gravity: nullable Gravity = null is writable

	# Total loss due to trubs (lees) to be taken in account when predicting the final volume of beer to be bottled/kegged
	var trub_losses: Volume = new USGallon(0.5) is writable

	# Based on malts and water quantity, estimated OG is calculated
	fun estimated_og: Gravity
	do
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

	fun estimated_fg: Gravity
	do
		if yeast == null then return new GU(0.0)
		return new GU(estimated_og.to_gu.value * (1.0 - yeast.attenuation))
	end

	fun grain_weight: Weight
	do
		var total_grain_weight = 0.0
		for i in malts do
			if i.fermentable isa Grain then total_grain_weight += i.quantity.to_lbs.value
		end
		return new Pound(total_grain_weight)
	end

	# Based on the mash profile, computes the gravity of the wort during boil.
	fun estimated_boil_gravity: Gravity do return new GU((estimated_og.to_gu.value * target_volume.to_us_gal.value) / runoff_volume.to_us_gal.value)

	fun fermenter_volume: Volume do return new Liter(hop_loss.to_l.value + target_volume.to_l.value)

	# Based on the hops described in the recipe, computes the total loss of wort due to hop-use.
	#
	# Estimate : 215ml/oz of leaf hops
	fun hop_loss: Volume
	do
		var hop_use = new Liter(.215)
		var loss = 0.0
		for i in hops do loss += i.quantity.to_oz.value * hop_use.value
		return new Liter(loss)
	end

	# Computes the grain absorption of water
	fun grain_loss: Volume
	do
		return new USGallon(grain_weight.to_lbs.value * .2)
	end

	# Computes the water lost during boil
	# Estimated loss : 5%/h
	fun boil_loss: Volume
	do
		var hrly =(0.05 * runoff_volume.to_l.value)
		return new Liter(hrly * boil_length.to_h.value)
	end

	# Length of the boil, based on the hop profiles declared in the recipe
	fun boil_length: Time
	do
		var max = new Minute(0.0)
		for i in hops do
			if i.time.to_min.value > max.to_min.value and i isa Boil then max = i.time.to_min
		end
		return max.to_h
	end

	# Volume at start of boil
	fun runoff_volume: Volume
	do
		var batch_size = target_volume.to_l.value
		var shrinkage = new Liter(batch_size / .96)
		return new Liter((shrinkage.value / (1.0 - (.05 * boil_length.to_h.value))) + hop_loss.to_l.value)
	end

	# Computes the maximum points/pound/gallon that can be harvested from grains
	fun max_ppg: Float
	do
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
	fun effective_ppg: Float do return (((measured_gravity.to_sg.value * 1000.0) - 1000.0) * measured_volume.to_us_gal.value) / grain_weight.to_lbs.value

	# Based on estimated OG and FG, and the Yeast profile, computes the expected ABV of the recipe
	fun estimated_abv: Float do
		if estimated_fg.value == 0.0 then return 0.0
		return ((1.05 * (estimated_og.to_sg.value - estimated_fg.to_sg.value)) / estimated_fg.to_sg.value) / 0.79 * 100.0
	end

	# After fermentation is complete, and final gravity has been measured, computes the effective ABV of the recipe.
	fun effective_abv: Float do return ((1.05 * (measured_gravity.to_sg.value - final_gravity.to_sg.value)) / final_gravity.to_sg.value) / .79 * 100.0

	fun max_grain_gravity: Gravity
	do
		var max_gu = 0.0
		for i in malts do
			if i.fermentable isa Grain then
				max_gu += i.gu
			end
		end
		print "Gravity potential : {max_gu} GU"
		return new GU(max_gu)
	end

	fun effective_grain_gravity: Gravity
	do
		if measured_volume == null then return new GU(0.0)
		var final_gravity = measured_gravity.to_gu.value * measured_volume.as(not null).to_us_gal.value
		for i in malts do
			if not i.fermentable isa Grain then
				final_gravity -= i.gu
			end
		end
		print "Harvested gravity : {final_gravity} GU"
		return new GU(final_gravity)
	end

	# Computes the efficiency of the batch
	fun efficiency: Float do return (effective_grain_gravity.to_gu.value / max_grain_gravity.to_gu.value) * 100.0

	# Volume of water to be used for the mash phase
	fun mash_water: Volume
	do
		return new USQuart(1.25 * grain_weight.to_lbs.value)
	end

	# Volume of water to be used for the sparge phase
	fun sparge_water: Volume do return new Liter(runoff_volume.to_l.value - (mash_water.to_l.value - grain_loss.to_l.value))

	# Based on the `HopProfiles`, calculates the IBUs of the Recipe.
	fun ibu: Float
	do
		var final_ibu = 0.0
		var boil_grav = new SG((estimated_boil_gravity.to_sg.value + estimated_og.to_sg.value) / 2.0)
		var correction_factor: Float
		if boil_grav.to_sg.value > 1.050 then
			correction_factor = 1.0 + ((boil_grav.to_sg.value - 1.050) / .2)
		else
			correction_factor = 1.0
		end
		for i in hops do
			if i isa Boil then
				final_ibu += (i.quantity.to_oz.value * i.use_factor(boil_grav) * (i.hop.alpha_acid / 100.0) * 7.489) / (fermenter_volume.to_us_gal.value * correction_factor)
			end
		end
		return final_ibu * 1000.0
	end

	# Computes the colour of the final product
	fun colour: Colour
	do
		var mcu = 0.0
		for i in malts do
			mcu += (i.quantity.to_lbs.value * i.fermentable.colour.to_srm.value) / fermenter_volume.to_us_gal.value
		end
		return new SRM(1.4922 * mcu.pow(0.6859))
	end
end

# Yeast used for a recipe
class Yeast
	# Brand manufacturing the yeast
	var brand: String

	# Name of the yeast
	var name: String

	# Different aliases for a Yeast type (e.g. US-05 => American Ale Yeast)
	var aliases: Array[String]

	# Enumeration of flocculation types for Yeast
	var flocculation: Int

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
end
