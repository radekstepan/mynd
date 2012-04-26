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
        $(@el).html @template "chart.normal",
            "title":       if @options.title then @response.title else ""
            "description": if @options.description then @response.description else ""
            "notAnalysed": @response.notAnalysed

        # Extra attributes (DataSets etc.)?
        if @response.filterLabel?
            $(@el).find('div.form form').append @template "chart.extra",
                "label":    @response.filterLabel
                "possible": @response.filters.split(',') # Is a String unfortunately.
                "selected": @response.filterSelectedValue

        # Are the results empty?
        if @response.results.length > 1
            # Create the chart.
            if @response.chartType of google.visualization # If the type exists...
                chart = new google.visualization[@response.chartType]($(@el).find("div.content")[0])
                chart.draw(google.visualization.arrayToDataTable(@response.results, false), @chartOptions)

                # Add event listener on click the chart bar.
                if @response.pathQuery?
                    google.visualization.events.addListener chart, "select", =>
                        # Determine which bar we are in.
                        description = ''
                        for item in chart.getSelection()
                            if item.row?
                                description += @response.results[item.row + 1][0]
                                if item.column?
                                    description += ' ' + @response.results[0][item.column]

                        # Remove any previous.
                        if @barView? then @barView.close()
                        
                        # We may have deselected a bar.
                        if description
                            # Create `View`
                            $(@el).find('div.content').append (@barView = new ChartBarView(
                                "description": description
                                "template":    @template
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