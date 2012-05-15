### View maintaining Chart Widget.###

class ChartView extends Backbone.View

    # Google Visualization chart options.
    chartOptions:
        fontName: "Sans-Serif"
        fontSize: 11
        width:    460
        height:   450
        colors:   [ "#2F72FF", "#9FC0FF" ]
        legend:
            position: "top"
        chartArea:
            top:    30
            left:   50
            width:  400
            height: 305
        hAxis:
            titleTextStyle:
                fontName: "Sans-Serif"
        vAxis:
            titleTextStyle:
                fontName: "Sans-Serif"

    events:
        "change div.form select": "formAction"

    initialize: (o) ->
        @[k] = v for k, v of o
        @render()

    render: ->
        # Render the widget template.
        $(@el).html @template "chart",
            "title":       if @options.title then @response.title else ""
            "description": if @options.description then @response.description else ""
            "notAnalysed": @response.notAnalysed

        # Extra attributes (DataSets etc.)?
        if @response.filterLabel?
            $(@el).find('div.form form').append @template "extra",
                "label":    @response.filterLabel
                "possible": @response.filters.split(',') # Is a String unfortunately.
                "selected": @response.filterSelectedValue

        # Are the results empty?
        if @response.results.length > 1
            # Create the chart.
            if @response.chartType of google.visualization # If the type exists...

                # Set the legend on axes.
                @chartOptions.hAxis =
                    'title': if @response.chartType is 'BarChart' then @response.rangeLabel else @response.domainLabel
                @chartOptions.vAxis =
                    'title': if @response.chartType is 'BarChart' then @response.domainLabel else @response.rangeLabel

                chart = new google.visualization[@response.chartType]($(@el).find("div.content")[0])
                chart.draw(google.visualization.arrayToDataTable(@response.results, false), @chartOptions)

                # Add event listener on click the chart bar.
                if @response.pathQuery?
                    google.visualization.events.addListener chart, "select", =>
                        # Translate view series into PathQuery series (Expressed/Not Expressed into true/false).
                        translate = (response, series) ->
                            # Chromosome Distribution widget fails on this step not having `seriesValues`.
                            if response.seriesValues?
                                response.seriesValues.split(',')[response.seriesLabels.split(',').indexOf(series)]

                        # Determine which bar we are in.
                        description = '' ; resultsPq = @response.pathQuery ; quickPq = @response.simplePathQuery
                        for item in chart.getSelection()
                            if item.row?
                                row = @response.results[item.row + 1][0]
                                description += row
                                # Replace `%category` in PathQueries.
                                resultsPq = resultsPq.replace "%category", row ; quickPq = quickPq.replace "%category"
                                # Replace `%series` in PathQuery.
                                if item.column?
                                    column = @response.results[0][item.column]
                                    description += ' ' + column
                                    resultsPq = resultsPq.replace("%series", translate @response, column)
                                    quickPq =   resultsPq.replace("%series", translate @response, column)
                        
                        # Turn into JSON object?
                        resultsPq = JSON?.parse resultsPq ; quickPq = JSON?.parse quickPq

                        # Remove any previous.
                        if @barView? then @barView.close()

                        # We may have deselected a bar.
                        if description
                            # Create `View`
                            $(@el).find('div.content').append (@barView = new ChartPopoverView(
                                "description": description
                                "template":    @template
                                "resultsPq":   resultsPq
                                "resultsCb":   @options.resultsCb
                                "listCb":      @options.listCb
                                "matchCb":     @options.matchCb
                                "quickPq":     quickPq
                                "imService":   @widget.imService
                                "type":        @response.type
                            )).el
            else
                # Undefined Google Visualization chart type.
                @error 'title': @response.chartType, 'text': "This chart type does not exist in Google Visualization API"

        else
            # Render no results.
            $(@el).find("div.content").html $ @template "noresults"

    # On form select option change, set the new options and re-render.
    formAction: (e) =>
        @widget.formOptions[$(e.target).attr("name")] = $(e.target[e.target.selectedIndex]).attr("value")
        @widget.render()