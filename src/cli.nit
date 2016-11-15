import modelbuilder
import html_gen

fun usage do
	print "Usage: ./cli file"
end

if args.length < 1 then
	usage
	exit 1
end

var fl = args[0]

if not fl.has_suffix("beer") then
	print "Unsupported file format, require `.beer` file."
	exit 3
end

if not fl.file_exists then
	print "File `{fl}` not found."
	exit 4
end

var m = build_recipe_from_beer(fl)

if m == null then exit 2
var rm = m.as(not null)

var os = new FileWriter.open("Recipe.html")
rm.write_to(os)

with ctx = new DBContext do
	rm.context = ctx
	rm.commit
end
