# Binds database entities to model
module db_binding

import db_entities
import pipeline

redef class DBContext

	# Worker producing `Fermentables`
	fun fermentable_worker: FermentableWorker do return once new FermentableWorker

	# Worker producing `Hops`
	fun hop_worker: HopWorker do return once new HopWorker

	# Worker producing `Recipes`
	fun recipe_worker: RecipeWorker do return once new RecipeWorker

	# Worker producing `Equipments`
	fun equipment_worker: EquipmentWorker do return once new EquipmentWorker

	# Worker producing `Yeasts`
	fun yeast_worker: YeastWorker do return once new YeastWorker

	# Worker producing `HopProfiles`
	fun hop_profile_worker: HopProfileWorker do return once new HopProfileWorker

	# Worker producing `FermentableProfiles`
	fun fermentable_profile_worker: FermentableProfileWorker do return once new FermentableProfileWorker

	# Fetches fermentables that have already been deserialized from database
	var fermentable_cache = new HashMap[Int, Fermentable]

	# Fetches hops that have already been deserialized from database
	var hop_cache = new HashMap[Int, Hop]

	# Fetch a `Fermentable` by its id
	#
	# Returns `null` if none could be found
	fun fermentable_by_id(id: Int): nullable Fermentable do
		if fermentable_cache.has_key(id) then return fermentable_cache[id]
		var ferm = fermentable_worker.fetch_one(self, "* FROM fermentables WHERE id = {id}")
		if ferm == null then return null
		fermentable_cache[ferm.id] = ferm
		return ferm
	end

	# Fetch a `Hop` by its id
	#
	# Returns `null` if none could be found
	fun hop_by_id(id: Int): nullable Hop do
		if hop_cache.has_key(id) then return hop_cache[id]
		var hop = hop_worker.fetch_one(self, "* FROM hops WHERE id = {id}")
		if hop == null then return null
		hop_cache[hop.id] = hop
		return hop
	end

	# Fetch a `Yeast` by its id
	#
	# Returns `null` if none could be found
	fun yeast_by_id(id: Int): nullable Yeast do return yeast_worker.fetch_one(self, "* FROM yeasts WHERE id = {id}")

	# Fetch an `Equipment` by its id
	#
	# Returns `null` if none could be found
	fun equipment_by_id(id: Int): nullable Equipment do return equipment_worker.fetch_one(self, "* FROM equipments WHERE id = {id}")

	# Fetch a `Recipe` by its id
	#
	# Returns `null` if none could be found
	fun recipe_by_id(id: Int): nullable Recipe do return recipe_worker.fetch_one(self, "* FROM recipes WHERE id = {id}")

	# Fetch an `HopProfile` by its id
	#
	# Returns `null` if none could be found
	fun hop_profile_by_id(id: Int): nullable HopProfile do return hop_profile_worker.fetch_one(self, "* FROM hop_profiles WHERE id = {id}")

	# Fetch an `FermentableProfile` by its id
	#
	# Returns `null` if none could be found
	fun fermentable_profile_by_id(id: Int): nullable FermentableProfile do return fermentable_profile_worker.fetch_one(self, "* FROM fermentable_profiles WHERE id = {id}")
end

# A worker specialized in getting data from Database Statements
abstract class EntityWorker
	# The kind of entity `self` supports
	type ENTITY: Entity

	# Checks the content of a row for compatibility with an object `ENTITY`
	fun check_data(row: StatementRow): Bool do
		var m = row.map
		for i in expected_data do
			if not m.has_key(i) then
				print "Missing data `{i}` in map for `{entity_type}`"
				print "map was {m.join("\n", ": ")}"
				return false
			end
		end
		return true
	end

	# Tries to fetch an entity from a row.
	fun perform(ctx: DBContext, row: StatementRow): nullable ENTITY do
		if not check_data(row) then return null
		return make_entity_from_row(ctx, row)
	end

	# Fetch one `ENTITY` from DB with `query`
	fun fetch_one(ctx: DBContext, query: String): nullable ENTITY do
		var res = ctx.try_select(query)
		if res == null then
			ctx.log_sql_error(self, query)
			return null
		end
		return fetch_one_from_statement(ctx, res)
	end

	# Fetch multiple `ENTITY` from DB with `query`
	fun fetch_multiple(ctx: DBContext, query: String): Array[ENTITY] do
		var res = ctx.try_select(query)
		if res == null then
			ctx.log_sql_error(self, query)
			return new Array[ENTITY]
		end
		return fetch_multiple_from_statement(ctx, res)
	end

	# Fetch multiple `ENTITY` from DB with `rows`
	fun fetch_one_from_statement(ctx: DBContext, row: Statement): nullable ENTITY do
		var ret = fetch_multiple_from_statement(ctx, row)
		if ret.is_empty then return null
		return ret.first
	end

	# Fetch multiple `ENTITY` from DB with `rows`
	fun fetch_multiple_from_statement(ctx: DBContext, rows: Statement): Array[ENTITY] do
		var ret = new Array[ENTITY]
		for i in rows do
			var el = perform(ctx, i)
			if el == null then
				print "Error when deserializing `{entity_type}` from database"
				print "Got `{i.map}`"
				ret.clear
				break
			end
			ret.add el
		end
		return ret
	end

	# Which data is expected in a map?
	fun expected_data: Array[String] is abstract

	# Returns a user-readable version of `ENTITY`
	fun entity_type: String is abstract

	# Buils an entity from a Database Row
	fun make_entity_from_row(ctx: DBContext, row: StatementRow): ENTITY is abstract
