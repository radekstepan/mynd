Client for embedding InterMine widgets (ws_widgets branch only!).

## Requirements:
### To Run:

- [InterMine JavaScript API Loader](http://cdn.intermine.org/api)

The following will be fetched automatically:

- jQuery
- underscore.js
- backbone.js
- InterMine imjs

### To Compile:

You can install all of the following dependencies by running:

```bash
sudo npm install -g coffee-script
npm install -d
```

- [CoffeeScript](http://coffeescript.org/) 1.3.1+ & [eco](https://github.com/sstephenson/eco) templating.
- [uglify-js](https://github.com/mishoo/UglifyJS) to compress templates.

## Configure:

You can either use the InterMine API Loader to always give you the latest version of the widgets:

```html
<script src="http://cdn.intermine.org/api"></script>
```

```javascript
intermine.load('widgets', function() {
    var Widgets = new intermine.widgets('http://flymine.org/service');
});
```

Or you can include both the API Loader and Widgets JS files and use them immediately:

```html
// point to API, requirement for all InterMine client side JavaScript
<script src="http://cdn.intermine.org/api"></script>
// include Widgets library locally, is immediately available on the `intermine` namespace
<script src="js/intermine.widgets.js"></script>
```

```javascript
var Widgets = new intermine.widgets('http://flymine.org/service');
```

Then, **choose which widgets** you want to load:

```javascript
// Load all Widgets:
Widgets.all('Gene', 'myList', '#all-widgets');
// Load a specific Chart Widget:
Widgets.chart('flyfish', 'myList', '#widget-1');
// Load a specific Enrichment Widget:
Widgets.enrichment('pathway_enrichment', 'myList', '#widget-2');
// Load a specific Table Widget:
Widgets.table('interactions', 'myList', '#widget-3');
```

## Use:
1. Start a simple HTTP server using `.webserver.sh`.
2. Visit [http://0.0.0.0:1111/](http://0.0.0.0:1111/)

## Compile:

Run `cake compile:main` to compile widgets and templates into one target. Check optional parameters by running `cake`.

## Test:

1. Run `cake compile:tests` to compile tests.
2. Visit [http://0.0.0.0:1111/test](http://0.0.0.0:1111/test) to run the tests using [Mocha](http://visionmedia.github.com/mocha/) and [Chai](http://chaijs.com/).

The tests are automatically loaded from available tests in the `test/src` directory. Libraries needed to run the tests are loaded automatically too. You can speed up their execution by including the files the `<head>` section of the `test/index.html` file.

## Release to InterMine:

**Configure** the `Cakefile` with paths to your own InterMine SVN:

```coffeescript
# Path to InterMine SVN output.
INTERMINE =
    ROOT: "/home/rs676/svn/ws_widgets"
    OUTPUT: "intermine/webapp/main/resources/webapp/js/widget.js"
```

### With Commit

**Execute** the release task by running `cake --commit "message" release`; this will commit the `widget.js` file with your custom message.

## Example:
![image](https://raw.github.com/radekstepan/intermine-widget-client/master/example.png)

## Q&A:

### Where is documentation?

Commented source code is in the `/docs` directory: [http://0.0.0.0:1111/docs/widgets.html](http://0.0.0.0:1111/docs/widgets.html).

### How do apply a CSS style to the widgets?

Use or modify a [Twitter Bootstrap](http://twitter.github.com/bootstrap/) [theme](http://bootswatch.com/).

### I want to define a custom behavior when clicking on an Enrichment or Chart widget.

Clicking on an individual match (Gene, Protein etc.) in popover window:

```javascript
var options = {
    matchCb: function(id, type) {
        window.open(mineURL + "/portal.do?class=" + type + "&externalids=" + id);
    }
};
Widgets.enrichment('pathway_enrichment', 'myList', '#widget', options);
```

Clicking on View results button in a popover window:

```javascript
var options = {
    resultsCb: function(pq) {
        ...
    }
};
Widgets.enrichment('pathway_enrichment', 'myList', '#widget', options);
```

Clicking on Create list button in a popover window:

```javascript
var options = {
    listCb: function(pq) {
        ...
    }
};
Widgets.enrichment('pathway_enrichment', 'myList', '#widget', options);
```

### I want to hide the title or description of a widget.

```javascript
var options = {
    "title": false,
    "description": false
};
Widgets.enrichment('pathway_enrichment', 'myList', '#widget', options);
```

### I am clicking on Download after selecting a few Enrichment Widget rows and nothing happens.

Make sure you run widgets through the `http://` protocol instead of `file://`.

## Browser Support:

- Linux Chrome 16
- Linux Firefox 11
- Linux Opera 11.61*
- MacOS X Google Chrome 19
- MacOS X Firefox 4.0.1
- MacOS X Safari 5.0.6
- Windows 7 Chrome 18
- Windows 7 Firefox 11
- Windows 7 Firefox 4
- Windows 7 Firefox 2
- Windows 7 Firefox 3
- Windows 7 Opera 11.61
- Windows 7 Opera 9.64
- Windows 7 Safari 5.1.7
- Windows 7 Internet Explorer 8

Support of other browsers cannot be guaranteed.

### Known Issues:

1. Windows 7 **Internet Explorer 7** does not support `display:table-*` properties and thus faux table header is not inlined. (IE7 not supported)
1. Linux **Opera 11.61** Google Visualization sometimes trims horizontal axis label.