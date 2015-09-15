import literal
import unit_build
import model
import console

class HopVisitor
	super Visitor

	var errors = new Array[String]

	redef fun visit(n) do
		n.accept_hop_visitor(self)
		for i in errors do print i.red
	end
end

redef class Node

	fun accept_hop_visitor(v: HopVisitor) do visit_children(v)

end

redef class Nhops

	var hops: Array[HopProfile]

	redef fun accept_hop_visitor(v) do
		super
		var arr = n_hop_profile.children
		hops = new Array[HopProfile].with_capacity(arr.length)
		for i in arr do
			hops.push i.val
		end
	end

end

redef class Nhop_profile

	var val: HopProfile

	redef fun accept_hop_visitor(v) do
		var aa: nullable Float = null
		var qt: nullable Weight = null
		var time: nullable Time = null
		var hop_type: nullable Int = null
		var use: nullable Int = null

		for i in n_hop_profile_body.children do
			if i isa Nhop_profile_body_aa then
				aa = i.alpha_acid
			else if i isa Nhop_profile_body_quantity then
				qt = i.quantity
			else if i isa Nhop_profile_body_time then
				time = i.time
			else if i isa Nhop_profile_body_type then
				hop_type = i.hop_type
			else if i isa Nhop_profile_body_use then
				use = i.use
			end
		end

		var err_reported = false

		if aa == null then
			err_reported = true
			v.errors.add "Missing alpha-acid information at {position.as(not null)}"
		end
		if qt == null then
			err_reported = true
			v.errors.add "Missing quantity information at {position.as(not null)}"
		end
		if time == null then
			err_reported = true
			v.errors.add "Missing time information at {position.as(not null)}"
		end
		if hop_type == null then
			err_reported = true
			v.errors.add "Missing hop type information at {position.as(not null)}"
		end
		if use == null then
			err_reported = true
			v.errors.add "Missing hop use information at {position.as(not null)}"
		end

		var hp: Hop

		if hop_type == 0 then
			hp = new Leaf(n_string.value,aa.as(not null))
		else if hop_type == 1 then
			hp = new Pellet(n_string.value,aa.as(not null))
		else
			v.errors.add("Wrong value for hop type at {position.as(not null)}")
			return
		end

		if use == 0 then
			val = new Boil(hp, qt.as(not null), time.as(not null))
		else if use == 1 then
			val = new DryHop(hp, qt.as(not null), time.as(not null))
		else
			v.errors.add("Wrong value for hop use at {position.as(not null)}")
			return
		end
	end

end

redef class Nhop_profile_body_aa

	fun alpha_acid: Float do return n_number.value
end

redef class Nhop_profile_body_quantity

	fun quantity: Weight do return n_weiunit.val
end

redef class Nhop_profile_body_time

	fun time: Time do return n_timunit.val
end

redef class Nhop_profile_body_type

	var hop_type: Int is lazy do
		var type_str = n_hop_type.text
		if type_str == "Leaf" then
			return 0
		else if type_str == "Pellet" then
			return 1
		end
		return -1
	end
end

redef class Nhop_profile_body_use

	var use: Int is lazy do
		var use_str = n_hop_use.text
		if use_str == "Boil" then
			return 0
		else if use_str == "DryHop" then
			return 1
		end
		return -1
	end
end

