import modelbuilder
import html_gen

fun usage do
	print "Usage: ./cli file"
end

if args.length < 1 then
	usage
	exit 1
end

var m = build_recipe_from_beer(args[0])

if m == null then exit 2

var os = new FileWriter.open("Recipe.html")
m.as(not null).write_to(os)

