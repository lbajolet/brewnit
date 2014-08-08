# All hop-related calculations are to be made here
module hops

import units

in "C header" `{

typedef struct hop_use {
	int time;
	double use_percentage;
} hop_use;

`}

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

	# Hop use formulas below, at x < 1040 boil gravity
	fun use_1030(time: Int): Float `{
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
		}
		static hop_use hop[] = {
			{0, 0},
			{5, .055},
			{10, .1},
			{15, .137},
			{20, .167},
			{25, .192},
			{30, .212},
			{35, .229},
			{40, .242},
			{45, .253},
			{50, .263},
			{55, .270},
			{60, .276},
			{70, .285},
			{80, .291},
			{90, .295},
			{100, .298},
			{110, .3},
			{120, .301}
		};
		return hop[index].use_percentage;
	`}

	# Hop use formulas below, at 1040 >= x < 1050 boil gravity
	fun use_1040(time: Int): Float `{
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
		}
		static hop_use hop[] = {
			{0, 0},
			{5, .050},
			{10, .91},
			{15, .125},
			{20, .153},
			{25, .175},
			{30, .194},
			{35, .209},
			{40, .221},
			{45, .232},
			{50, .240},
			{55, .247},
			{60, .252},
			{70, .261},
			{80, .266},
			{90, .270},
			{100, .272},
			{110, .274},
			{120, .275}
		};
		return hop[index].use_percentage;
	`}

	# Hop use formulas below, at 1050 >= x < 1060 boil gravity
	fun use_1050(time: Int): Float `{
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
		}
		static hop_use hop[] = {
			{0, 0},
			{5, .046},
			{10, .084},
			{15, .114},
			{20, .140},
			{25, .160},
			{30, .177},
			{35, .191},
			{40, .202},
			{45, .212},
			{50, .219},
			{55, .226},
			{60, .231},
			{70, .238},
			{80, .243},
			{90, .247},
			{100, .249},
			{110, .251},
			{120, .252}
		};
		return hop[index].use_percentage;
	`}

	# Hop use formulas below, at 1060 >= x < 1070 boil gravity
	fun use_1060(time: Int): Float `{
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
		}
		static hop_use hop[] = {
			{0, 0},
			{5, .042},
			{10, .076},
			{15, .105},
			{20, .128},
			{25, .147},
			{30, .162},
			{35, .175},
			{40, .185},
			{45, .194},
			{50, .200},
			{55, .206},
			{60, .211},
			{70, .218},
			{80, .222},
			{90, .226},
			{100, .228},
			{110, .229},
			{120, .230}
		};
		return hop[index].use_percentage;
	`}

	# Hop use formulas below, at 1070 >= x < 1080 boil gravity
	fun use_1070(time: Int): Float `{
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
		}
		static hop_use hop[] = {
			{0, 0},
			{5, .038},
			{10, .070},
			{15, .096},
			{20, .117},
			{25, .134},
			{30, .148},
			{35, .160},
			{40, .169},
			{45, .177},
			{50, .183},
			{55, .188},
			{60, .193},
			{70, .199},
			{80, .203},
			{90, .206},
			{100, .208},
			{110, .209},
			{120, .210}
		};
		return hop[index].use_percentage;
	`}

	# Hop use formulas below, at 1080 >= x < 1090 boil gravity
	fun use_1080(time: Int): Float `{
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
		}
		static hop_use hop[] = {
			{0, 0},
			{5, .035},
			{10, .064},
			{15, .087},
			{20, .107},
			{25, .122},
			{30, .135},
			{35, .146},
			{40, .155},
			{45, .162},
			{50, .168},
			{55, .172},
			{60, .176},
			{70, .182},
			{80, .186},
			{90, .188},
			{100, .190},
			{110, .191},
			{120, .192}
		};
		return hop[index].use_percentage;
	`}

	# Hop use formulas below, at 1090 >= x < 1100 boil gravity
	fun use_1090(time: Int): Float `{
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
		}
		static hop_use hop[] = {
			{0, 0},
			{5, .032},
			{10, .058},
			{15, .080},
			{20, .098},
			{25, .112},
			{30, .124},
			{35, .133},
			{40, .141},
			{45, .148},
			{50, .153},
			{55, .157},
			{60, .161},
			{70, .166},
			{80, .170},
			{90, .172},
			{100, .174},
			{110, .175},
			{120, .176}
		};
		return hop[index].use_percentage;
	`}

	# Hop use formulas below, at 1100 >= x < 1110 boil gravity
	fun use_1100(time: Int): Float `{
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
		}
		static hop_use hop[] = {
			{0, 0},
			{5, .029},
			{10, .053},
			{15, .073},
			{20, .089},
			{25, .102},
			{30, .113},
			{35, .122},
			{40, .129},
			{45, .135},
			{50, .140},
			{55, .144},
			{60, .147},
			{70, .152},
			{80, .155},
			{90, .157},
			{100, .159},
			{110, .160},
			{120, .161}
		};
		return hop[index].use_percentage;
	`}

	# Hop use formulas below, at 1110 >= x < 1120 boil gravity
	fun use_1110(time: Int): Float `{
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
		}
		static hop_use hop[] = {
			{0, 0},
			{5, .027},
			{10, .049},
			{15, .067},
			{20, .081},
			{25, .094},
			{30, .103},
			{35, .111},
			{40, .118},
			{45, .123},
			{50, .128},
			{55, .132},
			{60, .135},
			{70, .139},
			{80, .142},
			{90, .144},
			{100, .145},
			{110, .146},
			{120, .147}
		};
		return hop[index].use_percentage;
	`}

	# Hop use formulas below, at x >= 1120 boil gravity
	fun use_1120(time: Int): Float `{
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
		}
		static hop_use hop[] = {
			{0, 0},
			{5, .025},
			{10, .045},
			{15, .061},
			{20, .074},
			{25, .085},
			{30, .094},
			{35, .102},
			{40, .108},
			{45, .113},
			{50, .117},
			{55, .120},
			{60, .123},
			{70, .127},
			{80, .130},
			{90, .132},
			{100, .133},
			{110, .134},
			{120, .134}
		};
		return hop[index].use_percentage;
	`}
end

class DryHop
	super HopProfile

	redef fun use_factor(g) do return 0.0
end
