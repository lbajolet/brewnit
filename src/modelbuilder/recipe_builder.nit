# Used to build recipes from a `beer` description file
module recipe_builder

import literal
import unit_build
import model
import console

# Visitor for beer files
class RecipeVisitor
	super Visitor

	# The end recipe created from the informations in the `beer` file
	var recipe: nullable Recipe = null

	# Errors reported when building recipe
	var errors = new Array[String]

	redef fun visit(n) do
		n.accept_recipe_visitor(self)
	end
end

redef class Node
	# Accepts the visit from a `RecipeVisitor`
	fun accept_recipe_visitor(v: RecipeVisitor) do visit_children(v)
end

redef class Nprog
	redef fun accept_recipe_visitor(v) do
		super
		for i in v.errors do print i.red
		if not v.errors.is_empty then return
		var rec = n_recipe
		var eq = n_equipment
		var fr = n_fermentables
		var hops = n_hops
		var ys = n_yeast
		var rv = rec.volume
		var rt = rec.temperature
		var req = eq.equipment
		if rv == null or rt == null or req == null then return
		var ret = new Recipe(rec.name, rv, rt, req, ys.yeast)
		ret.hops.add_all hops.hops
		ret.malts.add_all fr.fermentables
		v.recipe = ret
	end
end

redef class Nrecipe

	# Name of the recipe
	var name: String is lazy do return n_string.value
	# Target volume of the recipe
	var volume: nullable Volume = null
	# Target mash temperature
	var temperature: nullable Temperature = null

	redef fun accept_recipe_visitor(v) do
		for i in n_recipe_body.children do
			if i isa Nrecipe_body_volume then
				volume = i.volume
			else if i isa Nrecipe_body_mash_temp then
				temperature = i.mash_temp
			end
		end
		if volume == null then v.errors.push "Error: Missing volume information in recipe at {position or else "?"}"
		if temperature == null then v.errors.push "Error: Missing mash temperature information in recipe at {position or else "?"}"
	end

end

redef class Nrecipe_body_volume
	# Volume of the recipe
	var volume: Volume is lazy do return n_volunit.val
end

redef class Nrecipe_body_mash_temp
	# Mash temperature of a recipe
	var mash_temp: Temperature is lazy  do return n_tmpunit.val
end

redef class Nyeast

	# Name of the yeast
	var name: String is lazy do return n_string.value
	# Yeast object built by visitor
	var yeast: Yeast is noinit

	redef fun accept_recipe_visitor(v) do
		visit_children(v)
		var att: nullable Float = null
		var brand = ""
		for i in n_yeast_body.children do
			if i isa Nyeast_body_att then
				att = i.attenuation
			else if i isa Nyeast_body_brand then
				brand = i.brand
			end
		end
		if att == null then
			v.errors.add "Error, missing attenuation information in Yeast at {position or else "?"}"
			return
		end
		yeast = new Yeast(brand, name, [""], att)
	end
end

redef class Nyeast_body_att

	# Yeast attenuation percentage
	var attenuation: Float is lazy do return n_number.value / 100.0
end

redef class Nyeast_body_brand

	# Yeast brand
	var brand: String is lazy do return n_string.value
end

redef class Nstr_list
	# Aliases of a yeast's name
	var aliases = new Array[String]
end

redef class Nequipment
	# The equipment for the recipe
	var equipment: nullable Equipment = null

	redef fun accept_recipe_visitor(v) do
		var eff: nullable Float = null
		var vol: nullable Volume = null
		for i in n_equipment_body.children do
			if i isa Nequipment_body_efficiency then
				eff = i.efficiency
			else if i isa Nequipment_body_volume then
				vol = i.volume
			end
		end
		var err = false
		if eff == null then
			v.errors.add "Error, missing efficiency information in equipment at {position or else "?"}"
			err = true
		end
		if vol == null then
			v.errors.add "Error, missing volume information at in equipment at {position or else "?"}"
			err = true
		end
		if err then return
		equipment = new Equipment(n_string.value, eff.as(not null), vol.as(not null))
	end
end

redef class Nequipment_body_efficiency

	# Efficiency of the equipment
	var efficiency: Float is lazy do return n_number.value / 100.0
end

redef class Nequipment_body_volume

	# Volume of the equipment
	var volume: Volume is lazy do return n_volunit.val
end

redef class Nfermentables

	# Fermentables of a recipe
	var fermentables = new Array[FermentableProfile]

	redef fun accept_recipe_visitor(v) do
		visit_children(v)
		var arr = n_compound.children
		for i in arr do
			var prof = i.profile
			if prof == null then break
			fermentables.push prof
		end
	end

end

