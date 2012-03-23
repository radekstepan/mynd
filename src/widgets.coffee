# Public interface for the various InterMine Widgets.
class root.Widgets

    # JavaScript libraries as resources. Will be loaded if not present already.
    resources:
        js:
            jQuery:   "http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"
            _:        "http://documentcloud.github.com/underscore/underscore.js"
            google:   "https://www.google.com/jsapi"
            Backbone: "http://documentcloud.github.com/backbone/backbone-min.js"

    # New Widgets client.
    # `service`: http://aragorn.flymine.org:8080/flymine/service/
    # `token`:   token for accessing user's lists
    constructor: (@service, @token = "") ->
        # Check and load resources if needed.
        for library, path of @resources.js then do (library, path) =>
            if not window[library]?
                @wait = (@wait ? 0) + 1
                new JSLoader(path, =>
                    # We are jQuery.
                    if library is 'jQuery' then root.$ = window.jQuery
                    # We are Backbone.
                    if library is 'Backbone' then root extends factory(window.Backbone)
                    
                    @wait -= 1
                )
            else
                # We are jQuery.
                if library is 'jQuery' then root.$ = window.jQuery
                # We are Backbone.
                if library is 'Backbone' then root extends factory(window.Backbone)

    # Chart Widget.
    # `id`:            widgetId
    # `bagName`:       myBag
    # `el`:            #target
    # `widgetOptions`: { "title": true/false, "description": true/false, "selectCb": function() {} }
    chart: (opts...) =>
        if @wait then window.setTimeout((=> @chart(opts...)), 0)
        else
            # Load Google Visualization.
            google.load "visualization", "1.0",
                packages: [ "corechart" ]
                callback: => new ChartWidget(@service, @token, opts...)
    
    # Enrichment Widget.
    # `id`:            widgetId
    # `bagName`:       myBag
    # `el`:            #target
    # `widgetOptions`: { "title": true/false, "description": true/false, "matchCb": function() {} }
    enrichment: (opts...) =>
        if @wait then window.setTimeout((=> @enrichment(opts...)), 0) else new EnrichmentWidget(@service, @token, opts...)

    # All available Widgets.
    # `type`:          Gene, Protein
    # `bagName`:       myBag
    # `el`:            #target
    # `widgetOptions`: { "title": true/false, "description": true/false, "selectCb": function() {}, "matchCb": function() {} }
    all: (type = "Gene", bagName, el, widgetOptions) =>
        if @wait then window.setTimeout((=> @all(type, bagName, el, widgetOptions)), 0)
        else
            $.ajax
                url:      "#{@service}widgets"
                dataType: "json"
                
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
                
                error: (err) -> $(el).html $ '<div/>',
                    class: "alert alert-error"
                    text:  "An unspecified error has happened, server timeout?"