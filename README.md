Client for embedding InterMine widgets (ws_widgets).

## Requirements:
### To Run:
- Google API (included)
- jQuery (included)
- underscore.js (included)

### To Compile/Test:
- CoffeeScript & [eco](https://github.com/sstephenson/eco) templating
- [uglify-js](https://github.com/mishoo/UglifyJS) to compress templates

1. Install dependencies `npm install -d`
2. Run `./compile.sh` to compile widgets and templates into one target.
3. Run `cake compile:tests` to compile the test spec.

## Usage:
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