class ChartWidget extends InterMineWidget

    # Default widget options that will be merged with user's values.
    widgetOptions:
        "title":       true
        "description": true
        selectCb: (pq) ->
            console?.log pq

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
    # `widgetOptions`: { "title": true/false, "description": true/false, "selectCb": function(pq) {} }
    constructor: (@service, @token, @id, @bagName, @el, widgetOptions = {}) ->
        # Merge widgetOptions.
        @widgetOptions = merge widgetOptions, @widgetOptions

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
                # We have results.
                if response.wasSuccessful
                    new ChartView(
                        "widget":   @
                        "el":       @el
                        "template": @template
                        "response": response
                        "options":  @widgetOptions
                    )
            
            error: (err) => @error "AJAXTransport", err