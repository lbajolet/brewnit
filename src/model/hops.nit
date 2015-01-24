# All hop-related calculations are to be made here
module hops

import units

# Any kind of hop that is to be used
abstract class Hop
	# Name of the hop variety
	var name: String

	# Percentage of alpha-acids contained in said hop variety
	var alpha_acid: Float

	# The absorption factor of the hop, expressed in ml/oz
	fun absorption_factor: Volume is abstract
end

class Leaf
	super Hop

	redef fun absorption_factor do return once new Liter(.215)
end

class Pellet
	super Hop

	redef fun absorption_factor do return once new Liter(.215)
end

# A `HopProfile` is a hop used in a recipe with its related quantity and use in the recipe
class HopProfile

	# The name and alpha-acid content of the hop
	var hop: Hop

	# Quantity of hop present in the recipe
	var quantity: Weight

	# Time the hop is supposed to stay in recipe (either at boil or in dry-hop)
	var time: Time

	# Computes the total AAU (Alpha-Acid Units) produced by the hops
	fun aau: Float do return quantity.to_oz.value * hop.alpha_acid
end

class Boil
	super HopProfile
end

class DryHop
	super HopProfile
end
