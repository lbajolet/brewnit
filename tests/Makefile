all: reset_db
	mkdir -p bin
	mkdir -p out
	mkdir -p sav
	nitc ../src/cli.nit -m dummy_db.nit -o bin/cli
	./tests.sh

reset_db:
	-rm dummy_brewnit 2> /dev/null
	sqlite3 dummy_brewnit < ../db_scripts/init.sql

clean:
	-rm -rf bin
	-rm dummy_brewnit
	-rm -rf out
	-rm Recipe.html
