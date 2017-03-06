.PHONY: clean, tests

all: cli

cli: parser bin
	nitc src/cli.nit -o bin/cli

bin:
	mkdir -p bin

parser:
	cd src/parser && $(MAKE)

clean:
	-rm -rf bin
	cd src/parser && $(MAKE) clean

reset_db:
	-rm brewnit
	sqlite3 brewnit < db_scripts/init.sql

tests:
	cd tests && $(MAKE) clean
	cd tests && $(MAKE)
