module db_entities

import recipe
import serialization

redef class DBContext
	fun has_hop(name: String): Bool do
		var db = connection
		var query = "* FROM hops WHERE name = {name.to_sql_string}"
		var res = db.select(query)
		if res == null then
			print "Cannot fetch hop by name"
			log_sql_error(self, query)
			return false
		end
		return res.iterator.to_a.length != 0
	end

	fun has_fermentable(name: String): Bool do
		var db = connection
		var query = "* FROM fermentables WHERE name = {name.to_sql_string}"
		var res = db.select(query)
		if res == null then
			print "Cannot fetch fermentable by name"
			log_sql_error(self, query)
			return false
		end
		return res.iterator.to_a.length != 0
	end
end

redef class Fermentable
	serialize

	fun type_id: Int is abstract

	redef fun insert do
		var query = "INSERT INTO fermentables(name, potential, colour, ferm_type) VALUES({name.to_sql_string}, {potential.to_sg.value}, {colour.to_srm.value}, {type_id})"
		return basic_insert(query)
	end

	redef fun attach_query do return "* FROM fermentables WHERE ferm_type = {type_id} AND name = {name.to_sql_string}"
end

redef class Grain
	redef fun type_id do return 1
end

redef class Adjunct
	redef fun type_id do return 2
end

redef class Sugar
	redef fun type_id do return 3
end

redef class Extract
	redef fun type_id do return 4
end

redef class Yeast
	serialize

	redef fun insert do
		var query = "INSERT INTO yeasts(brand, name, attenuation) VALUES ({brand.to_sql_string}, {name.to_sql_string}, {attenuation})"
		if not basic_insert(query) then return false
		for i in aliases do
			var ctx = context
			if ctx == null then return true
			var db = ctx.connection
			query = "INSERT INTO yeast_aliases(yeast_id, name) VALUES ({id}, {i.to_sql_string})"
			db.execute(query)
		end
		return true
	end

	redef fun update do
		var query = "UPDATE yeasts SET brand = {brand.to_sql_string}, name = {name.to_sql_string}, attenuation = {attenuation} WHERE id = {id}"
		return basic_update(query)
	end

	redef fun attach_query do return "* FROM yeasts WHERE name = {name.to_sql_string}"
end

redef class Equipment
	serialize

	redef fun insert do
		var query = "INSERT INTO equipments(name, efficiency, volume, losses, boil_loss) VALUES ({name.to_sql_string}, {efficiency}, {volume.to_l.value}, {trub_losses.to_l.value}, {boil_loss})"
		return basic_insert(query)
	end

	redef fun update do
		var query = "UPDATE equipments SET name = {name.to_sql_string}, efficiency = {efficiency}, volume = {volume.to_l.value}, losses = {trub_losses.to_l.value}, boil_loss = {boil_loss} WHERE id = {id}"
		return basic_update(query)
	end

	redef fun attach_query do return "* FROM equipments WHERE name = {name.to_sql_string} AND efficiency = {efficiency}"
end

redef class FermentableProfile
	serialize

	var recipe_id: nullable Int = null is writable

	redef fun insert do
		var rid = recipe_id
		if rid == null then
			print "Cannot add FermentableProfile due to it not being attached to a recipe"
			return false
		end
		var ctx = context
		if ctx == null then return false
		fermentable.context = ctx
		var query = "INSERT INTO fermentable_profiles(fermentable_id, recipe_id, quantity) VALUES({fermentable.id}, {rid}, {quantity.to_g.value})"
		return basic_insert(query)
	end

	redef fun update do
		var query = "UPDATE fermentable_profiles SET quantity = {quantity.to_g.value}"
		return basic_update(query)
	end

	redef fun delete do
		var query = "DELETE fermentable_profiles WHERE id = {id}"
		return basic_delete(query)
	end

	redef fun context=(ctx) do
		fermentable.context = ctx
		set_context ctx
	end
end

redef class Hop
	serialize

	redef fun insert do
		var query = "INSERT INTO hops(name) VALUES ({name.to_sql_string})"
		return basic_insert(query)
	end

	redef fun update do
		var query = "UPDATE hops SET name = {name.to_sql_string} WHERE id = {id}"
		return basic_update(query)
	end

	redef fun attach_query do return "* FROM hops WHERE name = {name.to_sql_string}"
end

