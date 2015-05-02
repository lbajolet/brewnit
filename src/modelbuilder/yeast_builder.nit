import literal
import unit_build
import model
import console

class YeastVisitor
	super Visitor

	var errors = new Array[String]

	redef fun visit(n) do
		n.accept_yeast_visitor(self)
		for i in errors do print i.red
	end
end

redef class Node

	fun accept_yeast_visitor(v: YeastVisitor) do visit_children(v)
end

redef class Nyeast

	var yeast: Yeast

	redef fun accept_yeast_visitor(v) do
		var fl: nullable Int = null
		var att: nullable Float = null
		for i in n_yeast_body.children do
			if i isa Nyeast_body_floc then
				fl = i.flocculation
			else if i isa Nyeast_body_att then
				att = i.attenuation
			end
		end
		var err = false
		if fl == null then
			v.errors.add "Error, missing flocculation information at {position.as(not null)}"
			err = true
		end
		if att == null then
			v.errors.add "Error, missing attenuation information at {position.as(not null)}"
			err = true
		end
		yeast = new Yeast("", n_string.value, [""], fl.as(not null), att.as(not null))
	end
end

redef class Nyeast_body_floc

	fun flocculation: Int do
		var floc_text = n_flocculation_type.text
		if floc_text == "low" then
			return 0
		else if floc_text == "medium" then
			return 1
		else if floc_text == "high" then
			return 2
		end
		return -1
	end
end

redef class Nyeast_body_att

	fun attenuation: Float do return n_number.value / 100.0
end
