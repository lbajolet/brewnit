# All the units to be used in brewery calculations are stored here
module units

# Any kind of unit, its value should be set at construction time
abstract class Unit

	fun unit: String is abstract

	redef fun to_s do return "{value.to_s} {unit}"

	# Value
	var value: Float
end

abstract class UnitFactory

	type SELF: Unit

	fun build_unit(val: Float, s: String): SELF is abstract
end

# Abstract colour value, expressed in either SRM or EBC
abstract class Colour
	super Unit

	# Converts the value to SRM units
	fun to_srm: SRM is abstract

	# Converts the value to EBC units
	fun to_ebc: EBC is abstract
end

class ColourFactory
	super UnitFactory

	redef type SELF: Colour

	redef fun build_unit(val, s) do
		if s == "SRM" then
			return new SRM(val)
		else if s == "EBC" then
			return new EBC(val)
		else
			print "Cannot find colour unit {s}"
			exit(-1)
		end
	end

end

# Colour, in SRM (Standard Reference Method) units
class SRM
	super Colour

	redef fun unit do return once "SRM"

	redef fun to_srm do return self

	redef fun to_ebc do return new EBC(value * 1.97)
end

# Colour, in EBC (European Brewery Convention) units
class EBC
	super Colour

	redef fun unit do return once "EBC"

	redef fun to_srm do return new SRM(value * .508)

	redef fun to_ebc do return self
end

# Any kind of weight units (g, oz, etc...)
abstract class Weight
	super Unit

	# Converts the weight into ounces
	fun to_oz: Ounce is abstract

	# Converts the weight into grams
	fun to_g: Gram is abstract

	# Converts the weight into pounds
	fun to_lbs: Pound is abstract
end

class WeightFactory
	super UnitFactory

	redef type SELF: Weight

	redef fun build_unit(val, s) do
		if s == "g" then
			return new Gram(val)
		else if s == "oz" then
			return new Ounce(val)
		else if s == "lbs" then
			return new Pound(val)
		else
			print "Cannot find weight unit {s}"
			exit(-1)
		end
	end

end

# Weight unit, an oz is worth 28.3495231 g
class Ounce
	super Weight

	redef fun unit do return once "oz"

	redef fun to_g do return new Gram(value * 28.3495231)

	redef fun to_oz do return self

	redef fun to_lbs do return new Pound(value * 0.0625)
end

# Weight unit, used in US/CAN/UK regions eventually
class Pound
	super Weight

	redef fun unit do return once "lbs"

	redef fun to_g do return new Gram(value * 453.59237)

	redef fun to_oz do return new Ounce(value / 0.0625)

	redef fun to_lbs do return self
end

# Weight unit, International System standard
class Gram
	super Weight

	redef fun unit do return once "g"

	redef fun to_oz do return new Ounce(value / 28.3495231)

	redef fun to_g do return self

	redef fun to_lbs do return new Pound(value / 453.59237)
end

# Volume units (e.g. Gallon or Liter)
abstract class Volume
	super Unit

	fun to_us_gal: USGallon is abstract

	fun to_us_qt: USQuart is abstract

	fun to_imp_gal: ImperialGallon is abstract

	fun to_l: Liter is abstract
end

# Volume unit, standard measurement in the USA
class USGallon
	super Volume

	redef fun unit do return once "gal"

	redef fun to_us_gal do return self

	redef fun to_l do return new Liter(value / 0.264172052)

	redef fun to_imp_gal do return new ImperialGallon(value * 0.83267384)

	redef fun to_us_qt do return new USQuart(value * 4.0)
end

# Volume unit, is eventually used in the UK or any Commonwealth country
class ImperialGallon
	super Volume

	redef fun unit do return once "Imperial gal"

	redef fun to_l do return new Liter(value / 0.219969157)

	redef fun to_us_gal do return new USGallon(value / 0.83267384)

	redef fun to_imp_gal do return self

	redef fun to_us_qt do return new USQuart(value / 0.20816846)
end

