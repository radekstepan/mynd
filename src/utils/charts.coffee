Charts = { }

class Charts.TwoBars

    # Number of ColorBrewer classes.
    colorbrewer: 4

    # Expand object values on us.
    constructor: (o) ->
        @[k] = v for k, v of o

        # Update the height of the outer element.
        $(@el).css 'height', @height

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
                # Horizontal line.
                g.append("svg:line")
                .attr("class", "line")
                .attr("y1", domain['y'](tick)).attr("y2", domain['y'](tick))
                .attr("x1", margin).attr("x2", @width)

                # Description
                g.append("svg:text")
                .attr("class", "rule")
                .attr("x", 0)
                .attr("dx", -3)
                .attr("y", @height - domain['y'](tick))
                .attr("text-anchor", "middle")
                .text tick.toFixed(0)

        # Vertical lines.
        for i, group of @data
            left = margin + domain['x'](i) + domain['x'].rangeBand() / 2

            g.append("svg:line")
            .attr("class", "line dashed")
            .attr("x1", left).attr("x2", left)
            .attr("y1", 0).attr("y2", @height)
            .attr("style", "stroke-dasharray: 10, 5;")

        # The bars.
        bars = @chart.append("svg:g").attr("class", "bars") ; values = @chart.append("svg:g").attr("class", "values")
        for i, group of @data
            # A wrapper group.
            g = bars
            .append("svg:g")
            .attr("class", "group g#{i}")
            
            j = 0
            for series, value of group['data']
                # Calculate the distances.
                width =  domain['x'].rangeBand() / 2
                left =   domain['x'](i) + (j * width)
                height = domain['y'](value)
                # ColorBrewer band.
                color =  domain['color'](value).toFixed(0)

                # Append the actual rectangle.
                bar = g.append("svg:rect")
                .attr("class",  "bar #{series} q#{color}-#{@colorbrewer}")
                .attr('x',      margin + left)
                .attr('y',      @height - height)
                .attr('width',  width)
                .attr('height', height)

                # Add a text value.
                values.append("svg:text")
                .attr("class", "value")
                .attr('x', margin + left + (width / 2))
                .attr('y', @height - height - 1)
                .attr("text-anchor", "middle")
                .text value

                # Attach onclick event.
                if @onclick?
                    do (bar, group, j, value) =>
                        bar.on 'click', => @onclick group['text'], j, value

                j++
            
            # Update the distance from left for description text.
            desc = descriptions.select(".g#{i}")
            .attr('x', margin + left + width + 10)
            .attr('y', @height + 20)
            
            # (A better) naive fce to determine if we should rotate the text.
            if descWidth > width then desc.attr("transform", "rotate(-30 #{margin + left + width + 10} #{@height + 20})")

    # Get the domain.
    _domain: () ->
        {
            'x':     d3.scale.ordinal().domain([0..@data.length - 1]).rangeBands([ 0, @width ], .05)
            'y':     d3.scale.linear().domain([ 0, @_max() ]).range([ 0, @height ])
            'color': d3.scale.linear().domain([ 0, @_max() ]).range([ 0, @colorbrewer - 1 ])
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


class Charts.Legend

    # Expand object values on us.
    constructor: (o) ->
        @[k] = v for k, v of o

    render: () ->
        $(@el).append ul = $('<ul/>')
        ul.append $('<li/>',
            'class': 'a'
            'html':  @series['a']
        )
        ul.append $('<li/>',
            'class': 'b'
            'html':  @series['b']
        )
