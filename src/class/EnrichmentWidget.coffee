class EnrichmentWidget extends InterMineWidget

    # Default widget options that will be merged with user's values.
    widgetOptions:
        "title":       true
        "description": true
        matchCb: (id, type) ->
            console?.log id, type
        viewCb: (ids, pq) ->
            console?.log ids, pq

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

    # Set the params on us and render.
    # `service`:       http://aragorn.flymine.org:8080/flymine/service/
    # `token`:         token for accessing user's lists
    # `id`:            widgetId
    # `bagName`:       myBag
    # `el`:            #target
    # `widgetOptions`: { "title": true/false, "description": true/false, "matchCb": function(id, type) {}, "viewCb": function(ids, pq) {} } }
    constructor: (@service, @token, @id, @bagName, @el, widgetOptions) ->
        # Merge widgetOptions.
        @widgetOptions = merge widgetOptions, @widgetOptions

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
                    # New View.
                    new EnrichmentView(
                        "widget":   @
                        "el":       @el
                        "template": @template
                        "response": response
                        "form":
                            "options":          @formOptions
                            "pValues":          @pValues
                            "errorCorrections": @errorCorrections
                        "options":  @widgetOptions
                    )
            
            error: (err) => @error "AJAXTransport", err