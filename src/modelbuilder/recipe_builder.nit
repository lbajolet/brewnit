import literal
import unit_build
import model
import console

class RecipeVisitor
	super Visitor

	var errors = new Array[String]

	redef fun visit(n) do
		n.accept_recipe_visitor(self)
		for i in errors do print i.red
	end
end

redef class Node

	fun accept_recipe_visitor(v: RecipeVisitor) do visit_children(v)

end


redef class Nrecipe

	var recipe: Recipe

	redef fun accept_recipe_visitor(v) do
		var vol: nullable Volume = null
		var tmp: nullable Temperature = null
		for i in n_recipe_body.children do
			if i isa Nrecipe_body_volume then
				vol = i.volume
			else if i isa Nrecipe_body_mash_temp then
				tmp = i.mash_temp
			end
		end
		var err = false
		if vol == null then
			err = true
			v.errors.push "Error: Missing volume information at {position.as(not null)}"
			return
		end
		if tmp == null then
			err = true
			v.errors.push "Error: Missing mash temperature information at {position.as(not null)}"
			return
		end
		recipe = new Recipe(n_string.value, vol, tmp)
	end

end

redef class Nrecipe_body_volume
	fun volume: Volume do return n_volunit.val
end

redef class Nrecipe_body_mash_temp
	fun mash_temp: Temperature do return n_tmpunit.val
end

