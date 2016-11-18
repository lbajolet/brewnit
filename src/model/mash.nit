# All mash-related calculations are to be stored here
module mash

import db_base
import units

# A fermentable is any kind of material that can produce fermentable sugars during mash phase or boil (sugars and such)
class Fermentable
	super UniqueEntity
	serialize

	# Name of the type of mash
	var name: String

	# Potential of sugars to extract (lbs/gal) at 100% efficiency
	var potential: Gravity

	# Colour of the malt
	var colour: Colour

	# Does the fermentable need mashing or not (influences efficiency)
	fun need_mash: Bool is abstract

	# Builds a new `Fermentable` with its type name
	new with_name(name: String, potential: Gravity, colour: Colour, f_type: String) do
		if f_type == "grain" then return new Grain(name, potential, colour)
		if f_type == "adjunct" then return new Adjunct(name, potential, colour)
		if f_type == "sugar" then return new Sugar(name, potential, colour)
		if f_type == "extract" then return new Extract(name, potential, colour)
		# If unknown type, abort
		abort
	end
end

# A fermentable used in a `Recipe`
class FermentableProfile
	super UniqueEntity
	serialize

	# Type of Fermentable used
	var fermentable: Fermentable

	# Quantity of fermentable used in the recipe
	var quantity: Weight

	# Gravity units produced by the fermentable
	fun gu: Float do return fermentable.potential.to_gu.value * quantity.to_lbs.value
end

# Grain to be used in a recipe
class Grain
	super Fermentable
	serialize

	redef fun need_mash do return true
end

# Adjunct to use in a recipe
class Adjunct
	super Fermentable
	serialize

	redef fun need_mash do return false
end

# Sugar to use in a recipe
class Sugar
	super Fermentable
	serialize

	redef fun need_mash do return false
end

# Extract to use in a recipe
class Extract
	super Fermentable
	serialize

	redef fun need_mash do return false
end
