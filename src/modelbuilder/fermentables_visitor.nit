import parser
import nitcc_runtime
import model
import literal
import unit_build
import console

class FermentablesVisitor
	super Visitor

	var errors = new Array[String]

	redef fun visit(n) do
		n.accept_fermentables_visitor(self)
		for i in errors do print i.red
	end
end

redef class Node

	fun accept_fermentables_visitor(v: FermentablesVisitor) do visit_children(v)
end

redef class Nfermentables

	var ferms: Array[FermentableProfile]

	redef fun accept_fermentables_visitor(v) do
		visit_children(v)
		var arr = n_compound.children
		ferms = new Array[FermentableProfile].with_capacity(arr.length)
		for i in arr do
			ferms.push i.ferm
		end
	end

end

redef class Ncompound

	var ferm: FermentableProfile

	var val: Fermentable

	var qt: nullable Weight = null

	fun build_ferm do ferm = new FermentableProfile(val, qt.as(not null))

	fun check_infos(g: nullable Gravity, c: nullable Colour, qt: nullable Weight, v: FermentablesVisitor): Bool do
		var err = false
		if g == null then
			err = true
			v.errors.add("Missing potential information {position.as(not null)}")
		end
		if c == null then
			err = true
			v.errors.add("Missing colour information {position. as(not null)}")
		end
		if qt == null then
			err = true
			v.errors.add("Missing quantity information {position.as(not null)}")
		end
		return not err
	end
end

redef class Ncompound_grain

	redef fun accept_fermentables_visitor(v) do
		var g: nullable Gravity = null
		var c: nullable Colour = null
		for i in n_compound_body.children do
			if i isa Ncompound_body_potential then
				g = i.get_potential
			else if i isa Ncompound_body_colour then
				c = i.get_colour
			else if i isa Ncompound_body_quantity then
				qt = i.get_quantity
			end
		end
		if not check_infos(g,c,qt,v) then return
		val = new Grain(n_string.value, g.as(not null), c.as(not null))
		build_ferm
	end
end

redef class Ncompound_adjunct

	redef fun accept_fermentables_visitor(v) do
		var g: nullable Gravity = null
		var c: nullable Colour = null
		for i in n_compound_body.children do
			if i isa Ncompound_body_potential then
				g = i.get_potential
			else if i isa Ncompound_body_colour then
				c = i.get_colour
			else if i isa Ncompound_body_quantity then
				qt = i.get_quantity
			end
		end
		if not check_infos(g,c,qt,v) then return
		val = new Adjunct(n_string.value, g.as(not null), c.as(not null))
		build_ferm
	end
end

redef class Ncompound_sugar

	redef fun accept_fermentables_visitor(v) do
		var g: nullable Gravity = null
		var c: nullable Colour = null
		for i in n_compound_body.children do
			if i isa Ncompound_body_potential then
				g = i.get_potential
			else if i isa Ncompound_body_colour then
				c = i.get_colour
			else if i isa Ncompound_body_quantity then
				qt = i.get_quantity
			end
		end
		if not check_infos(g,c,qt,v) then return
		val = new Sugar(n_string.value, g.as(not null), c.as(not null))
		build_ferm
	end

end

redef class Ncompound_extract

	redef fun accept_fermentables_visitor(v) do
		var g: nullable Gravity = null
		var c: nullable Colour = null
		for i in n_compound_body.children do
			if i isa Ncompound_body_potential then
				g = i.get_potential
			else if i isa Ncompound_body_colour then
				c = i.get_colour
			else if i isa Ncompound_body_quantity then
				qt = i.get_quantity
			end
		end
		if not check_infos(g,c,qt,v) then return
		val = new Extract(n_string.value, g.as(not null), c.as(not null))
		build_ferm
	end
end

redef class Ncompound_body_potential

	fun get_potential: Gravity do return n_grvunit.val
end

redef class Ncompound_body_colour

	fun get_colour: Colour do return n_colunit.val
end

redef class Ncompound_body_quantity

	fun get_quantity: Weight do return n_weiunit.val
end
