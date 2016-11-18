# Compounds-related queries
module api_compounds

import api_base

redef class APIRouter
	redef init do
		super
		use("/hops", new HopList)
		use("/hops/:id", new HopDetail)
		use("/fermentables", new FermentableList)
		use("/fermentables/:id", new FermentableDetail)
		use("/yeasts", new YeastList)
		use("/yeasts/:id", new YeastDetail)
		use("/equipments", new EquipmentList)
		use("/equipments/:id", new EquipmentDetail)
	end
end

# Lists all known hops from database
class HopList
	super APIHandler

	redef fun get(req, res) do
		var ctx = req.ctx
		var hops = ctx.hop_worker.fetch_multiple(ctx, "* FROM hops")
		res.json new JsonArray.from(hops)
	end
end

# Gets at most one hop via its ID
class HopDetail
	super IDHandler

	redef fun get(req, res) do
		var ctx = req.ctx
		var id = id(req, res)
		if id == null then return
		var hop = ctx.hop_worker.fetch_one(ctx, "* FROM hops WHERE id = {id}")
		res.json hop
	end
end

# Lists all known fermentables from database
class FermentableList
	super APIHandler

	redef fun get(req, res) do
		var ctx = req.ctx
		var malts = ctx.fermentable_worker.fetch_multiple(ctx, "* FROM fermentables")
		res.json new JsonArray.from(malts)
	end
end

# Gets at most one fermentable via its ID
class FermentableDetail
	super IDHandler

	redef fun get(req, res) do
		var ctx = req.ctx
		var id = id(req, res)
		if id == null then return
		var ferm = ctx.fermentable_worker.fetch_one(ctx, "* FROM fermentables WHERE id = {id}")
		res.json ferm
	end
end

# Lists all yeasts from Database
class YeastList
	super APIHandler

	redef fun get(req, res) do
		var ctx = req.ctx
		var ret = ctx.yeast_worker.fetch_multiple(ctx, "* FROM yeasts")
		res.json new JsonArray.from(ret)
	end
end

# Gets at most one yeast via its ID
class YeastDetail
	super IDHandler

	redef fun get(req, res) do
		var ctx = req.ctx
		var id = id(req, res)
		if id == null then return
		var ferm = ctx.yeast_worker.fetch_one(ctx, "* FROM yeasts WHERE id = {id}")
		res.json ferm
	end
end

# Lists all equipments from Database
class EquipmentList
	super APIHandler

	redef fun get(req, res) do
		var ctx = req.ctx
		var ret = ctx.equipment_worker.fetch_multiple(ctx, "* FROM equipments")
		res.json new JsonArray.from(ret)
	end
end

# Gets at most one fermentable via its ID
class EquipmentDetail
	super IDHandler

	redef fun get(req, res) do
		var ctx = req.ctx
		var id = id(req, res)
		if id == null then return
		var ferm = ctx.equipment_worker.fetch_one(ctx, "* FROM equipments WHERE id = {id}")
		res.json ferm
	end
end
