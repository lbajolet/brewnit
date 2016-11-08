# Any facilities to rebuild a valid model from a beer description file
module modelbuilder

import recipe_builder
import parser

# Build a recipe from a beer description file
fun build_recipe_from_beer(path: String): nullable Recipe do
	var n = parse_beer_file(path)
	if n == null then
		print "Error when parsing file {path}".red
		return null
	end
	if n isa NError then
		print n.to_s.red
		return null
	end
	(new LiteralVisitor).enter_visit(n)
	(new UnitVisitor).enter_visit(n)
	var rec = new RecipeVisitor
	rec.enter_visit(n)
	return rec.recipe
end
