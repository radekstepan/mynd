Chart = {}

class Chart.MultipleBars

    # Size.
    width:  420
    height: 200

    # Expand object values on us.
    constructor: (o) ->
        @[k] = v for k, v of o

        # Create the chart wrapper.
        @chart = d3.select(@el[0])
        .append('svg:svg') # append svg
        .attr('class', 'chart')
        .attr('width', @width)
        .append("svg:g") # add a wrapping container
        .attr("transform", "translate(10,15)")

    render: () ->
        # Get the domain.
        domain = @_domain()

        # Draw the grid.
        @_grid domain

        # The bars.
        i = 0
        for n, group of @series
            g = @chart
            .append("svg:g")
            .attr("class", "group g#{n}")
            for series, value of group
                g.append("svg:rect")
                .attr("class", series)
                .attr('y', domain['y'](i))
                .attr('width', domain['x'](value))
                .attr('height', domain['y'].rangeBand())

                console.log i, domain['x'](i)

                i++

    # Draw the grid.
    _grid: (domain) ->
        g = @chart.append("svg:g").attr("class", "grid")
        
        g.selectAll("line")
        .data(domain['x'].ticks(10))
        .enter()
        .append("svg:line")
        .attr("x1", domain['x'])
        .attr("x2", domain['x'])
        .attr("y1", 0)
        .attr("y2", @height)

        # The grid values.
        g.selectAll(".rule")
        .data(domain['x'].ticks(10))
        .enter()
        .append("svg:text")
        .attr("class", "rule")
        .attr("x", domain['x'])
        .attr("y", 0)
        .attr("dy", -3)
        .attr("text-anchor", "middle")
        .text(String)       

    # Get the domain.
    _domain: () ->
        # Get the domain.
        {
            'x': d3.scale.linear().domain([ 0, @_max() ]).range([ 0, @width ])
            'y': d3.scale.ordinal().domain([0..(@series.length * 2) - 1]).rangeBands([ 0, @height ], .1)
        }

    # Get a maximum value from series.
    _max: () ->
        max = -Infinity
        for i in @series
            for j in [ 'x', 'y' ]
                max = i[j] if i[j] > max
        max