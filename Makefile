.PHONY: clean, tests

all: cli server

cli: parser bin
	nitc src/cli.nit -o bin/cli

server: parser bin
	nitserial src/app.nit -o src/app_serial.nit
	nitc src/app.nit -m src/app_serial.nit -o bin/brewnit_server

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
