Charts = {}

class Charts.MultipleBars

    # Size.
    width:  420
    height: 200

    # Expand object values on us.
    constructor: (o) ->
        @[k] = v for k, v of o

        # Create the chart wrapper.
        @canvas = d3.select(@el[0])
        .append('svg:svg') # append svg
        .attr('class', 'canvas')
        .attr('width', @width)

    render: () ->
        # Place the description text to determine its width.
        descWidth = -Infinity
        descriptions = @canvas.append('svg:g').attr('class', 'descriptions')
        for i, group of @series
            text = descriptions.append("svg:text")
                .attr("class", "text group g#{i}")
                .text(group['text'])

            # Update the max width.
            width = text.node().getComputedTextLength()
            descWidth = width if width > descWidth

        # Reduce the chart space for chart and add some extra padding for the grid.
        @width = @width - descWidth - 10 ; @height = @height - 15

        # Chart `g`.
        @chart = @canvas.append("svg:g").attr("class", "chart").attr("transform", "translate(#{descWidth + 5},15)")
        
        # Get the domain.
        domain = @_domain()

        # Draw the grid.
        g = @chart.append("svg:g").attr("class", "grid")
        
        g.selectAll("line").data(domain['x'].ticks(10)).enter()
        .append("svg:line")
        .attr("x1", domain['x']).attr("x2", domain['x'])
        .attr("y1", 0).attr("y2", @height)

        # The grid values.
        g.selectAll(".rule")
        .data(domain['x'].ticks(10)).enter()
        .append("svg:text")
        .attr("class", "rule")
        .attr("x", domain['x'])
        .attr("y", 0)
        .attr("dy", -3)
        .attr("text-anchor", "middle")
        .text(String)

        # The bars.
        for i, group of @series
            # A wrapper group.
            g = @chart
            .append("svg:g")
            .attr("class", "group g#{i}")
            
            j = 0
            for series, value of group['data']
                # Calculate the distances.
                height = domain['y'].rangeBand() / 2
                top =    domain['y'](i) + (j * height)
                value =  domain['x'](value)

                # Append the actual rectangle.
                g.append("svg:rect")
                .attr("class",  series)
                .attr('y',      top)
                .attr('width',  value)
                .attr('height', height)

                j++

            # Update the distance from top (top for bar + bar height) for the description text.
            descriptions.select(".g#{i}").attr('y', top + height)

    # Get the domain.
    _domain: () ->
        {
            'x': d3.scale.linear().domain([ 0, @_max() ]).range([ 0, @width ])
            'y': d3.scale.ordinal().domain([0..@series.length - 1]).rangeBands([ 0, @height ], .05)
        }   

    # Get a maximum value from series.
    _max: () ->
        max = -Infinity
        for group in @series
            for key, value of group['data']
                max = value if value > max
        max