import parser
import nitcc_runtime
import model
import literal

class UnitVisitor
	super Visitor

	redef fun visit(n) do n.accept_unit_visitor(self)
end

redef class Node

	fun accept_unit_visitor(v: UnitVisitor) do visit_children v

end

redef class Nvolunit

	var val: Volume

	fun volume_factory: VolumeFactory do return once new VolumeFactory

	redef fun accept_unit_visitor(v) do val = volume_factory.build_unit(n_number.value, n_volume_unit.text)

end

redef class Ntmpunit

	var val: Temperature

	fun temp_factory: TemperatureFactory do return once new TemperatureFactory

	redef fun accept_unit_visitor(v) do val = temp_factory.build_unit(n_number.value, n_temp_unit.text)
end

redef class Ngrvunit

	var val: Gravity

	fun grav_factory: GravityFactory do return once new GravityFactory

	redef fun accept_unit_visitor(v) do val = grav_factory.build_unit(n_number.value, n_gravity_unit.text)
end

redef class Ncolunit

	var val: Colour

	fun col_factory: ColourFactory do return once new ColourFactory

	redef fun accept_unit_visitor(v) do val = col_factory.build_unit(n_number.value, n_colour_unit.text)
end

redef class Nweiunit

	var val: Weight

	fun weight_factory: WeightFactory do return once new WeightFactory

	redef fun accept_unit_visitor(v) do val = weight_factory.build_unit(n_number.value, n_weight_unit.text)
end

redef class Ntimunit

	var val: Time

	fun time_factory: TimeFactory do return once new TimeFactory

	redef fun accept_unit_visitor(v) do val = time_factory.build_unit(n_number.value, n_time_unit.text)
end