redef class HopProfile
	serialize

	var recipe_id: nullable Int = null is writable

	redef fun insert do
		var rid = recipe_id
		if rid == null then
			print "Cannot insert HopProfile due to it not being attached to a recipe"
			return false
		end
		var ctx = context
		if ctx == null then return false
		hop.context = ctx
		var query = "INSERT INTO hop_profiles(hop_id, recipe_id, quantity, time, alpha_acid, use) VALUES ({hop.id}, {rid}, {quantity.to_g.value}, {time.to_sec.value}, {alpha_acid}, {use})"
		return basic_insert(query)
	end

	redef fun update do
		var query = "UPDATE hop_profiles SET quantity = {quantity.to_g.value}, time = {time.to_sec.value}, alpha_acid = {alpha_acid}, use = {use}"
		return basic_update(query)
	end

	redef fun delete do
		var query = "DELETE hop_profiles WHERE id = {id}"
		return basic_delete(query)
	end

	redef fun context=(ctx) do
		hop.context = ctx
		set_context ctx
	end
end

redef class Recipe
	serialize

	redef fun insert do
		if not yeast.commit or not equipment.commit then return false
		var m_grav = measured_gravity
		var m_vol = measured_volume
		var f_grav = final_gravity
		var query = "INSERT INTO recipes(name, target_volume, target_temperature, mash_time, equipment_id, yeast_id, measured_volume, measured_gravity, final_gravity) VALUES({name.to_sql_string}, {target_volume.to_l.value}, {target_mash_temp.to_c.value}, {mash_time.to_sec.value}, {equipment.id}, {yeast.id}"
		var unit = "NULL"
		if m_grav != null then unit = m_grav.to_sg.value.to_s
		query += ", {unit}"
		unit = "NULL"
		if m_vol != null then unit = m_vol.to_l.value.to_s
		query += ", {unit}"
		unit = "NULL"
		if f_grav != null then unit = f_grav.to_sg.value.to_s
		query += ", {unit})"
		if not basic_insert(query) then return false
		var ctx = context
		if ctx == null then return false
		for i in malts do
			if not ctx.has_fermentable(i.fermentable.name) then i.fermentable.commit
			i.recipe_id = id
			i.commit
		end
		for i in hops do
			if not ctx.has_hop(i.hop.name) then i.hop.commit
			i.recipe_id = id
			i.commit
		end
		return true
	end

	redef fun update do
		if not yeast.commit or equipment.commit then return false
		var m_grav = measured_gravity
		var m_vol = measured_volume
		var f_grav = final_gravity
		var ns = "NULL".to_sql_string
		var og_unit = ns
		var mv_unit = ns
		var fg_unit = ns
		if m_grav != null then og_unit = m_grav.to_sg.value.to_s
		if m_vol != null then mv_unit = m_vol.to_l.value.to_s
		if f_grav != null then fg_unit = f_grav.to_sg.value.to_s
		var query = "UPDATE recipes SET name = {name.to_sql_string}, target_volume = {target_volume.to_l.value}, target_temperature = {target_mash_temp.to_c.value}, mash_time = {mash_time.to_sec.value}, equipment_id = {equipment.id}, yeast_id = {yeast.id}, measured_volume = {mv_unit}, measured_gravity = {og_unit}, final_gravity = {fg_unit} WHERE id = {id}"
		if not basic_update(query) then return false
		var ctx = context
		if ctx == null then return false
		if not remove_uses then return false
		for i in malts do
			if not ctx.has_fermentable(i.fermentable.name) then i.fermentable.commit
			i.recipe_id = id
			i.commit
		end
		for i in hops do
			if not ctx.has_hop(i.hop.name) then i.hop.commit
			i.recipe_id = id
			i.commit
		end
		return true
	end

	fun remove_uses: Bool do
		var ctx = context
		if ctx == null then return false
		var ferm_use_query = "DELETE fermentable_profiles WHERE recipe_id = {id}"
		var hop_use_query = "DELETE hop_profiles WHERE recipe_id = id"
		var db = ctx.connection
		if not db.execute(ferm_use_query) then
			ctx.log_sql_error(self, ferm_use_query)
			return false
		end
		if not db.execute(hop_use_query) then
			ctx.log_sql_error(self, hop_use_query)
			return false
		end
		return true
	end

	redef fun attach_query do return "* FROM recipes WHERE name = {name.to_sql_string} AND target_volume = {target_volume.value} AND target_temperature = {target_mash_temp.value}"

	redef fun context=(ctx) do
		super
		yeast.context = ctx
		equipment.context = ctx
		for i in malts do i.context = ctx
		for i in hops do i.context = ctx
	end
end
