import modelbuilder
import html_gen

var m = new Modelbuilder(args[0])

var os = new FileWriter.open("Recipe.html")
m.recipe.write_to(os)

