Brewnit
=======

#### *Bringing open-source to brewing*

Brewnit is a software to help you plan your brewing recipes.

It will compute a few things for you. Things like :

 * The estimated original gravity of your beer
 * The estimated final gravity
 * Estimated ABV
 * The water needed for each step of the brewing process
 * Estimated colour of your beer

The software comes with a small language to describe the components involved in the creation of your recipe.

The grammar is available and compilable using [nitcc](https://github.com/privat/nit/tree/master/contrib/nitcc).

The software itself is compilable using the Nit language's compiler, also available [here](https://github.com/privat/nit)

# How to use

To start creating your recipes with Brewnit, you'll need to create a pristine `.beer` file.

Several sections are part of the `.beer` format specification

## RECIPE

The basic informations on the recipe, that is its name, the temperature of the mash and the volume of final product you aim for.

The name of the recipe is to be entered as a quoted string alongside the `RECIPE` keyword.

The other information is entered as a key-value format: `keyword ':'? number unit`

The unit type will depend on the information you enter, for now several units are supported.

## EQUIPMENT

As with the recipe, the equipment has its name entered alongside the recipe.

After that, you will need to enter informations like the efficiency of your equipment and the volume of your mash tun.

## FERMENTABLES

Unlike equipment and recipe, this section is used to list all your fermentable ingredients.

Note that although all the ingredients you might enter here will not necessarily be fermentables, anything that is not a hop is listed in this section.

Brewnit can list ingredients in different categories which will have an impact on the final calculations of your recipe.

Each fermentable ingredient will require you to enter several informations that are necessary to compute the information about the recipe:

* The name of the ingredient is to be specified as a quoted string alongside the type of ingredient.
* `Potential`: The potential of a fermentable ingredient is the potential fermentable sugar yield of the ingredient. You can express it with any gravity unit.
* `Colour`: The colour, expressed in either SRM or EBC is the color potential of the ingredient you add.
* `Quantity`: Potential and colour are meaningless if you do not enter the quantity of the ingredient added in your recipe. It can also be expressed in any weight unit.

### GRAIN

A grain is used in partial and full-grain brewing.

Its use as steeping material in extract brewing however is not supported yet, as all ingredients are supposed to be added at mashing time (this will be subject to modification later).

It is expected of the user to know its grain, therefore all the information about colour and potential will have to be entered manually.

### EXTRACT

Much like grain, extract is added to enhance the original gravity of the beer you're brewing, since it does not require mashing, it can be added at boiling or steeping time.

Much like the grain, the colour and potential of your extract will need to be entered manually.

Although, as a rule of thumb, it can be expected of LME to have a potential of 1.036 SG and of DME to have a potential of 1.040 SG, regardless of its colour.

### ADJUNCT

The adjunct category is used as a way to declare extra ingredients such as spices, herbs or fruits.

As these are (supposedly) mainly aromatic and add little to no gravity, you should enter 1.000 SG to its potential.

As for the colour, depending on the adjunct it might have an impact which could be useful to provide should you have the information.
If you lack this information, you might enter 0 SRM as colour value for it to have no impact on the calculations.

### SUGAR

Any source of extra sugar besides your Extract and Grain should be added in this category.

Sugars typically have a very high extract rate and should be used scarcely in your recipes as they bring little to no yeast nutrients, unlike extract and grain.

Typical examples of these are corn syrup, maple syrup, honey, agave, etc.

## HOPS

Hops are a stape of beer nowadays, though some brewers can do without it (gruit for example is still made with a herb mix).

Gruit brewing is not yet supported by Brewnit since no one has ever expressed the need for it.

For hops, a similar layout as for fermentables is expected.

First specify each hop using the HOP keyword followed by its name.

Then enter the following informations:

* `alpha`: The alpha-acid percentage of the hop
* `quantity`: How much hop to add
* `time`: How long will this hop be added in the wort
* `type`: Is your hop in Leaf, Pellet or Plug form ? (this will have an impact on the total absorption of wort)
* `use`: How do you use this hop ? DryHop or Boil. (DryHop additions have no impact on the bitterness of your beer but will impact its hoppy taste)

## YEAST

The final ingredient of your beer, yeast.

As it is necessary for your newly brewed wort to convert to beer you can drink and enjoy, it has a huge impact on the flavours of your beer.

All yeasts are different and have different properties.

Aromatic properties of the yeast are left to the discretion of the brewer and have no effect on the math.

The attenuation of the yeast is however a significant information to provide since it is necessary to compute the estimated FG and ABV of the beer.

The information about your yeast should be entered in the following format

~~~
YEAST "name"
	attenuation: n (in percent)
	flocculation: Low/Medium/High
~~~

# Client

To transform the .beer file to a .html file readable by your internet browser, a client is available in the src/ directory.

To compile it, you will need the nit compiler: `nitc`.

The command should be something along the lines of `nitc src/cli.nit`.

An executable program will be generated that you can use to process a .beer file.

To use it use a command like `./cli yourbeer.beer`.

A `Recipe.html` file will be generated where the command was used that will contain the information about your beer and a basic set of rules to use on the brew day.
