Client for embedding InterMine widgets (ws_widgets).

## Requirements:
- Google API (included)
- jQuery (included)
- underscore.js (included)

### CoffeeScript:
Run `./compile.sh` to compile and watch the `widgets.coffee` file for changes.

## Usage:
1. Create a new Widgets instance pointing to a service: `widgets = new Widgets("http://aragorn.flymine.org:8080/flymine/service/");`
2. Request either a graph `widgets.graph('flyfish', 'myList', '#widget-1');` or enrichment `widgets.enrichment('pathway_enrichment', 'myList', '#widget-3');` widget.

## Example:
![image](https://raw.github.com/radekstepan/intermine-widget-client/master/example.png)