### View maintaining Chart Widget.###

class ChartView extends Backbone.View

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
            # Form the series from Google Visualization formatted data.
            series = [
                data:  []
                color: '#2F72FF'
                name:  @response.results[0][1]
            ,
                data:  []
                color: '#9FC0FF'
                name:  @response.results[0][2]
            ]
            series[j]['data'].push { 'x': i-1, 'y': @response.results[i][j+1] } for j in [0, 1] for i in [1..@response.results.length-1]

            # 'Fix' glitch in the library.
            series[i]['data'].push { 'x': @response.results.length, 'y':0 } for i in [0, 1]

            # Render with Rickshaw.
            graph = new Rickshaw.Graph(
                'element':  $(@el).find("div.content div.graph")[0]
                'height':   250
                'renderer': 'bar'
                'series':   series
            )
            
            # Provide axes.
            new Rickshaw.Graph.Axis.Y(
                'graph':      graph
                'tickFormat': Rickshaw.Fixtures.Number.formatKMBT
                'element':    $(@el).find("div.content div.axis.y")[0]
            )

            graph.renderer.unstack = true
            graph.render()

            # Provide a legend.
            new Rickshaw.Graph.Legend(
                'graph':   graph
                'element': $(@el).find("div.content div.legend")[0]
            )
        else
            # Render no results.
            $(@el).find("div.content").html $ @template "noresults"

    # On form select option change, set the new options and re-render.
    formAction: (e) =>
        @widget.formOptions[$(e.target).attr("name")] = $(e.target[e.target.selectedIndex]).attr("value")
        @widget.render()