Client for embedding InterMine widgets (ws_widgets).

## Requirements:
### To Run:

- Google API (included)
- jQuery (included)
- underscore.js (included)
- backbone.js (included)

### To Compile/Test:
- CoffeeScript & [eco](https://github.com/sstephenson/eco) templating
- [uglify-js](https://github.com/mishoo/UglifyJS) to compress templates

## Configure:
1. Create a new Widgets instance pointing to a service: `widgets = new Widgets("http://aragorn.flymine.org:8080/flymine/service/");` in `index.html`.

2. Choose which widgets you want to load:
```javascript
widgets.all('Gene', 'myList', '#all-widgets'); // load all Widgets
widgets.chart('flyfish', 'myList', '#widget-1'); // load a specific Chart Widget
widgets.enrichment('pathway_enrichment', 'myList', '#widget-2'); // load a specific Enrichment Widget
```
## Use:
2. Start a simple HTTP server using `.webserver.sh`.
3. Visit `http://0.0.0.0:1111/`

## Compile:
1. Install dependencies `npm install -d`.
2. Run `cake compile:main` to compile widgets and templates into one target. Check optional parameters by running `cake`.

## Test:
1. Run `cake compile:tests` to compile the test spec.
2. Start a simple HTTP server using `.webserver.sh`.
3. Visit `http://0.0.0.0:1111/tests/` that automatically runs [Jasmine](http://pivotal.github.com/jasmine/) tests.

## Example:
![image](https://raw.github.com/radekstepan/intermine-widget-client/master/example.png)