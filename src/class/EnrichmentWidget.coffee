### Enrichment Widget main class.###

class EnrichmentWidget extends InterMineWidget

    # Default widget options that will be merged with user's values.
    widgetOptions:
        "title":       true
        "description": true
        matchCb: (id, type) ->
            console?.log id, type
        viewCb: (pq) ->
            console?.log pq

    errorCorrections: [ "Holm-Bonferroni", "Benjamini Hochberg", "Bonferroni", "None" ]
    pValues:          [ "0.05", "0.10", "1.00" ]

    # Spec for a successful and correct JSON response.
    spec:
        response:
            "title":               type.isString
            "description":         type.isString
            "pathQuery":           type.isJSON
            "pathConstraint":      type.isString
            "error":               type.isNull
            "list":                type.isString
            "notAnalysed":         type.isInteger
            "requestedAt":         type.isString
            "results":             type.isArray
            "label":               type.isString
            "statusCode":          type.isHTTPSuccess
            "title":               type.isString
            "type":                type.isString
            "wasSuccessful":       type.isBoolean
            "filters":             type.isString
            "filterLabel":         type.isString
            "filterSelectedValue": type.isString

    # Set the params on us and render.
    #
    # 1. `service`:       http://aragorn.flymine.org:8080/flymine/service/
    # 2. `token`:         token for accessing user's lists
    # 3. `id`:            widgetId
    # 4. `bagName`:       myBag
    # 4. `el`:            #target
    # 5. `widgetOptions`: { "title": true/false, "description": true/false, "matchCb": function(id, type) {}, "viewCb": function(pq) {} } }
    constructor: (@service, @token, @id, @bagName, @el, widgetOptions = {}) ->
        # Merge `widgetOptions`.
        @widgetOptions = merge widgetOptions, @widgetOptions

        # Set form options for this widget.
        @formOptions =
            errorCorrection: "Holm-Bonferroni"
            pValue:          "0.05"

        super() # Luke... I am your father!
        @render()

    # Visualize the widget.
    render: =>
        # *Loading* overlay.
        timeout = window.setTimeout((=> $(@el).append @loading = $ @template 'loading'), 400)

        # Removes all of the **View**'s delegated events if there is one already.
        @view?.undelegateEvents()

        # Payload.
        data =
            'widget':     @id
            'list':       @bagName
            'correction': @formOptions.errorCorrection
            'maxp':       @formOptions.pValue
            'token':      @token

        # An extra form filter?
        for key, value of @formOptions
            # This should be handled better...
            if key not in [ 'errorCorrection', 'pValue' ] then data['filter'] = value

        # Request new data.
        $.ajax
            'url':      "#{@service}list/enrichment"
            'dataType': "jsonp"
            'data':     data
            
            success: (response) =>
                # No need for a loading overlay.
                window.clearTimeout timeout
                @loading?.remove()

                # We have response, validate.
                @validateType response, @spec.response
                # We have results.
                if response.wasSuccessful
                    # Actual name of the widget.
                    @name = response.title

                    # New **View**.
                    @view = new EnrichmentView(
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
            
            error: (err) => @error err, "AJAXTransport"