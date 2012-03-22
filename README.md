Client for embedding InterMine widgets (ws_widgets).

## Requirements:
### To Run:
- Google API (included)
- jQuery (included)
- underscore.js (included)
- backbone.js (included)

1. Open the `index.html`, and modify where the widgets webservice exists (line #63).
2. Start a simple HTTP server using `.webserver.sh`.
3. Visit `http://0.0.0.0:1111/`

### To Compile/Test:
- CoffeeScript & [eco](https://github.com/sstephenson/eco) templating
- [uglify-js](https://github.com/mishoo/UglifyJS) to compress templates

## Compile:
1. Install dependencies `npm install -d`.
2. Run `cake compile:main` to compile widgets and templates into one target. Check optional parameters by running `cake`.

## Test:
1. Run `cake compile:tests` to compile the test spec.
2. Start a simple HTTP server using `.webserver.sh`.
3. Visit `http://0.0.0.0:1111/tests/` that automatically runs [Jasmine](http://pivotal.github.com/jasmine/) tests.

## Use:
1. Create a new Widgets instance pointing to a service: `widgets = new Widgets("http://aragorn.flymine.org:8080/flymine/service/");`
2. Follow below...

### Load all Widgets:
`widgets.all('Gene', 'myList', '#all-widgets');`
### Load a specific Chart Widget:
`widgets.chart('flyfish', 'myList', '#widget-1');`
### Load a specific Enrichment Widget:
`widgets.enrichment('pathway_enrichment', 'myList', '#widget-2');`

## Example:
![image](https://raw.github.com/radekstepan/intermine-widget-client/master/example.png)