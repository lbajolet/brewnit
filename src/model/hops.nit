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

	fun use_factor(gravity: Gravity): Float is abstract
end

class Boil
	super HopProfile

	# Computes the use factor (percentage) for the selected hop
	redef fun use_factor(grav: Gravity): Float do
		var gravity = (grav.to_sg.value * 1000.0).to_i
		var rt = time.to_min.value.to_i - (time.to_min.value.to_i % 5)
		rt = time_to_index(rt)
		if gravity < 1040 then return use_1030(rt)
		if gravity < 1050 then return use_1040(rt)
		if gravity < 1060 then return use_1050(rt)
		if gravity < 1070 then return use_1060(rt)
		if gravity < 1080 then return use_1070(rt)
		if gravity < 1090 then return use_1080(rt)
		if gravity < 1100 then return use_1090(rt)
		if gravity < 1110 then return use_1100(rt)
		if gravity < 1020 then return use_1110(rt)
		return use_1120(rt)
	end

	fun time_to_index(time: Int): Int `{
		int index;
		switch(time){
			case 0: index = 0; break;
			case 5: index = 1; break;
			case 10: index = 2; break;
			case 15: index = 3; break;
			case 20: index = 4; break;
			case 25: index = 5; break;
			case 30: index = 6; break;
			case 35: index = 7; break;
			case 40: index = 8; break;
			case 45: index = 9; break;
			case 50: index = 10; break;
			case 55: index = 11; break;
			case 60: index = 12; break;
			case 70: index = 13; break;
			case 80: index = 14; break;
			case 90: index = 15; break;
			case 100: index = 16; break;
			case 110: index = 17; break;
			case 120: index = 18; break;
			default: index = 0; break;
		}
		return index;
	`}

	# Hop use formulas below, at x < 1040 boil gravity
	fun use_1030(index: Int): Float `{
		static int hop[] = {
			0,
			.055,
			.1,
			.137,
			.167,
			.192,
			.212,
			.229,
			.242,
			.253,
			.263,
			.270,
			.276,
			.285,
			.291,
			.295,
			.298,
			.3,
			.301
		};
		return hop[index];
	`}

	# Hop use formulas below, at 1040 >= x < 1050 boil gravity
	fun use_1040(index: Int): Float `{
		static int hop[] = {
			0,
			.050,
			.91,
			.125,
			.153,
			.175,
			.194,
			.209,
			.221,
			.232,
			.240,
			.247,
			.252,
			.261,
			.266,
			.270,
			.272,
			.274,
			.275
		};
		return hop[index];
	`}

	# Hop use formulas below, at 1050 >= x < 1060 boil gravity
	fun use_1050(index: Int): Float `{
		static int hop[] = {
			0,
			.046,
			.084,
			.114,
			.140,
			.160,
			.177,
			.191,
			.202,
			.212,
			.219,
			.226,
			.231,
			.238,
			.243,
			.247,
			.249,
			.251,
			.252
		};
		return hop[index];
	`}

	# Hop use formulas below, at 1060 >= x < 1070 boil gravity
	fun use_1060(index: Int): Float `{
		static int hop[] = {
			0,
			.042,
			.076,
			.105,
			.128,
			.147,
			.162,
			.175,
			.185,
			.194,
			.200,
			.206,
			.211,
			.218,
			.222,
			.226,
			.228,
			.229,
			.230
		};
		return hop[index];
	`}

	# Hop use formulas below, at 1070 >= x < 1080 boil gravity
	fun use_1070(index: Int): Float `{
		static int hop[] = {
			0,
			.038,
			.070,
			.096,
			.117,
			.134,
			.148,
			.160,
			.169,
			.177,
			.183,
			.188,
			.193,
			.199,
			.203,
			.206,
			.208,
			.209,
			.210
		};
		return hop[index];
	`}

	# Hop use formulas below, at 1080 >= x < 1090 boil gravity
	fun use_1080(index: Int): Float `{
		static int hop[] = {
			0,
			.035,
			.064,
			.087,
			.107,
			.122,
			.135,
			.146,
			.155,
			.162,
			.168,
			.172,
			.176,
			.182,
			.186,
			.188,
			.190,
			.191,
			.192
		};
		return hop[index];
	`}

	# Hop use formulas below, at 1090 >= x < 1100 boil gravity
	fun use_1090(index: Int): Float `{
		static int hop[] = {
			0,
			.032,
			.058,
			.080,
			.098,
			.112,
			.124,
			.133,
			.141,
			.148,
			.153,
			.157,
			.161,
			.166,
			.170,
			.172,
			.174,
			.175,
			.176
		};
		return hop[index];
	`}

	# Hop use formulas below, at 1100 >= x < 1110 boil gravity
	fun use_1100(index: Int): Float `{
		static int hop[] = {
			0,
			.029,
			.053,
			.073,
			.089,
			.102,
			.113,
			.122,
			.129,
			.135,
			.140,
			.144,
			.147,
			.152,
			.155,
			.157,
			.159,
			.160,
			.161
		};
		return hop[index];
	`}

	# Hop use formulas below, at 1110 >= x < 1120 boil gravity
	fun use_1110(index: Int): Float `{
		static int hop[] = {
			0,
			.027,
			.049,
			.067,
			.081,
			.094,
			.103,
			.111,
			.118,
			.123,
			.128,
			.132,
			.135,
			.139,
			.142,
			.144,
			.145,
			.146,
			.147
		};
		return hop[index];
	`}

	# Hop use formulas below, at x >= 1120 boil gravity
	fun use_1120(index: Int): Float `{
		static int hop[] = {
			0,
			.025,
			.045,
			.061,
			.074,
			.085,
			.094,
			.102,
			.108,
			.113,
			.117,
			.120,
			.123,
			.127,
			.130,
			.132,
			.133,
			.134,
			.134
		};
		return hop[index];
	`}
end

class DryHop
	super HopProfile

	redef fun use_factor(g) do return 0.0
end
