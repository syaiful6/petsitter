STATICPATH = public/assets
RESOURCEPATH = resources/static
bin        = $(shell npm bin)
browserify = $(bin)/browserify

.PHONY: run compile-static cs-fix test check debug-mail

run:
	php -S 0.0.0.0:8080 -t public/ public/index.php

compile-static:
	mkdir -p $(STATICPATH)/js
	$(browserify) --extension='.coffee' $(RESOURCEPATH)/coffee/main.coffee -t coffeeify --outfile $(STATICPATH)/js/main.js

clean:
	rm -rf $(STATICPATH)

compile-static-specs:
	mkdir -p $(STATICPATH)/js
	$(browserify) --extension='.coffee' $(RESOURCEPATH)/coffee/specs/main.coffee -t coffeeify --outfile $(STATICPATH)/js/specs.js

cs-fix:
	vendor/bin/phpcbf

cs-info:
	vendor/bin/phpcs

test:
	vendor/bin/phpunit

check: cs-info test

debug-mail:
	python -m smtpd -n -c DebuggingServer localhost:1025
