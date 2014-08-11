import literal
import unit_build
import model

class EquipmentVisitor
	super Visitor

	var errors = new Array[String]

	redef fun enter_visit(n) do n.accept_equipment_visitor(self)
end

redef class Node

	fun accept_equipment_visitor(v: EquipmentVisitor) do visit_children(v)

end

redef class Nequipment
	var eq: Equipment

	redef fun accept_equipment_visitor(v) do
		var eff: nullable Float = null
		var vol: nullable Volume = null
		for i in n_equipment_body.children do
			if i isa Nequipment_body_efficiency then
				eff = i.efficiency
			else if i isa Nequipment_body_volume then
				vol = i.volume
			end
		end
		var err = false
		if eff == null then
			v.errors.add "Error, missing efficiency information at {position.as(not null)}"
			err = true
		end
		if vol == null then
			v.errors.add "Error, missing volume information at {position.as(not null)}"
			err = true
		end
		if err then return
		eq = new Equipment(n_string.value, eff.as(not null), vol.as(not null))
	end
end

redef class Nequipment_body_efficiency

	fun efficiency: Float do return n_number.value / 100.0
end

redef class Nequipment_body_volume

	fun volume: Volume do return n_volunit.val
end
