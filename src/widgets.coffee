root = this

# JSON Types.
type = {}
class type.Root
    result: false
    is: -> @result
    toString: -> @expected

class type.isString extends type.Root
    expected: "String"
    constructor: (key) -> @result = typeof key is 'string'

class type.isInteger extends type.Root
    expected: "Integer"
    constructor: (key) -> @result = typeof key is 'number'

class type.isBoolean extends type.Root
    expected: "Boolean true"
    constructor: (key) -> @result = typeof key is 'boolean'

class type.isNull extends type.Root
    expected: "Null"
    constructor: (key) -> @result = key is null

class type.isArray extends type.Root
    expected: "Array"
    constructor: (key) -> @result = key instanceof Array

class type.isHTTPSuccess extends type.Root
    expected: "HTTP code 200"
    constructor: (key) -> @result = key is 200

class type.isUndefined extends type.Root
    expected: "it to be undefined"


# --------------------------------------------


class InterMineWidget

    # Inject wrapper inside the target div that we have control over.
    constructor: ->
        $(@el).html $ '<div/>',
            class: "inner"
            style: "height:572px;overflow:hidden"
        @el = "#{@el} div.inner"

    # Where is eco?
    template: (name, context = {}) -> JST["#{name}.eco"]?(context)

    # Validate JSON object against the spec.
    validateType: (object, spec) =>
        fails = []
        for key, value of object
            if (r = new spec[key]?(value) or r = new type.isUndefined()) and not r.is()
                fails.push @template "invalidjsonkey",
                    key:      key
                    actual:   r.is()
                    expected: new String(r)
        
        if fails.length then @error "JSONObjectType", fails

    # The possible errors we handle.
    error: (type, data) =>
        opts = title: "Error", text: "Generic error"

        # Which?
        switch type
            when "AJAXTransport"
                opts.title = data.statusText
                opts.text = data.responseText
            when "JSONObjectType"
                opts.title = "Invalid JSON"
                opts.text = "<ol>#{data.join('')}</ol>"

        # Show.
        $(@el).html @template "error", opts

# --------------------------------------------

class ChartWidget extends InterMineWidget

    # Google Visualization chart options.
    chartOptions:
        fontName: "Sans-Serif"
        fontSize: 11
        width:    400
        height:   450
        legend:   "bottom"
        colors:   [ "#2F72FF", "#9FC0FF" ]
        chartArea:
            top: 30
        hAxis:
            titleTextStyle:
                fontName: "Sans-Serif"
        vAxis:
            titleTextStyle:
                fontName: "Sans-Serif"

    # Spec for a successful and correct JSON response.
    spec:
        response:
            "chartType":     type.isString
            "description":   type.isString
            "error":         type.isNull
            "list":          type.isString
            "notAnalysed":   type.isInteger
            "pathQuery":     type.isString
            "requestedAt":   type.isString
            "results":       type.isArray
            "seriesLabels":  type.isString
            "seriesValues":  type.isString
            "statusCode":    type.isHTTPSuccess
            "title":         type.isString
            "type":          type.isString
            "wasSuccessful": type.isBoolean

    # Set the params on us and set Google load callback.
    # `service`:       http://aragorn.flymine.org:8080/flymine/service/
    # `token`:         token for accessing user's lists
    # `id`:            widgetId
    # `bagName`:       myBag
    # `el`:            #target
    # `widgetOptions`: { "title": true/false, "description": true/false, "selectCb": function() {} }
    constructor: (@service, @token, @id, @bagName, @el, @widgetOptions = {
        "title":       true
        "description": true
        # By default, the select callback will open a new window with a table of results.
        selectCb: (pq) => window.open "#{@service}query/results?query=#{encodeURIComponent(pq)}&format=html"
    }) ->
        super()
        @render()

    # Visualize the displayer.
    render: =>
        # Get JSON response by calling the service.
        $.ajax
            url:      "#{@service}list/chart"
            dataType: "json"
            data:
                widget: @id
                list:   @bagName
                token:  @token
            
            success: (response) =>
                # We have response, validate.
                @validateType response, @spec.response
                # Render the widget template.
                $(@el).html @template "chart.normal",
                    "title":       if @widgetOptions.title then response.title else ""
                    "description": if @widgetOptions.description then response.description else ""
                    "notAnalysed": response.notAnalysed

                # Are the results empty?
                if response.results.length > 1
                    # Create the chart.
                    if response.chartType of google.visualization # If the type exists...
                        chart = new google.visualization[response.chartType]($(@el).find("div.content")[0])
                        chart.draw(google.visualization.arrayToDataTable(response.results, false), @chartOptions)

                        # Add event listener on click the chart bar.
                        if response.pathQuery?
                            google.visualization.events.addListener chart, "select", =>
                                pq = response.pathQuery
                                for item in chart.getSelection()
                                    if item.row?
                                        # Replace %category in PathQuery.
                                        pq = pq.replace("%category", response.results[item.row + 1][0])
                                        if item.column?
                                            # Replace %series in PathQuery.
                                            pq = pq.replace("%series", @_translateSeries(response, response.results[0][item.column]))
                                        @widgetOptions.selectCb(pq)
                    else
                        # Undefined Google Visualization chart type.
                        $(@el).html @template "error",
                            title: response.chartType
                            text:  "This chart type does not exist in Google Visualization API"
                else
                    # Render no results.
                    $(@el).find("div.content").html $ @template "noresults"
            
            error: (err) => @error "AJAXTransport", err

    # Translate view series into PathQuery series (Expressed/Not Expressed into true/false).
    _translateSeries: (response, series) -> response.seriesValues.split(',')[response.seriesLabels.split(',').indexOf(series)]


