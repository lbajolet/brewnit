# All the units to be used in brewery calculations are stored here
module units

import db_base

# Any kind of unit, its value should be set at construction time
abstract class Unit
	serialize

	# Any compatible unit type for operations
	type SELFUNIT: Unit

	# Adds two compatible unit types
	fun +(o: SELFUNIT): SELF is abstract

	# Substracts two compatible unit types
	fun -(o: SELFUNIT): SELF is abstract

	# Unit textual description
	var unit: String is abstract

	redef fun to_s do return "{value.to_s} {unit}"

	# Value
	var value: Float
end

# Abstract colour value, expressed in either SRM or EBC
abstract class Colour
	super Unit

	redef type SELFUNIT: Colour

	# Converts the value to SRM units
	fun to_srm: SRM is abstract

	# Converts the value to EBC units
	fun to_ebc: EBC is abstract

	# Build a new Colour with its unit name
	new with_name(value: Float, unit: String) do
		if unit == "SRM" then return new SRM(value)
		if unit == "EBC" then return new EBC(value)
		# If a unit is added but not buildale through this constructor
		# it requires to add the support here.
		abort
	end
end

# Colour, in SRM (Standard Reference Method) units
class SRM
	super Colour

	redef fun +(o) do return new SRM(value + o.to_srm.value)

	redef fun unit do return once "SRM"

	redef fun to_srm do return self

	redef fun to_ebc do return new EBC(value * 1.97)
end

# Colour, in EBC (European Brewery Convention) units
class EBC
	super Colour

	redef fun +(o) do return new EBC(value + o.to_ebc.value)

	redef fun unit do return once "EBC"

	redef fun to_srm do return new SRM(value * .508)

	redef fun to_ebc do return self
end

# Any kind of weight units (g, oz, etc...)
abstract class Weight
	super Unit

	redef type SELFUNIT: Weight

	# Converts the weight into ounces
	fun to_oz: Ounce is abstract

	# Converts the weight into grams
	fun to_g: Gram is abstract

	# Converts the weight into pounds
	fun to_lbs: Pound is abstract

	# Build a new Weight with its unit name
	new with_name(value: Float, unit: String) do
		if unit == "oz" then return new Ounce(value)
		if unit == "lbs" then return new Pound(value)
		if unit == "g" then return new Gram(value)
		# If a unit is added but not buildale through this constructor
		# it requires to add the support here.
		abort
	end
end

# Weight unit, an oz is worth 28.3495231 g
class Ounce
	super Weight

	redef fun +(o) do return new Ounce(value + o.to_oz.value)

	redef fun unit do return once "oz"

	redef fun to_g do return new Gram(value * 28.3495231)

	redef fun to_oz do return self

	redef fun to_lbs do return new Pound(value * 0.0625)
end

# Weight unit, used in US/CAN/UK regions eventually
class Pound
	super Weight

	redef fun +(o) do return new Pound(value + o.to_lbs.value)

	redef fun unit do return once "lbs"

	redef fun to_g do return new Gram(value * 453.59237)

	redef fun to_oz do return new Ounce(value / 0.0625)

	redef fun to_lbs do return self
end

# Weight unit, International System standard
class Gram
	super Weight

	redef fun +(o) do return new Gram(value + o.to_g.value)

	redef fun unit do return once "g"

	redef fun to_oz do return new Ounce(value / 28.3495231)

	redef fun to_g do return self

	redef fun to_lbs do return new Pound(value / 453.59237)
end

# Volume units (e.g. Gallon or Liter)
abstract class Volume
	super Unit

	redef type SELFUNIT: Volume

	# To US Gallon
	fun to_us_gal: USGallon is abstract

	# To US Quart
	fun to_us_qt: USQuart is abstract

	# To Imperial Gallon
	fun to_imp_gal: ImperialGallon is abstract

	# To Liter
	fun to_l: Liter is abstract

	# Build a new Volume with its unit name
	new with_name(value: Float, unit: String) do
		if unit == "gal" then return new USGallon(value)
		if unit == "Imperial gal" then return new ImperialGallon(value)
		if unit == "L" then return new Liter(value)
		if unit == "qt" then return new USQuart(value)
		# If a unit is added but not buildale through this constructor
		# it requires to add the support here.
		abort
	end
