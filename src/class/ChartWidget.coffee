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