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

            # d3.js
            width = 420 ; height = 200 # size
            data = [ 4, 8, 15, 16, 23, 42 ] # series

            chart = d3.select(($(@el).find("div.content")[0]))
            .append('svg:svg') # append svg
            .attr('class', 'chart')
            .attr('width', width)
            .append("svg:g") # add a wrapping container
            .attr("transform", "translate(10,15)")

            x = d3.scale.linear()
            .domain([ 0, d3.max(data) ])
            .range([ 0, width ])
            y = d3.scale.ordinal()
            .domain(data)
            .rangeBands([ 0, height ])

            # The grid.
            chart.selectAll("line")
            .data(x.ticks(10))
            .enter()
            .append("svg:line")
            .attr("x1", x)
            .attr("x2", x)
            .attr("y1", 0)
            .attr("y2", height)

            # The grid values.
            chart.selectAll(".rule")
            .data(x.ticks(10))
            .enter()
            .append("svg:text")
            .attr("class", "rule")
            .attr("x", x)
            .attr("y", 0)
            .attr("dy", -3)
            .attr("text-anchor", "middle")
            .text(String)

            # The bars.
            chart.selectAll('rect')
            .data(data)
            .enter()
            .append('svg:rect')
            .attr("class", (d, i) -> [ 'first', 'second' ][i % 2])
            .attr('y', y)
            .attr('width', x)
            .attr('height', y.rangeBand())

            # Single line for y-axis,
            chart.append("svg:line")
            .attr("class", "axis y")
            .attr("y1", 0)
            .attr("y2", height)
        else
            # Render no results.
            $(@el).find("div.content").html $ @template "noresults"

    # On form select option change, set the new options and re-render.
    formAction: (e) =>
        @widget.formOptions[$(e.target).attr("name")] = $(e.target[e.target.selectedIndex]).attr("value")
        @widget.render()