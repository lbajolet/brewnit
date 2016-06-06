import recipe
import html_gen

var dipa = new Recipe("1/4 Century DIPA", new Liter(22.0), new Celsius(67.0))
var eq = new Equipment("Home", .7, new Liter(30.0))

dipa.equipment = eq

var pm = new FermentableProfile(new Grain("2-Row", new SG(1.038), new EBC(3.9)), new Gram(6000.0))
var cp = new FermentableProfile(new Grain("Cara-pils", new SG(1.033), new EBC(3.9)), new Gram(500.0))
var crystal = new FermentableProfile(new Grain("Crystal 40", new SG(1.034), new EBC(78.8)), new Gram(500.0))
var cs = new FermentableProfile(new Sugar("Corn syrup", new SG(1.037), new EBC(2.0)), new Gram(350.0))

var profiles = [pm,cp,crystal,cs]

dipa.malts.add_all(profiles)

var columbus = new Leaf("Columbus", 17.2)
var centennial = new Leaf("Centennial", 9.6)
var simcoe = new Leaf("Simcoe", 15.4)

var boil60_cmb = new Boil(columbus, new Gram(22.0), new Minute(60.0))
var boil45_cmb = new Boil(columbus, new Gram(15.0), new Minute(45.0))
var boil30_sim = new Boil(simcoe, new Gram(30.0), new Minute(30.0))
var boil0_sim = new Boil(simcoe, new Gram(70.0), new Minute(0.0))
var boil0_cen = new Boil(centennial, new Gram(30.0), new Minute(0.0))

var dh_cen14 = new DryHop(centennial, new Gram(30.0), new Day(14.0))
var dh_col14 = new DryHop(columbus, new Gram(30.0), new Day(14.0))
var dh_sim14 = new DryHop(simcoe, new Gram(30.0), new Day(14.0))

var dh_cen7 = new DryHop(centennial, new Gram(7.0), new Day(7.0))
var dh_col7 = new DryHop(columbus, new Gram(7.0), new Day(7.0))
var dh_sim7 = new DryHop(simcoe, new Gram(7.0), new Day(7.0))

var boil_hps = [boil60_cmb, boil45_cmb, boil30_sim, boil0_sim, boil0_cen]
var dh_hps = [dh_cen14, dh_col14, dh_sim14, dh_cen7, dh_col7, dh_sim7]

dipa.hops.add_all(boil_hps)
dipa.hops.add_all(dh_hps)

var y = new Yeast("US-05", "Safale", ["American Ale Yeast"], 0, 0.78)
dipa.yeast = y

dipa.measured_gravity = new SG(1.072)
dipa.measured_volume = new Liter(19.70)
dipa.final_gravity = new SG(1.016)

print "Recipe stats :"
print ""
print "Batch size = {dipa.target_volume.to_l} L"
print "Estimated OG = {dipa.estimated_og.to_sg} SG"
print "Estimated FG = {dipa.estimated_fg.to_sg} SG"
print "Mash water = {dipa.mash_water.to_l} L"
print "Estimated grain absorption = {dipa.grain_loss.to_l} L"
print "Sparge water = {dipa.sparge_water.to_l} L"
print "Runoff volume = {dipa.runoff_volume.to_l} L"
print "Boil loss = {dipa.boil_loss.to_l} L"
print "Hop absorption = {dipa.hop_loss.to_l} L"
print "Estimated IBU = {dipa.ibu}"
print "Estimated Colour = {dipa.colour.to_ebc} EBC"
print "Efficiency = {dipa.efficiency}%"
print "Estimated ABV = {dipa.estimated_abv} %"
print "Effective ABV = {dipa.effective_abv} %"

dipa.write_to_file "DIPA.html"