# --------------------------------------------


class EnrichmentWidget extends InterMineWidget

    formOptions:
        errorCorrection: "Holm-Bonferroni"
        pValue:          0.05

    errorCorrections: [ "Holm-Bonferroni", "Benjamini Hochberg", "Bonferroni", "None" ]
    pValues: [ 0.05, 0.10, 1.00 ]

    # Spec for a successful and correct JSON response.
    spec:
        response:
            "title":         type.isString
            "description":   type.isString
            "error":         type.isNull
            "list":          type.isString
            "notAnalysed":   type.isInteger
            "requestedAt":   type.isString
            "results":       type.isArray
            "label":         type.isString
            "statusCode":    type.isHTTPSuccess
            "title":         type.isString
            "type":          type.isString
            "wasSuccessful": type.isBoolean
        resultRow:
            "description": type.isString
            "item":        type.isString
            "matches":     type.isArray
            "p-value":     type.isInteger

    # Set the params on us and render.
    # `service`:       http://aragorn.flymine.org:8080/flymine/service/
    # `token`:         token for accessing user's lists
    # `id`:            widgetId
    # `bagName`:       myBag
    # `el`:            #target
    # `widgetOptions`: { "title": true/false, "description": true/false, "matchCb": function() {} }
    constructor: (@service, @token, @id, @bagName, @el, @widgetOptions = {
        "title":       true
        "description": true
        # By default, the select callback will dump the match id into the console.
        matchCb: (id) => console?.log id
    }) ->
        super() # Luke... I am your father!
        @render()

    # Visualize the displayer.
    render: =>
        $.ajax
            url:      "#{@service}list/enrichment"
            dataType: "json"
            data:
                widget:     @id
                list:       @bagName
                correction: @formOptions.errorCorrection
                maxp:       @formOptions.pValue
                token:      @token
            
            success: (response) =>
                # We have response, validate.
                @validateType response, @spec.response
                # We have results.
                if response.wasSuccessful
                    # Render the widget template.
                    $(@el).html @template "enrichment.normal",
                        "title":       if @widgetOptions.title then response.title else ""
                        "description": if @widgetOptions.description then response.description else ""
                        "notAnalysed": response.notAnalysed

                    # Callback for actions.
                    $(@el).find("div.actions button.view").click => @viewClick()
                    $(@el).find("div.actions button.export").click => @exportClick()

                    # Form options.
                    $(@el).find("div.form").html @template "enrichment.form",
                        "options":          @formOptions
                        "errorCorrections": @errorCorrections
                        "pValues":          @pValues
                    
                    # Extra attributes (DataSets)?
                    if response.extraAttributeLabel?
                        $(@l).find('div.form form').append @template "enrichment.extra",
                            "label":    response.extraAttributeLabel
                            "possible": response.extraAttributePossibleValues
                            "selected": response.extraAttributeSelectedValue

                    # Results?
                    if response.results.length > 0
                        # How tall should the table be?
                        height = $(@el).height() - $(@el).find('header').height() - 18

                        # Render the table.
                        $(@el).find("div.content").html(
                            $ @template "enrichment.table", "label": response.label
                        ).css "height", "#{height}px"
                        
                        # Table rows.
                        table = $(@el).find("div.content table")
                        for i in [0...response.results.length] then do (i) =>
                            row = response.results[i]
                            # Validate type.
                            @validateType row, @spec.resultRow
                            # Append.
                            table.append tr = $ @template "enrichment.row", "row": row
                            # Events.
                            td = tr.find("td.matches .count").click => @matchesClick td, row["matches"], @widgetOptions.matchCb
                            tr.find("td.check input").click => @checkboxClick i, row
                    else
                        # Render no results
                        $(@el).find("div.content").html $ @template "noresults"

                    # Set behaviors.
                    $(@el).find("form select").change @formClick
            
            error: (err) => @error "AJAXTransport", err

    # On form select option change, set the new options and re-render.
    formClick: (e) =>
        @formOptions[$(e.target).attr("name")] = $(e.target[e.target.selectedIndex]).attr("value")
        @render()

    # Append to or remove from a list of selected rows.
    checkboxClick: (key, row) =>
        if not @selected? then @selected = {}
        if @selected[key]? then delete @selected[key] else @selected[key] = row

    # Show matches.
    matchesClick: (target, matches, matchCb) =>
        target.after modal = $ @template "enrichment.matches", "matches": matches
        modal.find("a.close").click -> modal.remove()
        # Individual match click behavior.
        modal.find("div.popover-content a").click (e) ->
            matchCb $(@).text()
            e.preventDefault()

    # Button toolbar 'View' click.
    viewClick: ->
        console.log "view"

    # Button toolbar 'Export' click.
    exportClick: =>
        result = []
        for key, value of @selected
            result.push $(@template "enrichment.download", value).html()
        w = window.open('', '', "width=900,height=600")
        w.document.writeln result.join '<br/>'


