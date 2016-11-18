# All API calls related to management of recipes
module api_recipes

import api_compounds
import model

redef class APIRouter
	redef init do
		use("/recipes", new RecipeList)
	end
end

# Lists all recipes
class RecipeList
	super APIHandler

	redef fun get(req, res) do
		var ctx = req.ctx
		var ret = ctx.recipe_worker.fetch_multiple(ctx, "* FROM recipes")
		res.json new JsonArray.from(ret)
	end
end