redef class Ncompound

	# The name of the compound
	var name: String is lazy do return n_string.value

	# Final profile of a fermentable
	var profile: nullable FermentableProfile = null

	# Fermentable used in the profile
	var fermentable: nullable Fermentable = null

	# Gravity potential of a compound
	var potential: nullable Gravity = null

	# Quantity of a compound
	var quantity: nullable Weight = null

	# Colour potential of a compound
	var colour: nullable Colour = null

	# Fermentable type
	var f_type: String is lazy do return n_kw_compound.text.to_lower

	redef fun accept_recipe_visitor(v) do
		if not build_fermentable(v) then return
		if f_type == "grain" then
			fermentable = new Grain(name, potential.as(not null), colour.as(not null))
		else if f_type == "adjunct" then
			fermentable = new Adjunct(name, potential.as(not null), colour.as(not null))
		else if f_type == "sugar" then
			fermentable = new Sugar(name, potential.as(not null), colour.as(not null))
		else if f_type == "extract" then
			fermentable = new Extract(name, potential.as(not null), colour.as(not null))
		else
			return
		end
		var ferm = fermentable.as(not null)
		var qt = quantity.as(not null)
		profile = new FermentableProfile(ferm, qt)
	end

	# Parse information from the children of `self`:
	fun parse_data do
		for i in n_compound_body.children do
			if i isa Ncompound_body_potential then
				potential = i.potential
			else if i isa Ncompound_body_colour then
				colour = i.colour
			else if i isa Ncompound_body_quantity then
				quantity = i.quantity
			end
		end
	end

	# Build fermentable information from the contents of `self`
	fun build_fermentable(v: RecipeVisitor): Bool do
		parse_data
		if not check(v) then return false
		return true
	end

	# Check if the informations are all available
	#
	# REQUIRE: parse_data must have been called prior to this
	fun check(v: RecipeVisitor): Bool do
		var err = true
		if potential == null then
			v.errors.push("Error: Missing potential information for fermentable at {position or else "?"}")
			err = false
		end
		if colour == null then
			v.errors.push("Error: Missing colour information for fermentable at {position or else "?"}")
			err = false
		end
		if quantity == null then
			v.errors.push("Error: Missing quantity information for fermentable at {position or else "?"}")
			err = false
		end
		return err
	end
end

redef class Ncompound_body_potential

	# Gravity potential of a compound
	var potential: Gravity is lazy do return n_grvunit.val
end

redef class Ncompound_body_colour

	# Colour potential of a compound
	var colour: Colour is lazy do return n_colunit.val
end

redef class Ncompound_body_quantity

	# Quantity of a compound to use in a recipe
	var quantity: Weight is lazy do return n_weiunit.val
end

redef class Nhops

	# Hops in the recipe
	var hops = new Array[Hop]

	redef fun accept_recipe_visitor(v) do
		super
		var arr = n_hop_profile.children
		for i in arr do
			var prof = i.profile
			if prof == null then break
			hops.push prof
		end
	end

end

redef class Nhop_profile

	# How the hop is used in the recipe
	var profile: nullable Hop = null
	# Alpha Acid content of a hop
	var alpha_acid: nullable Float = null
	# Quantity used in the recipe
	var quantity: nullable Weight = null
	# How long the hop stays in the wort
	var time: nullable Time = null
	# How is the hop used
	var use: nullable Int = null
	# Variety of the Hop used
	var name: String is lazy do return n_string.value

	redef fun accept_recipe_visitor(v) do
		for i in n_hop_profile_body.children do
			if i isa Nhop_profile_body_aa then
				alpha_acid = i.alpha_acid
			else if i isa Nhop_profile_body_quantity then
				quantity = i.quantity
			else if i isa Nhop_profile_body_time then
				time = i.time
			else if i isa Nhop_profile_body_use then
				use = i.use
			end
		end

		var err = false
		if alpha_acid == null then
			v.errors.push("Error: Missing alpha acid information for hop at {position or else "?"}")
			err = true
		end
		if quantity == null then
			v.errors.push("Error: Missing quantity information for hop at {position or else "?"}")
			err = true
		end
		if time == null then
			v.errors.push("Error: Missing time information for hop at {position or else "?"}")
			err = true
		end
		if use == null then
			v.errors.push("Error: Missing use information for hop at {position or else "?"}")
			err = true
		end
		if err then return

		profile = new Hop(name, quantity.as(not null), time.as(not null), alpha_acid.as(not null), use.as(not null))
	end
end

redef class Nhop_profile_body_aa

	# Alpha Acid percentage in hop
	var alpha_acid: Float is lazy do return n_number.value
end

redef class Nhop_profile_body_quantity

	# Quantity of hop used
	fun quantity: Weight do return n_weiunit.val
end

redef class Nhop_profile_body_time

	# Time for which the hop will be in the wort
	fun time: Time do return n_timunit.val
end

redef class Nhop_profile_body_use

	# How is the hop used in the recipe
	var use: Int is lazy do
		var use_str = n_hop_use.text
		if use_str == "Boil" then
			return boil
		else if use_str == "DryHop" then
			return dry_hop
		end
		return -1
	end
end
