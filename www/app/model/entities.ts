export class Hop {
	id: number
	name: string
}

export class Fermentable {
	id: number
	name: string
	potential: Unit
	colour: Unit
}

export class Unit {
	unit: string
	value: number
}

export class Yeast {
	id: number
	brand: string
	name: string
	aliases: string[]
	attenuation: number

	attenuation_percentage: number = this.attenuation * 100;
}
