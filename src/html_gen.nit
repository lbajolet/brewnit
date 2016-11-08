import model
import template

redef class Recipe
	super Template

	redef fun rendering do
		add """<!DOCTYPE html>
		<html>
			<title> {{{name}}} </title>
		<body>
			<h1>{{{name}}}</h1>
			<h3>Volume : {{{target_volume}}}
			<h3>Mash Temperature : {{{target_mash_temp}}}</h3>
			<div id = "Stats">
				Estimated OG : {{{estimated_og}}}<br/>
				Estimated FG : {{{estimated_fg}}}<br/>
				Estimated ABV : {{{estimated_abv}}} %<br/>
				Mash Water : {{{mash_water}}}<br/>
				Estimated grain absorption = {{{grain_loss}}} <br/>
				Sparge water = {{{sparge_water}}}<br/>
				Runoff volume = {{{runoff_volume}}}<br/>
				Estimated boil gravity = {{{estimated_boil_gravity}}}<br/>
				Bitterness = {{{ibu}}} IBU <br/>
				Estimated colour = {{{colour}}} <br/>
			</div>"""
			add """<div id = "Yeast"><h2>Yeast</h2>"""
			add yeast
			add "</div>"
			add """<div id = "Fermentables">
				<h2>Fermentables</h2>
				<table>
					<th>
						<td>Potential</td>
						<td>Colour</td>
						<td>Quantity</td>
						<td>GU Potential</td>
					</th>"""
		for i in malts do add i
		add """		</table>
			</div>
			<div id = "Hops">
				<h2>Hops</h2>
				<table>
					<th>
						<td> AA% </td>
						<td> Time </td>
						<td> Quantity </td>
						<td> Use </td>
					</th>"""
		for i in hops do add i
		add """		</table>
			</div>
			<div id = "Directions">
				<h2>Brewing Directions</h2>
				<h4>Mash</h4>
Prepare {{{mash_water}}} of water in your mash tun, and heat it to {{{target_mash_temp.value + 4.0}}}.<br/>
Mash the grain at a temperature of {{{target_mash_temp}}} for 60 minutes.<br/>
				<h4>Sparging</h4>
Once the grain is mashed, sparge the grain in two batches of {{{sparge_water.value / 2.0}}}.<br/>
Don't forget the Vorloff (re-transfer of the wort) step to get rid of particles in the wort !<br/>
				<h4>Boil</h4>
Bring to a boil the wort after sparging, at the beginning of the boil step, the volume should be {{{runoff_volume}}}.<br/>
After that, add :<br/>
<ul>"""

		for i in hops do
			if i.use == boil then
				add """<li> {{{i.quantity}}} of {{{i.name}}} {{{i.time}}} before the end of the boil.</li>"""
			end
		end
		add """</ul>
				<h4>Fermentation</h4>
Chill the wort and place in the fermenter.<br/>
Add the Yeast and leave to ferment."""

		var dh = false
		for i in hops do
			if i.use == dry_hop then
				dh = true
				break
			end
		end

		if dh then
			add """<h4>Dry Hopping</h4>
			Add :<br/><ul>"""
			for i in hops do
				if i.use == dry_hop then
					add  """<li> {{{i.quantity}}} of {{{i.name}}} {{{i.time}}} before end of fermentation.</li>"""
				end
			end
			add "</ul>"
		end

		add """</body>
<footer> This file was generated by Brewnit </footer>
</html>"""
	end
end

redef class Yeast
	super Template

	redef fun rendering do add "Yeast : {brand} {name}<br/>Attenuation : {attenuation}<br/>"
end

redef class FermentableProfile
	super Template

	redef fun rendering do
		add "<tr>"
		add fermentable
		add "<td>{quantity}</td>"
		add "<td>{gu}</td>"
		add "</tr>"
	end

end

redef class Fermentable
	super Template

	redef fun rendering do
		add """<td>{{{name}}}</td><td>{{{potential}}}</td><td>{{{colour}}}</td>"""
	end
end

redef class Hop
	super Template

	redef fun rendering do
		add "<tr>"
		add """<td>{{{name}}}</td><td>{{{alpha_acid}}} %</td>"""
		add "<td>{time}</td><td>{quantity}</td><td>{class_name}</td>"
		add "</tr>"
	end
end
