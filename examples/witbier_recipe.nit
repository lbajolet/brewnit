import recipe
import html_gen

var wit = new Recipe("MTL Wit", new Liter(22.0), new Celsius(65.67))
var eq = new Equipment("Home", .70, new Liter(30.0))

wit.equipment = eq

var wt = new FermentableProfile(new Grain("White Wheat Unmalted", new SG(1.036), new SRM(2.0)), new Gram(450.0))
var pm = new FermentableProfile(new Grain("2-Row", new SG(1.038), new EBC(3.9)), new Gram(2250.0))
var rh = new FermentableProfile(new Adjunct("Rice Hulls", new SG(1.000), new EBC(0.0)), new Gram(250.0))
var wf = new FermentableProfile(new Grain("Flaked Wheat", new SG(1.035), new SRM(1.6)), new Gram(1750.0))
var of = new FermentableProfile(new Grain("Flaked Oats", new SG(1.037), new SRM(1.0)), new Gram(250.0))

wit.malts.add_all([wt, pm, rh, wf, of])

print "Grain profiles :"
print ""
for i in wit.malts do print "{i.fermentable.name} produces {i.gu} GU"
print ""

var ekg = new Leaf("East Kent Golding", 5.0)

var boil60_ekg = new Boil(ekg, new Ounce(1.0), new Hour(1.0))

wit.hops.add(boil60_ekg)

wit.measured_gravity = new SG(1.048)
wit.measured_volume = new Liter(19.70)

wit.yeast = new Yeast("White Labs", "WLP-400", ["Wit ale yeast"], 1,.65)

print "Recipe stats :"
print ""
print "Batch size = {wit.target_volume.to_l} L"
print "Estimated OG = {wit.estimated_og.to_sg} SG"
print "Mash water = {wit.mash_water.to_l} L"
print "Estimated grain absorption = {wit.grain_loss.to_l} L"
print "Sparge water = {wit.sparge_water.to_l} L"
print "Runoff volume = {wit.runoff_volume.to_l} L"
print "Boil loss = {wit.boil_loss.to_l} L"
print "Hop absorption = {wit.hop_loss.to_l} L"
print "Estimated boil gravity = {wit.estimated_boil_gravity.to_sg} SG"
print "Estimated IBU = {wit.ibu}"
print "Estimated colour = {wit.colour.to_ebc} EBC"
print "Efficiency = {wit.efficiency}%"
print "Estimated FG = {wit.estimated_fg.to_sg} SG"
print "Estimated ABV = {wit.estimated_abv} %"

var out = new OFStream.open("MTL Wit.html")

wit.write_to out