# Volume unit, standard from the International System
class Liter
	super Volume

	redef fun unit do return once "L"

	redef fun to_l do return self

	redef fun to_us_gal do return new USGallon(value * 0.264172052)

	redef fun to_imp_gal do return new ImperialGallon(value * 0.219969157)

	redef fun to_us_qt do return new USQuart(value / 0.946352946)
end

class USQuart
	super Volume

	redef fun unit do return once "qt"

	redef fun to_l do return new Liter(value * 0.946352946)

	redef fun to_us_gal do return new USGallon(value / 4.0)

	redef fun to_imp_gal do return new ImperialGallon(value * 0.20816846)

	redef fun to_us_qt do return self
end

# All kinds of gravity units (e.g. SG, GU, Plato...)
abstract class Gravity
	super Unit

	# Converts a gravity unit to its SG representation
	fun to_sg: SG is abstract

	# Converts a gravity unit to its GU representation
	fun to_gu: GU is abstract

	# Converts a gravity unit to its Plato representation
	fun to_plato: Plato is abstract
end

# Specific Gravity
class SG
	super Gravity

	redef fun unit do return once "SG"

	redef fun to_sg do return self

	redef fun to_gu do return new GU((value - 1.0) * 1000.0)

	redef fun to_plato do return new Plato((258.6 * (value - 1.0)) / (.88 * value + .12))
end

class GU
	super Gravity

	redef fun unit do return once "GU"

	redef fun to_sg do return new SG(value / 1000.0 + 1.0)

	redef fun to_gu do return self

	redef fun to_plato do return to_sg.to_plato
end

class Plato
	super Gravity

	redef fun unit do return once "°P"

	redef fun to_sg do return new SG(1.0 + value / (258.6 - .88 * value))

	redef fun to_gu do return to_sg.to_gu

	redef fun to_plato do return self
end

abstract class Temperature
	super Unit

	fun to_f: Fahrenheit is abstract

	fun to_c: Celsius is abstract
end

class Fahrenheit
	super Temperature

	redef fun unit do return once "°F"

	redef fun to_f do return self

	redef fun to_c do return new Celsius(((value - 32.0) * 5.0) / 9.0)
end

class Celsius
	super Temperature

	redef fun unit do return once "°C"

	redef fun to_c do return self

	redef fun to_f do return new Fahrenheit((value * 9.0 / 5.0) + 32.0)
end

abstract class Time
	super Unit

	fun to_min: Minute is abstract

	fun to_sec: Second is abstract

	fun to_h: Hour is abstract

	fun to_days: Day is abstract

	fun to_weeks: Week is abstract
end

class Minute
	super Time

	redef fun unit do return "min"

	redef fun to_h do return new Hour(value / 60.0)

	redef fun to_min do return self

	redef fun to_sec do return new Second(value * 60.0)

	redef fun to_days do return new Day(value / 1440.0)

	redef fun to_weeks do return new Week(value / 10080.0)
end

class Hour
	super Time

	redef fun unit do return "h"

	redef fun to_h do return self

	redef fun to_min do return new Minute(value * 60.0)

	redef fun to_sec do return new Second(value * 3600.0)

	redef fun to_days do return new Day(value / 24.0)

	redef fun to_weeks do return new Week(value / 168.0)
end

class Second
	super Time

	redef fun unit do return "s"

	redef fun to_h do return new Hour(value / 3600.0)

	redef fun to_min do return new Minute(value / 60.0)

	redef fun to_sec do return self

	redef fun to_days do return new Day(value / 86400.0)

	redef fun to_weeks do return new Week(value / 604800.0)
end

class Day
	super Time

	redef fun unit do return "days"

	redef fun to_h do return new Hour(value * 24.0)

	redef fun to_min do return new Minute(value * 1440.0)

	redef fun to_sec do return new Second(value * 86400.0)

	redef fun to_days do return self

	redef fun to_weeks do return new Week(value / 7.0)
end

class Week
	super Time

	redef fun unit do return "weeks"

	redef fun to_h do return new Hour(value * 168.0)

	redef fun to_min do return new Minute(value * 10080.0)

	redef fun to_sec do return new Second(value * 604800.0)

	redef fun to_days do return new Day(value * 7.0)

	redef fun to_weeks do return self
end
