import parser
import nitcc_runtime
import model
import literal

class UnitVisitor
	super Visitor

	redef fun visit(n) do n.accept_unit_visitor(self)
end

redef class Node

	# Accepts a `UnitVisitor` `v`
	fun accept_unit_visitor(v: UnitVisitor) do visit_children v

end

redef class Nvolunit

	# Parsed volume value
	var val: Volume is noinit

	redef fun accept_unit_visitor(v) do val = new Volume.with_name(n_number.value, n_volume_unit.text)
end

redef class Ntmpunit

	# Parsed temperature value
	var val: Temperature is noinit

	redef fun accept_unit_visitor(v) do val = new Temperature.with_name(n_number.value, n_temp_unit.text)
end

redef class Ngrvunit

	# Parsed gravity value
	var val: Gravity is noinit

	redef fun accept_unit_visitor(v) do val = new Gravity.with_name(n_number.value, n_gravity_unit.text)
end

redef class Ncolunit

	# Parsed colour value
	var val: Colour is noinit

	redef fun accept_unit_visitor(v) do val = new Colour.with_name(n_number.value, n_colour_unit.text)
end

redef class Nweiunit

	# Parsed weight value
	var val: Weight is noinit

	redef fun accept_unit_visitor(v) do val = new Weight.with_name(n_number.value, n_weight_unit.text)
end

redef class Ntimunit

	# Parsed time value
	var val: Time is noinit

	redef fun accept_unit_visitor(v) do val = new Time.with_name(n_number.value, n_time_unit.text)
end
