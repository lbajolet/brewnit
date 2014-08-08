# All mash-related calculations are to be stored here
module mash

import units

# A fermentable is any kind of material that can produce fermentable sugars during mash phase or boil (sugars and such)
class Fermentable
	# Name of the type of mash
	var name: String

	# Potential of sugars to extract (lbs/gal) at 100% efficiency
	var potential: Gravity

	# Colour of the malt
	var colour: Colour

	# Does the fermentable need mashing or not (influences efficiency)
	fun need_mash: Bool is abstract
end

class FermentableProfile

	# Type of Fermentable used
	var fermentable: Fermentable

	# Quantity of fermentable used in the recipe
	var quantity: Weight

	# Gravity units produced by the fermentable
	fun gu: Float do return fermentable.potential.to_gu.value * quantity.to_lbs.value

end

class Grain
	super Fermentable

	redef fun need_mash do return true
end

class Adjunct
	super Fermentable

	redef fun need_mash do return false
end

class Sugar
	super Fermentable

	redef fun need_mash do return false
end

class Extract
	super Fermentable

	redef fun need_mash do return false
end
