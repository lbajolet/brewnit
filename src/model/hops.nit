# All hop-related calculations are to be made here
module hops

import units

# Hops used for boiling
fun boil: Int do return 0
# Hops used for dry-hopping
fun dry_hop: Int do return 1
# Hops used for mash-time hopping
fun mash_time: Int do return 2

# Any kind of hop used in a recipe
class Hop
	# Name of the hop variety
	var name: String

	# Quantity of hop present in the recipe
	var quantity: Weight

	# Time the hop is supposed to stay in recipe (either at boil or in dry-hop)
	var time: Time

	# Percentage of alpha-acids contained in said hop variety
	var alpha_acid: Float

	# How is the hop used in the recipe?
	#
	# Can either be `boil`, `dry_hop` or `mash_time`
	#
	# FIXME: Replace with an enum when available
	var use: Int

	# Computes the total AAU (Alpha-Acid Units) produced by the hops
	fun aau: Float do return quantity.to_oz.value * alpha_acid

	# The absorption factor of the hop, expressed in ml/oz
	fun absorption_factor: Volume do return new Liter(.215)
end