end

# Volume unit, standard measurement in the USA
class USGallon
	super Volume

	redef fun +(o) do return new USGallon(value + o.to_us_gal.value)

	redef fun unit do return once "gal"

	redef fun to_us_gal do return self

	redef fun to_l do return new Liter(value / 0.264172052)

	redef fun to_imp_gal do return new ImperialGallon(value * 0.83267384)

	redef fun to_us_qt do return new USQuart(value * 4.0)
end

# Volume unit, is eventually used in the UK or any Commonwealth country
class ImperialGallon
	super Volume

	redef fun +(o) do return new ImperialGallon(value + o.to_imp_gal.value)

	redef fun unit do return once "Imperial gal"

	redef fun to_l do return new Liter(value / 0.219969157)

	redef fun to_us_gal do return new USGallon(value / 0.83267384)

	redef fun to_imp_gal do return self

	redef fun to_us_qt do return new USQuart(value / 0.20816846)
end

# Volume unit, standard from the International System
class Liter
	super Volume

	redef fun +(o) do return new Liter(value + o.to_l.value)

	redef fun unit do return once "L"

	redef fun to_l do return self

	redef fun to_us_gal do return new USGallon(value * 0.264172052)

	redef fun to_imp_gal do return new ImperialGallon(value * 0.219969157)

	redef fun to_us_qt do return new USQuart(value / 0.946352946)
end

# US Quart, seldom used in the USA
class USQuart
	super Volume

	redef fun +(o) do return new USQuart(value + o.to_us_qt.value)

	redef fun unit do return once "qt"

	redef fun to_l do return new Liter(value * 0.946352946)

	redef fun to_us_gal do return new USGallon(value / 4.0)

	redef fun to_imp_gal do return new ImperialGallon(value * 0.20816846)

	redef fun to_us_qt do return self
end

# All kinds of gravity units (e.g. SG, GU, Plato...)
abstract class Gravity
	super Unit

	redef type SELFUNIT: Gravity

	# Converts a gravity unit to its SG representation
	fun to_sg: SG is abstract

	# Converts a gravity unit to its GU representation
	fun to_gu: GU is abstract

	# Converts a gravity unit to its Plato representation
	fun to_plato: Plato is abstract

	# Build a new Gravity with its unit name
	new with_name(value: Float, unit: String) do
		if unit == "SG" then return new SG(value)
		if unit == "GU" then return new GU(value)
		if unit == "P" then return new Plato(value)
		# If a unit is added but not buildale through this constructor
		# it requires to add the support here.
		abort
	end
end

# Specific Gravity
class SG
	super Gravity

	redef fun +(o) do return new SG(value + o.to_sg.value)

	redef fun unit do return once "SG"

	redef fun to_sg do return self

	redef fun to_gu do return new GU((value - 1.0) * 1000.0)

	redef fun to_plato do return new Plato((258.6 * (value - 1.0)) / (.88 * value + .12))
end

# Gravitu Units, standard gravity measure
class GU
	super Gravity

	redef fun +(o) do return new GU(value + o.to_gu.value)

	redef fun unit do return once "GU"

	redef fun to_sg do return new SG(value / 1000.0 + 1.0)

	redef fun to_gu do return self

	redef fun to_plato do return to_sg.to_plato
end

# Degrees Plato, used in brewing
class Plato
	super Gravity

	redef fun +(o) do return new Plato(value + o.to_plato.value)

	redef fun unit do return once "°P"

	redef fun to_sg do return new SG(1.0 + value / (258.6 - .88 * value))

	redef fun to_gu do return to_sg.to_gu

	redef fun to_plato do return self
end

