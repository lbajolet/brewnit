all:
	cd src/parser && $(MAKE)
	mkdir -p bin
	nitc src/app.nit -o bin/brewnit_server

clean:
	rm -rf bin
	cd src/parser && $(MAKE) clean
