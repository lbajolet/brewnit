all: cli cli_db
	nitserial src/app.nit -o src/app_serial.nit
	nitc src/app.nit -m app_serial -o bin/brewnit_server

cli: parser bin
	nitc src/cli.nit -o bin/cli

cli_db: parser bin
	nitc src/cli_db.nit -o bin/cli_db

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