# Builds temperature units
abstract class Temperature
	super Unit

	redef type SELFUNIT: Temperature

	# To Fahrenheit
	fun to_f: Fahrenheit is abstract

	# To Celsius
	fun to_c: Celsius is abstract

	# Build a new Temperature with its unit name
	new with_name(value: Float, unit: String) do
		if unit == "F" then return new Fahrenheit(value)
		if unit == "C" then return new Celsius(value)
		# If a unit is added but not buildale through this constructor
		# it requires to add the support here.
		abort
	end
end

# Fahrenheit Degrees, used in the USA and eventually
# in other countries for special contexts
class Fahrenheit
	super Temperature

	redef fun +(o) do return new Fahrenheit(value + o.to_f.value)

	redef fun unit do return once "°F"

	redef fun to_f do return self

	redef fun to_c do return new Celsius(((value - 32.0) * 5.0) / 9.0)
end

# Celsius degrees, standard for temperature measurement
class Celsius
	super Temperature

	redef fun +(o) do return new Celsius(value + o.to_c.value)

	redef fun unit do return once "°C"

	redef fun to_c do return self

	redef fun to_f do return new Fahrenheit((value * 9.0 / 5.0) + 32.0)
end

# Time units
abstract class Time
	super Unit

	redef type SELFUNIT: Time

	# To minutes
	fun to_min: Minute is abstract

	# To seconds
	fun to_sec: Second is abstract

	# To hours
	fun to_h: Hour is abstract

	# To days
	fun to_days: Day is abstract

	# To weeks
	fun to_weeks: Week is abstract

	# Build a new Time with its unit name
	new with_name(value: Float, unit: String) do
		if unit == "min" then return new Minute(value)
		if unit == "h" then return new Hour(value)
		if unit == "s" then return new Second(value)
		if unit == "day" or unit == "days" then return new Day(value)
		if unit == "week" or unit == "weeks" then return new Week(value)
		# If a unit is added but not buildale through this constructor
		# it requires to add the support here.
		abort
	end
end

# Minute
class Minute
	super Time

	redef fun +(o) do return new Minute(value + o.to_min.value)

	redef fun unit do return "min"

	redef fun to_h do return new Hour(value / 60.0)

	redef fun to_min do return self

	redef fun to_sec do return new Second(value * 60.0)

	redef fun to_days do return new Day(value / 1440.0)

	redef fun to_weeks do return new Week(value / 10080.0)
end

# Hour
class Hour
	super Time

	redef fun +(o) do return new Hour(value + o.to_h.value)

	redef fun unit do return "h"

	redef fun to_h do return self

	redef fun to_min do return new Minute(value * 60.0)

	redef fun to_sec do return new Second(value * 3600.0)

	redef fun to_days do return new Day(value / 24.0)

	redef fun to_weeks do return new Week(value / 168.0)
end

# Second
class Second
	super Time

	redef fun +(o) do return new Second(value + o.to_sec.value)

	redef fun unit do return "s"

	redef fun to_h do return new Hour(value / 3600.0)

	redef fun to_min do return new Minute(value / 60.0)

	redef fun to_sec do return self

	redef fun to_days do return new Day(value / 86400.0)

	redef fun to_weeks do return new Week(value / 604800.0)
end

# Day
class Day
	super Time

	redef fun +(o) do return new Day(value + o.to_days.value)

	redef fun unit do return "days"

	redef fun to_h do return new Hour(value * 24.0)

	redef fun to_min do return new Minute(value * 1440.0)

	redef fun to_sec do return new Second(value * 86400.0)

	redef fun to_days do return self

	redef fun to_weeks do return new Week(value / 7.0)
end

# Week
class Week
	super Time

	redef fun +(o) do return new Week(value + o.to_weeks.value)

	redef fun unit do return "weeks"

	redef fun to_h do return new Hour(value * 168.0)

	redef fun to_min do return new Minute(value * 10080.0)

	redef fun to_sec do return new Second(value * 604800.0)

	redef fun to_days do return new Day(value * 7.0)

	redef fun to_weeks do return self
end