# --------------------------------------------


# Asynchronously load resources by adding them to the `<head>` and use callback.
class Loader

    getHead: -> document.getElementsByTagName('head')[0]

    setCallback: (tag, callback) ->
        tag.onload = callback
        tag.onreadystatechange = ->
            state = tag.readyState
            if state is "complete" or state is "loaded"
                tag.onreadystatechange = null
                window.setTimeout callback, 0


# JavaScript Loader.
class JSLoader extends Loader

    constructor: (path, callback) ->
        script = document.createElement "script"
        script.src = path;
        script.type = "text/javascript"
        @setCallback(script, callback) if callback
        @getHead().appendChild(script)


# Cascading Style Sheet Loader.
class CSSLoader extends Loader

    constructor: (path, callback) ->
        sheet = document.createElement "link"
        sheet.rel = "stylesheet"
        sheet.type = "text/css"
        sheet.href = path
        @setCallback(sheet, callback) if callback
        @getHead().appendChild(sheet)


# --------------------------------------------


# Public interface for the various InterMine Widgets.
class root.Widgets

    # JavaScript libraries as resources. Will be loaded if not present already.
    resources:
        js:
            jQuery: "http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"
            _:      "http://documentcloud.github.com/underscore/underscore.js"
            google: "https://www.google.com/jsapi"

    # New Widgets client.
    # `service`: http://aragorn.flymine.org:8080/flymine/service/
    # `token`:   token for accessing user's lists
    constructor: (@service, @token = "") ->
        # Check and load resources if needed.
        for library, path of @resources.js then do (library, path) =>
            if not root[library]?
                @wait = (@wait ? 0) + 1
                new JSLoader(path, =>
                    if library is "jQuery" then root.$ = root.jQuery # We are jQuery.
                    @wait -= 1
                )
            else
                if library is "jQuery" then root.$ = root.jQuery # We are jQuery.

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