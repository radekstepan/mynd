#!/bin/sh

rm js/widgets.js

# templates
find src/templates -type f \( -iname '*.eco' \) -exec eco {} --print --identifier "JST" \; | uglifyjs >> js/widgets.js
echo "\n" >> js/widgets.js

# main
cat src/widgets.coffee | coffee --compile --stdio >> js/widgets.js

# tests
coffee --compile test/spec.coffee