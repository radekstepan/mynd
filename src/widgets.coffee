### Interface to InterMine Widgets.###

# For our purposes, `$` means jQuery or Zepto.
$ = window.jQuery or window.Zepto

# Public interface for the various InterMine Widgets.
class Widgets

    VERSION: '1.1.4'

    wait:    true

    # JavaScript libraries as resources. Will be loaded if not present already.
    resources: [
        name:  'JSON'
        path:  'http://cdnjs.cloudflare.com/ajax/libs/json3/3.2.2/json3.min.js'
        type:  'js'
    ,
        name:  "jQuery"
        path:  "http://cdnjs.cloudflare.com/ajax/libs/jquery/1.7.2/jquery.min.js"
        type:  "js"
        wait:  true
    ,
        name:  "_"
        path:  "http://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.3.3/underscore-min.js"
        type:  "js"
        wait:  true
    ,
        name:  "Backbone"
        path:  "http://cdnjs.cloudflare.com/ajax/libs/backbone.js/0.9.2/backbone-min.js"
        type:  "js"
        wait:  true
    ,
        name:  "google"
        path:  "https://www.google.com/jsapi"
        type:  "js"
    ,
        path:  "https://raw.github.com/alexkalderimis/imjs/master/src/model.js"
        type:  "js"
    ,
        path:  "https://raw.github.com/alexkalderimis/imjs/master/src/query.js"
        type:  "js"
    ,
        path:  "https://raw.github.com/alexkalderimis/imjs/master/src/service.js"
        type:  "js"
    ]

    # New Widgets client.
    #
    # 1. `service`: [http://aragorn:8080/flymine/service/](http://aragorn:8080/flymine/service/)
    # 2. `token`:   token for accessing user's lists 
    constructor: (@service, @token = "") ->
        intermine.load @resources, =>
            # All libraries loaded, welcome jQuery, export classes.
            $ = window.jQuery
            # Enable Cross-Origin Resource Sharing (for Opera, IE).
            #$.support.cors = true
            o extends factory window.Backbone
            # Switch off waiting switch.
            @wait = false

    # Chart Widget.
    #
    # 1. `id`:            widgetId
    # 2. `bagName`:       myBag
    # 3. `el`:            #target
    # 4. `widgetOptions`: { "title": true/false, "description": true/false, "matchCb": function(id, type) {}, "resultsCb": function(pq) {}, "listCb": function(pq) {} }
    chart: (opts...) =>
        if @wait then window.setTimeout((=> @chart(opts...)), 0)
        else
            # Load Google Visualization.
            google.load "visualization", "1.0",
                packages: [ "corechart" ]
                callback: => new o.ChartWidget(@service, @token, opts...)
    
    # Enrichment Widget.
    #
    # 1. `id`:            widgetId
    # 2. `bagName`:       myBag
    # 3. `el`:            #target
    # 4. `widgetOptions`: { "title": true/false, "description": true/false, "matchCb": function(id, type) {}, "resultsCb": function(pq) {}, "listCb": function(pq) {} }
    enrichment: (opts...) =>
        if @wait then window.setTimeout((=> @enrichment(opts...)), 0) else new o.EnrichmentWidget(@service, @token, opts...)

    # Table Widget.
    #
    # 1. `id`:            widgetId
    # 2. `bagName`:       myBag
    # 3. `el`:            #target
    # 4. `widgetOptions`: { "title": true/false, "description": true/false, "matchCb": function(id, type) {}, "resultsCb": function(pq) {}, "listCb": function(pq) {} }
    table: (opts...) =>
        if @wait then window.setTimeout((=> @table(opts...)), 0) else new o.TableWidget(@service, @token, opts...)

    # All available Widgets.
    #
    # 1. `type`:          Gene, Protein
    # 2. `bagName`:       myBag
    # 3. `el`:            #target
    # 4. `widgetOptions`: { "title": true/false, "description": true/false, "matchCb": function(id, type) {}, "resultsCb": function(pq) {}, "listCb": function(pq) {} }
    all: (type = "Gene", bagName, el, widgetOptions) =>
        if @wait then window.setTimeout((=> @all(type, bagName, el, widgetOptions)), 0)
        else
            $.ajax
                url:      "#{@service}widgets"
                dataType: "jsonp"
                
                success: (response) =>
                    # We have results.
                    if response.widgets
                        # For all that match our object type...
                        for widget in response.widgets when type in widget.targets
                            # Create target element for individual Widget (slugify just to make sure).
                            widgetEl = widget.name.replace(/[^-a-zA-Z0-9,&\s]+/ig, '').replace(/-/gi, "_").replace(/\s/gi, "-").toLowerCase()
                            $(el).append $('<div/>', id: widgetEl, class: "widget span6")
                            
                            # What type is it?
                            switch widget.widgetType
                                when "chart"
                                    @chart(widget.name, bagName, "#{el} ##{widgetEl}", widgetOptions)
                                when "enrichment"
                                    @enrichment(widget.name, bagName, "#{el} ##{widgetEl}", widgetOptions)
                                when "table"
                                    @table(widget.name, bagName, "#{el} ##{widgetEl}", widgetOptions)
                
                error: (xhr, opts, err) => $(el).html $ '<div/>',
                    class: "alert alert-error"
                    html:  "#{xhr.statusText} for <a href='#{@service}widgets'>#{@service}widgets</a>"


# Do we have the InterMine API Loader?
if not window.intermine
    throw 'You need to include the InterMine API Loader first!'
else
    window.intermine.widgets = Widgets