end

# A Worker capable of building Fermentables
class FermentableWorker
	super EntityWorker

	redef type ENTITY: Fermentable

	redef fun entity_type do return "Fermentable"

	redef fun expected_data do return ["id", "name", "potential", "colour", "ferm_type"]

	redef fun make_entity_from_row(ctx, row) do
		var map = row.map
		var fid = map["id"].as(Int)
		var fname = map["name"].as(String)
		var fpotential = map["potential"].as(Float)
		var fcolour = map["colour"].as(Float)
		var ferm_type = map["ferm_type"].as(Int)
		var grav = new SG(fpotential)
		var col = new SRM(fcolour)
		var ferm = new Fermentable.from_db(ctx, fid, fname, grav, col, ferm_type)
		return ferm
	end
end

# A Worker capable of building Yeasts
class YeastWorker
	super EntityWorker

	redef type ENTITY: Yeast

	redef fun entity_type do return "Yeast"

	redef fun expected_data do return ["id", "brand", "name", "attenuation"]

	redef fun make_entity_from_row(ctx, row) do
		var map = row.map
		var id = map["id"].as(Int)
		var name = map["name"].as(String)
		var brand = map["brand"].as(String)
		var attenuation = map["attenuation"].as(Float)
		var ret = new Yeast(brand, name, new Array[String], attenuation)
		ret.set_context(ctx)
		ret.id = id
		ret.fetch_aliases
		return ret
	end
end

# A Worker capable of building Equipments
class EquipmentWorker
	super EntityWorker

	redef type ENTITY: Equipment

	redef fun entity_type do return "Equipment"

	redef fun expected_data do return ["id", "name", "efficiency", "volume", "losses", "boil_loss"]

	redef fun make_entity_from_row(ctx, row) do
		var map = row.map
		var id = map["id"].as(Int)
		var name = map["name"].as(String)
		var efficiency = map["efficiency"].as(Float)
		var volume = map["volume"].as(Float)
		var losses = map["losses"].as(Float)
		var boil_loss = map["boil_loss"].as(Float)
		var vol = new Liter(volume)
		var ret = new Equipment(name, efficiency, vol)
		var loss = new Liter(losses)
		ret.trub_losses = loss
		ret.boil_loss = boil_loss
		ret.id = id
		ret.set_context(ctx)
		return ret
	end
end

# A Worker capable of building Hops
class HopWorker
	super EntityWorker

	redef type ENTITY: Hop

	redef fun entity_type do return "Hop"

	redef fun expected_data do return ["id", "name"]

	redef fun make_entity_from_row(ctx, row) do
		var map = row.map
		var id = map["id"].as(Int)
		var name = map["name"].as(String)
		var ret =  new Hop(name)
		ret.id = id
		ret.set_context(ctx)
		return ret
	end
end

# A Worker capable of building FermentableProfiles
class FermentableProfileWorker
	super EntityWorker
	
	redef type ENTITY: FermentableProfile

	redef fun entity_type do return "FermentableProfile"

	redef fun expected_data do return ["id", "fermentable_id", "recipe_id", "quantity"]

	redef fun make_entity_from_row(ctx, row) do
		var map = row.map
		var id = map["id"].as(Int)
		var fermentable_id = map["fermentable_id"].as(Int)
		var recipe_id = map["recipe_id"].as(Int)
		var quantity = map["quantity"].as(Float)
		var quant = new Gram(quantity)
		var ferm = ctx.fermentable_by_id(fermentable_id)
		# Corrupt Database
		if ferm == null then
			print "Fatal Error: Corrupt database detected on {entity_type}".red
			abort
		end
		var ret = new FermentableProfile(ferm, quant)
		ret.id = id
		ret.recipe_id = recipe_id
		ret.set_context(ctx)
		return ret
	end
end

# A Worker capable of building HopProfiles
class HopProfileWorker
	super EntityWorker

	redef type ENTITY: HopProfile

	redef fun entity_type do return "HopProfile"

	redef fun expected_data do return ["id", "hop_id", "recipe_id", "quantity", "time", "alpha_acid", "use"]

	redef fun make_entity_from_row(ctx, row) do
		var map = row.map
		var id = map["id"].as(Int)
		var hop_id = map["hop_id"].as(Int)
		var recipe_id = map["recipe_id"].as(Int)
		var quantity = map["quantity"].as(Float)
		var time = map["time"].as(Float)
		var alpha_acid = map["alpha_acid"].as(Float)
		var use = map["use"].as(Int)
		var hop = ctx.hop_by_id(hop_id)
		if hop == null then
			print "Fatal Error: Corrupt database detected on {entity_type}".red
			abort
		end
		var quant = new Gram(quantity)
		var rtime = new Second(time)
		var ret = new HopProfile(hop, quant, rtime, alpha_acid, use)
		ret.id = id
		ret.recipe_id = recipe_id
		ret.set_context(ctx)
		return ret
	end
