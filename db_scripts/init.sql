CREATE TABLE IF NOT EXISTS hops(
	id		INTEGER PRIMARY KEY	AUTOINCREMENT,
	name		TEXT			UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS yeasts(
	id		INTEGER PRIMARY KEY	AUTOINCREMENT,
	brand		TEXT			DEFAULT '',
	name		TEXT			NOT NULL,
	attenuation	INTEGER			NOT NULL
);

CREATE TABLE IF NOT EXISTS yeast_aliases(
	yeast_id	INTEGER			NOT NULL,
	name		TEXT			NOT NULL,

	PRIMARY KEY(yeast_id, name),
	FOREIGN KEY(yeast_id) REFERENCES yeasts(id)
);

CREATE TABLE IF NOT EXISTS equipments(
	id		INTEGER PRIMARY KEY	AUTOINCREMENT,
	name		TEXT			NOT NULL,
	efficiency	FLOAT			NOT NULL,
	volume		FLOAT			NOT NULL,
	losses		FLOAT			NOT NULL,
	boil_loss	FLOAT			NOT NULL
);

CREATE TABLE IF NOT EXISTS fermentable_types(
	id		INTEGER PRIMARY KEY	AUTOINCREMENT,
	name		TEXT			UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS fermentables(
	id		INTEGER PRIMARY KEY	AUTOINCREMENT,
	name		TEXT			UNIQUE NOT NULL,
	potential	FLOAT			NOT NULL,
	colour		FLOAT			NOT NULL,
	ferm_type	INTEGER			NOT NULL
);

CREATE TABLE IF NOT EXISTS recipes(
	id			INTEGER PRIMARY KEY	AUTOINCREMENT,
	name			TEXT			NOT NULL,
	target_volume		FLOAT			NOT NULL,
	target_temperature	FLOAT			NOT NULL,
	mash_time		FLOAT			NOT NULL,
	equipment_id		INTEGER			NOT NULL,
	yeast_id		INTEGER			NOT NULL,
	measured_volume		FLOAT,
	measured_gravity	FLOAT,
	final_gravity		FLOAT,

	FOREIGN KEY(yeast_id) REFERENCES yeasts(id),
	FOREIGN KEY(equipment_id) REFERENCES equipments(id)
);

CREATE TABLE IF NOT EXISTS fermentable_profiles(
	id		INTEGER PRIMARY KEY	AUTOINCREMENT,
	fermentable_id	INTEGER			NOT NULL,
	recipe_id	INTEGER			NOT NULL,
	quantity	FLOAT			NOT NULL,

	FOREIGN KEY(fermentable_id) REFERENCES fermentables(id),
	FOREIGN KEY(recipe_id) REFERENCES recipes(id)
);

CREATE TABLE IF NOT EXISTS hop_profiles(
	id		INTEGER PRIMARY KEY	AUTOINCREMENT,
	hop_id		INTEGER			NOT NULL,
	recipe_id	INTEGER			NOT NULL,
	quantity	FLOAT			NOT NULL,
	time		FLOAT			NOT NULL,
	alpha_acid	FLOAT			NOT NULL,
	use		INTEGER			NOT NULL,

	FOREIGN KEY(recipe_id) REFERENCES recipes(id),
	FOREIGN KEY(hop_id) REFERENCES hops(id)
);

INSERT INTO fermentable_types(name) VALUES('Grain'), ('Adjunct'), ('Sugar'), ('Extract');
