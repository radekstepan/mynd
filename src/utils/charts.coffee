Charts = { 'MultipleBars': {} }


class Charts.MultipleBars.Vertical

    # Size.
    width:  420
    height: 300

    # Expand object values on us.
    constructor: (o) ->
        @[k] = v for k, v of o

        # Create the chart wrapper.
        @canvas = d3.select(@el[0])
        .append('svg:svg') # append svg
        .attr('class', 'canvas')
        .attr('width', @width)

    render: () ->
        margin = 10

        # Reduce the chart space for chart and add some extra padding for the grid.
        @width = @width - 15 - margin ; @height = @height - 10

        # Chart `g`.
        @chart = @canvas.append("svg:g").attr("class", "chart").attr("transform", "translate(15,10)")
        
        # Get the domain.
        domain = @_domain()

        # Draw the grid.
        g = @chart.append("svg:g").attr("class", "grid")
        
        g.selectAll("line").data(domain['y'].ticks(10)).enter()
        .append("svg:line")
        .attr("y1", domain['y']).attr("y2", domain['y'])
        .attr("x1", margin).attr("x2", @width)

        # The grid values.
        g.selectAll(".rule")
        .data(domain['y'].ticks(10)).enter()
        .append("svg:text")
        .attr("class", "rule")
        .attr("x", 0)
        .attr("dx", -3)
        .attr("y", (d) => @height - domain['y'](d))
        .attr("text-anchor", "middle")
        .text (d) -> d.toFixed(1)

        # Descriptions wrapper.
        descriptions = @canvas.append('svg:g').attr('class', 'descriptions')

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
            
            # Place the descriptions text.
            text = descriptions.append("svg:text")
                .attr("class", "text group g#{i}")
                .attr('y', @height + 20)
                .attr('x', left + width)
                .attr("text-anchor", "middle")
                .attr("transform", "rotate(-45 #{left + width} #{@height + 20})")
                .text(group['text'])

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


class Charts.MultipleBars.Horizontal

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
        for i, group of @data
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
        .text (d) -> d.toFixed(1)

        # The bars.
        for i, group of @data
            # A wrapper group.
            g = @chart
            .append("svg:g")
            .attr("class", "group g#{i}")
            
            j = 0
            for series, value of group['data']
                # Calculate the distances.
                top =    domain['y'](i) + (j * height)
                width =  domain['x'](value)
                height = domain['y'].rangeBand() / 2

                # Append the actual rectangle.
                g.append("svg:rect")
                .attr("class",  series)
                .attr('y',      top)
                .attr('width',  width)
                .attr('height', height)

                j++

            # Update the distance from top (top for bar + bar height) for the description text.
            descriptions.select(".g#{i}").attr('y', top + height)

    # Get the domain.
    _domain: () ->
        {
            'x': d3.scale.linear().domain([ 0, @_max() ]).range([ 0, @width ])
            'y': d3.scale.ordinal().domain([0..@data.length - 1]).rangeBands([ 0, @height ], .05)
        }   

    # Get a maximum value from series.
    _max: () ->
        max = -Infinity
        for group in @data
            for key, value of group['data']
                max = value if value > max
        max