end

# A Worker capable of building Recipes
class RecipeWorker
	super EntityWorker

	redef type ENTITY: Recipe

	redef fun entity_type do return "Recipe"

	redef fun expected_data do return ["id", "name", "target_volume", "target_temperature", "mash_time", "equipment_id", "yeast_id", "measured_volume", "measured_gravity", "final_gravity"]

	redef fun make_entity_from_row(ctx, row) do
		var map = row.map
		var id = map["id"].as(Int)
		var name = map["name"].as(String)
		var tgt_vol = map["target_volume"].as(Float)
		var tgt_temp = map["target_temperature"].as(Float)
		var m_time = map["mash_time"].as(Float)
		var equipment_id = map["equipment_id"].as(Int)
		var yeast_id = map["yeast_id"].as(Int)
		var target_vol = new Liter(tgt_vol)
		var mash_temp = new Celsius(tgt_temp)
		var mash_time = new Second(m_time)
		var equipment = ctx.equipment_by_id(equipment_id)
		if equipment == null then
			print "Fatal Error: Corrupt database, equipment {equipment_id} for recipe {id} not found"
			abort
		end
		var yeast = ctx.yeast_by_id(yeast_id)
		if yeast == null then
			print "Fatal Error: Corrupt database, yeast {yeast_id} for recipe {id} not found"
			abort
		end
		var ret = new Recipe(name, target_vol, mash_temp, mash_time, equipment, yeast)
		var mvol = map["measured_volume"]
		if mvol != null then ret.measured_volume = new Liter(mvol.as(Float))
		var mgrav = map["measured_gravity"]
		if mvol != null then ret.measured_gravity = new SG(mgrav.as(Float))
		var fgrav = map["final_gravity"]
		if fgrav != null then ret.final_gravity = new SG(mgrav.as(Float))
		ret.id = id
		ret.set_context(ctx)
		ret.fetch_profiles
		return ret
	end
end

redef class Statement
	# Deserialize several fermentables from a database select
	fun to_fermentables(ctx: DBContext): Array[Fermentable] do
		var work = once new FermentableWorker
		return work.fetch_multiple_from_statement(ctx, self)
	end

	# Deserialize several yeasts from a database select
	fun to_yeasts(ctx: DBContext): Array[Yeast] do
		var work = once new YeastWorker
		return work.fetch_multiple_from_statement(ctx, self)
	end

	# Deserialize several equipments from a database select
	fun to_equipments(ctx: DBContext): Array[Equipment] do
		var work = once new EquipmentWorker
		return work.fetch_multiple_from_statement(ctx, self)
	end

	# Deserialize several hops from a database select
	fun to_hops(ctx: DBContext): Array[Hop] do
		var work = once new HopWorker
		return work.fetch_multiple_from_statement(ctx, self)
	end

	# Deserialize several recipes from a database select
	fun to_recipes(ctx: DBContext): Array[Recipe] do
		var work = once new RecipeWorker
		return work.fetch_multiple_from_statement(ctx, self)
	end
end

redef class Fermentable
	# Build a fermentable with database information
	new from_db(ctx: DBContext, id: Int, name: String, gravity: Gravity, colour: Colour, f_type: Int) do
		var ret: nullable Fermentable = null
		if f_type == 1 then
			ret = new Grain(name, gravity, colour)
		else if f_type == 2 then
			ret = new Adjunct(name, gravity, colour)
		else if f_type == 3 then
			ret = new Sugar(name, gravity, colour)
		else if f_type == 4 then
			ret = new Extract(name, gravity, colour)
		end
		# If a new Fermentable is added,
		# it must be implemented here to be used
		if ret == null then abort
		ret.id = id
		ret.set_context(ctx)
		return ret
	end
end

redef class Yeast
	# Update aliases from database
	fun fetch_aliases do
		var ctx = context
		if ctx == null then return
		var db = ctx.connection
		var query = "name FROM yeast_aliases WHERE yeast_id = {id}"
		var ret = db.select(query)
		if ret == null then
			ctx.log_sql_error(self, query)
			return
		end
		for i in ret do
			var m = i.map
			if not m.has_key("name") then continue
			var alias = m["name"].as(String)
			if aliases.has(alias) then continue
			aliases.add alias
		end
	end
end

redef class Recipe
	# Fetch profiles
	fun fetch_profiles do
		var ctx = context
		if ctx == null then return
		hops.clear
		var hop_profiles = ctx.hop_profile_worker.fetch_multiple(ctx, "* FROM hop_profiles WHERE recipe_id = {id}")
		hops.add_all hop_profiles
		var fermentables = ctx.fermentable_profile_worker.fetch_multiple(ctx, "* FROM fermentable_profiles WHERE id = {id}")
		malts.clear
		malts.add_all fermentables
	end
end
