pattern = /\/\/ BEGIN\(BROWSER\)/,/\/\/ END\(BROWSER\)/
begin = /\/\/ BEGIN(BROWSER)/d
end = /\/\/ END(BROWSER)/d
modulePath = ./node_modules/.bin

build: src/base.js src/ast.js src/parser.js
	@echo 'Concatenating scripts...'
	@awk '$(pattern)' src/base.js > /tmp/strudel.js
	@awk '$(pattern)' src/ast.js >> /tmp/strudel.js
	@awk '$(pattern)' src/parser.js >> /tmp/strudel_parser.js
	@sed '$(begin)' /tmp/strudel.js | sed '$(end)' > build/strudel.js
	@sed '$(begin)' /tmp/strudel_parser.js | sed '$(end)' > build/strudel_parser.js
	@echo 'Minifying script...'
	@$(modulePath)/uglifyjs build/strudel.js > build/strudel.min.js
	@$(modulePath)/uglifyjs build/strudel_parser.js > build/strudel_parser.min.js
	@echo 'Build succeeded'

src/parser.js: src/grammar/strudel.pegjs
	@echo 'Generating parser...'
	@$(modulePath)/pegjs -e 'Strudel.Parser' src/grammar/strudel.pegjs src/parser.js
	@echo "var Strudel = require('./base');\n\n// BEGIN(BROWSER)" > /tmp/parser.js
	@unexpand -t 2 src/parser.js >> /tmp/parser.js
	@echo '\n// END(BROWSER)' >> /tmp/parser.js
	@mv /tmp/parser.js src/parser.js
	@echo 'Parser generation succeeded'

parser: src/parser.js
	@:

test: src/base.js src/ast.js src/parser.js test/tests.js
	@$(modulePath)/mocha -u bdd -R list -C test/tests.js

clean:
	@rm -f build/* src/parser.js

.PHONY: parser test clean
