class ChartView extends Backbone.View

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

    initialize: (o) ->
        @[k] = v for k, v of o
        @render()

    render: ->
        # Render the widget template.
        $(@el).html @template "chart.normal",
            "title":       if @options.title then @response.title else ""
            "description": if @options.description then @response.description else ""
            "notAnalysed": @response.notAnalysed

        # Are the results empty?
        if @response.results.length > 1
            # Create the chart.
            if @response.chartType of google.visualization # If the type exists...
                chart = new google.visualization[@response.chartType]($(@el).find("div.content")[0])
                chart.draw(google.visualization.arrayToDataTable(@response.results, false), @chartOptions)

                # Add event listener on click the chart bar.
                if @response.pathQuery?
                    google.visualization.events.addListener chart, "select", =>
                        pq = @response.pathQuery
                        for item in chart.getSelection()
                            if item.row?
                                # Replace %category in PathQuery.
                                pq = pq.replace("%category", response.results[item.row + 1][0])
                                if item.column?
                                    # Replace %series in PathQuery.
                                    pq = pq.replace("%series", @_translateSeries(@response, @response.results[0][item.column]))
                                @options.selectCb(pq)
            else
                # Undefined Google Visualization chart type.
                $(@el).html @template "error",
                    title: @response.chartType
                    text:  "This chart type does not exist in Google Visualization API"

        else
            # Render no results.
            $(@el).find("div.content").html $ @template "noresults"


    # Translate view series into PathQuery series (Expressed/Not Expressed into true/false).
    _translateSeries: (response, series) -> response.seriesValues.split(',')[response.seriesLabels.split(',').indexOf(series)]