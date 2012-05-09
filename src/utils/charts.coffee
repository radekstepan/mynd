Charts = { 'MultipleBars': {} }


class Charts.MultipleBars.Vertical

    # Expand object values on us.
    constructor: (o) ->
        @[k] = v for k, v of o

        # Create the chart wrapper.
        @canvas = d3.select(@el[0])
        .append('svg:svg') # append svg
        .attr('class', 'canvas')
        .attr('width', @width)
        .attr('height', @height)

    render: () ->
        margin = 10

        # Chart `g`.
        @chart = @canvas.append("svg:g").attr("class", "chart").attr("transform", "translate(15,10)")

        # Descriptions.
        descWidth = -Infinity
        descriptions = @canvas.append('svg:g').attr('class', 'descriptions')
        for i, group of @data
            text = descriptions.append("svg:text")
                .attr("class", "text group g#{i}")
                .attr("text-anchor", "end")
                .text(group['text'])

            # Update the max width.
            width = text.node().getComputedTextLength()
            descWidth = width if width > descWidth

        # Reduce the chart space for chart and add some extra padding for the grid.
        @width = @width - 15 - margin ; @height = @height - 30 - (descWidth * 0.5)

        # Get the domain.
        domain = @_domain()

        # Draw the grid of whole numbers.
        g = @chart.append("svg:g").attr("class", "grid")
        isWhole = @_isWhole()
        
        for tick in domain['y'].ticks(10)
            if (parseInt(tick) is tick) or (!isWhole)
                g.append("svg:line")
                .attr("class", "line")
                .attr("y1", domain['y'](tick)).attr("y2", domain['y'](tick))
                .attr("x1", margin).attr("x2", @width)

                g.append("svg:text")
                .attr("class", "rule")
                .attr("x", 0)
                .attr("dx", -3)
                .attr("y", @height - domain['y'](tick))
                .attr("text-anchor", "middle")
                .text tick.toFixed(0)

        # The bars.
        for i, group of @data
            # A wrapper group.
            g = @chart
            .append("svg:g")
            .attr("class", "group g#{i}")
            
            j = 0
            for series, value of group['data']
                # Calculate the distances.
                width =  domain['x'].rangeBand() / 2
                left =   domain['x'](i) + (j * width)
                height = domain['y'](value)

                # Append the actual rectangle.
                g.append("svg:rect")
                .attr("class",  series)
                .attr('x',      margin + left)
                .attr('y',      @height - height)
                .attr('width',  width)
                .attr('height', height)

                j++
            
            # Update the distance from left for description text.
            descriptions.select(".g#{i}")
            .attr('x', margin + left + width)
            .attr('y', @height + 20)
            .attr("transform", "rotate(-30 #{margin + left + width} #{@height + 20})")

    # Get the domain.
    _domain: () ->
        {
            'x': d3.scale.ordinal().domain([0..@data.length - 1]).rangeBands([ 0, @width ], .05)
            'y': d3.scale.linear().domain([ 0, @_max() ]).range([ 0, @height ])
        }   

    # Get a maximum value from series.
    _max: () ->
        max = -Infinity
        for group in @data
            for key, value of group['data']
                max = value if value > max
        max

    # Does the chart only contain whole numbers?
    _isWhole: () ->
        for group in @data
            for key, value of group['data']
                return false if parseInt(value) isnt value
        true