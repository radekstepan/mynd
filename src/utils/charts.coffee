Chart =
    # The names of consecutive series.
    'series': [ 'first', 'second', 'third', 'fourth', 'fifth' ]


class Chart.Bars

    # Number of ColorBrewer classes.
    colorbrewer: 4

    # Assumed height of text.
    textHeight: 10

    # Expand object values on us.
    constructor: (o) ->
        @[k] = v for k, v of o

        # Get a better understanding of the datasets we are dealing with.
        @useWholeNumbers = true ; @maxValue = -Infinity
        for group in @data
            for key, value of group['data']
                # Does the chart only contain whole numbers?
                @useWholeNumbers = false if parseInt(value) isnt value
                # Get a maximum value from series.
                @maxValue = value if value > @maxValue

        # Update the height of the outer element.
        $(@el).css 'height', @height

        # Create the chart wrapper.
        @canvas = d3.select(@el[0])
        .append('svg:svg') # append svg
        .attr('class', 'canvas')

    render: () ->
        # Descriptions.
        descWidth = -Infinity
        descriptions = @canvas.append('svg:g').attr('class', 'descriptions')
        for index, group of @data
            # Wrapper for the text and title.
            g = descriptions.append("svg:g")
            .attr("class", "g#{index}")
            
            # Text.
            text = g.append("svg:text")
                .attr("class", "text")
                .attr("text-anchor", "end")
                .text(group['description'])

            # Update the max width.
            width = text.node().getComputedTextLength()
            descWidth = width if width > descWidth

            # Add an onhover description title.
            g.append("svg:title").text group['description']

        # Reduce the chart space for chart and add some extra padding for the grid.
        @height = @height - @textHeight - (descWidth * 0.5)

        # Get the domain.
        domain =
            'y':     d3.scale.linear().domain([ 0, @maxValue ]).range([ 0, @height ])
            'color': d3.scale.linear().domain([ 0, @maxValue ]).range([ 0, @colorbrewer - 1 ])

        # Draw the grid of whole numbers.
        g = @canvas.append("svg:g").attr("class", "grid")

        # Axis numbers
        @axisMargin = -Infinity
        for tick in domain['y'].ticks(10)
            if (parseInt(tick) is tick) or (!@useWholeNumbers)
                text = g.append("svg:text")
                .attr("class", "tick")
                .attr("x", 0)
                .attr("y", @height - domain['y'](tick))
                .attr("text-anchor", "begin")
                .text tick.toFixed(0)

                # Update the max width.
                width = text.node().getComputedTextLength()
                @axisMargin = width if width > @axisMargin

        # Reduce the chart space for chart and add some extra padding for the grid.
        @width = @width - @axisMargin
        domain['x'] = d3.scale.ordinal().domain([0..@data.length - 1]).rangeBands([ 0, @width ], .05)

        # Horizontal lines.
        for tick in domain['y'].ticks(10)
            if (parseInt(tick) is tick) or (!@useWholeNumbers)
                y = @height - domain['y'](tick)
                
                g.append("svg:line")
                .attr("class", "line")
                .attr("y1", y).attr("y2", y)
                .attr("x1", @axisMargin).attr("x2", @width)

        # Chart `g`.
        @chart = @canvas.append("svg:g").attr("class", "chart")

        # The bars.
        bars = @chart.append("svg:g").attr("class", "bars") ; values = @chart.append("svg:g").attr("class", "values")
        for index, group of @data
            # A wrapper group.
            g = bars
            .append("svg:g")
            .attr("class", "g#{index}")
            
            # Place vertical line.
            left = @axisMargin + domain['x'](index) + domain['x'].rangeBand() / 2

            g.append("svg:line")
            .attr("class", "line dashed")
            .attr("x1", left).attr("x2", left)
            .attr("y1", 0).attr("y2", @height)
            .attr("style", "stroke-dasharray: 10, 5;")

            # Traverse the a, b series.
            j = 0 ; end = 0
            for series, value of group['data']
                # Calculate the distances.
                width =  domain['x'].rangeBand() / group['data'].length
                left =   domain['x'](index) + (j * width)
                height = domain['y'](value)
                # ColorBrewer band.
                color =  domain['color'](value).toFixed(0)

                # Append the actual rectangle.
                bar = g.append("svg:rect")
                .attr("class",  "bar #{Chart.series[series]} q#{color}-#{@colorbrewer}")
                .attr('x',      @axisMargin + left)
                .attr('y',      @height - height)
                .attr('width',  width)
                .attr('height', height)

                # Add a text value.
                w = values.append("svg:g").attr('class', "g#{index} #{Chart.series[series]}")

                y = parseFloat @height - height - 1
                
                text = w.append("svg:text")
                .attr('x', @axisMargin + left + (width / 2))
                .attr("text-anchor", "middle")
                .text value

                # Maybe the value is too 'high' and would be left off the grid?
                if y < 15
                    text.attr('y', y + 15)
                    # Maybe it is also too wide and thus stretches beyond the bar?
                    if text.node().getComputedTextLength() > width
                        text.attr("class", "value on beyond")
                    else
                        text.attr("class", "value on")
                else
                    text.attr('y', y)
                    text.attr("class", "value above")

                # Add a title element for the value.
                w.append("svg:title").text value

                # Attach onclick event.
                if @onclick?
                    do (bar, group, j, value) =>
                        bar.on 'click', => @onclick group['description'], j, value

                # Save the total distance from the left till the (right) end of the bar.
                end = left + width + @axisMargin

                j++
            
            # Add an onhover showing tooltip description text.
            g.append("svg:title").text group['description']

            # Update the position of the description text wrapping `g` element.
            x = @axisMargin + left + width ; y = @height + @textHeight
            descG = descriptions.select(".g#{index}")
            .attr('transform', "translate(#{x},#{y})")
            
            # (A better) naive fce to determine if we should rotate the text.
            if descWidth > width
                desc = descG.select("text")
                desc.attr("transform", "rotate(-30 0 0)")
                # Maybe still, it is one of the first descriptions and is longer than the distance from left (margin + x + width + translate).
                while (desc.node().getComputedTextLength() * 0.866025) > end
                    # Trim the text.
                    desc.text desc.text().replace('...', '').split('').reverse()[1..].reverse().join('') + '...'


class Chart.Legend

    # Expand object values on us.
    constructor: (o) ->
        @[k] = v for k, v of o

    render: () ->
        $(@el).append ul = $('<ul/>')

        for index, name of @series
            ul.append $('<li/>',
                'class': Chart.series[index]
                'html':  name
                'click': (e) => @_clickAction e.target, index
            )

    # Onclick on legend series.
    _clickAction: (el, series) ->
        # Toggle the disabled state.
        $(el).toggleClass 'disabled'

        # Change the opacity to 'toggle' the series bars.
        d3.select(@chart[0]).selectAll("rect.bar.#{Chart.series[series]}")
        .attr('fill-opacity', () -> if $(el).hasClass 'disabled' then 0.2 else 1 )