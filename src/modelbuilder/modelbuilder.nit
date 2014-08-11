import literal
import unit_build
import equipment_builder
import fermentables_visitor
import hop_builder
import yeast_builder
import recipe_builder
import parser

class Modelbuilder

	var recipe: Recipe

	init(src: String)
	do
		var p = new Parser_beer(src)
		var n = p.parse_file
		(new LiteralVisitor).enter_visit(n)
		(new UnitVisitor).enter_visit(n)
		(new FermentablesVisitor).enter_visit(n)
		(new HopVisitor).enter_visit(n)
		(new EquipmentVisitor).enter_visit(n)
		(new YeastVisitor).enter_visit(n)
		(new RecipeVisitor).enter_visit(n)
		var f = new RecipeFinalizer
		f.enter_visit(n)
		recipe = f.recipe
	end

end

class RecipeFinalizer
	super Visitor

	var recipe: Recipe

	init do end

	redef fun visit(n) do n.accept_finalizer(self)

end

redef class Node

	fun accept_finalizer(v: RecipeFinalizer) do visit_children(v)
end

redef class Nprog

	redef fun accept_finalizer(v) do
		var recipe = n_recipe.recipe
		recipe.equipment = n_equipment.eq
		recipe.malts.add_all n_fermentables.ferms
		recipe.hops.add_all n_hops.hops
		recipe.yeast = n_yeast.yeast
		v.recipe = recipe
	end
end
