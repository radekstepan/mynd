Chart =
    # The names of consecutive series.
    'series': [ 'first', 'second', 'third', 'fourth', 'fifth' ]


class Chart.Bars

    # Number of ColorBrewer classes.
    colorbrewer:       4

    # Assumed height of text.
    textHeight:        10

    # The ticks/the numbers axis.
    ticks:
        # The width (from left) to be left for axis numbers.
        'maxWidth':    -Infinity
        # The number of ticks axis should have (roughly).
        'count':       10

    # Description...
    description:
        # ... maximum width.
        'maxWidth':    -Infinity
        # ... total width.
        'totalWidth':  0
        # ... rotation triangle (http://www.calculatorsoup.com/calculators/geometry-plane/triangle-theorems.php).
        'triangle':
            'degrees': 30
            'sideA':   0.5
            'sideB':   0.866025

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
            @description.maxWidth = width if width > @description.maxWidth
            # Update the total width.
            @description.totalWidth = @description.totalWidth + width

            # Add an onhover description title.
            g.append("svg:title").text group['description']

        # Reduce the chart space by accomodating the description.
        @height = @height - @textHeight

        # Add a wrapping `g` for the grid ticks and lines.
        @grid = @canvas.append("svg:g").attr("class", "grid")

        # Render the tick numbers so we can get the @ticks.maxWidth (slightly inaccurate as the @height might change).
        for index, tick of d3.scale.linear().domain([ 0, @maxValue ]).range([ 0, @height ]).ticks(@ticks.count)
            if (parseInt(tick) is tick) or (!@useWholeNumbers)
                t = @grid.append("svg:g").attr('class', "t#{index}")
                
                text = t.append("svg:text")
                .attr("class", "tick")
                .attr("x", 0)
                .attr("text-anchor", "begin")
                .text tick.toFixed(0)

                # Update the max width.
                width = text.node().getComputedTextLength()
                @ticks.maxWidth = width if width > @ticks.maxWidth

        # Now that we know the width of the axis, reduce the width.
        @width = @width - @ticks.maxWidth

        # Will we (probably) need to rotate the descriptions? Then reduce the @height by the height of one side of the triangle created by a 30 deg rotation.
        if @description.totalWidth > @width then @height = @height - (@description.maxWidth * @description.triangle.sideA)

        # Get the domain as @width & @height are fixed now.
        domain =
            'x':     d3.scale.ordinal().domain([0..@data.length - 1]).rangeBands([ 0, @width ], .05)
            'y':     d3.scale.linear().domain([ 0, @maxValue ]).range([ 0, @height ])
            'color': d3.scale.linear().domain([ 0, @maxValue ]).range([ 0, @colorbrewer - 1 ])

        # Horizontal lines.
        for index, tick of domain['y'].ticks(@ticks.count)
            if (parseInt(tick) is tick) or (!@useWholeNumbers)
                # Get the wrapping `g`.
                t = @grid.select(".t#{index}")

                # Draw the line
                t.append("svg:line")
                .attr("class", "line")
                .attr("x1",    @ticks.maxWidth)
                .attr("x2",    @width)

                # Update the position of the wrapping `g`.
                t.attr 'transform', "translate(0,#{@height - domain['y'](tick)})"

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
            left = @ticks.maxWidth + domain['x'](index) + domain['x'].rangeBand() / 2

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
                .attr('x',      @ticks.maxWidth + left)
                .attr('y',      @height - height)
                .attr('width',  width)
                .attr('height', height)

                # Add a text value.
                w = values.append("svg:g").attr('class', "g#{index} #{Chart.series[series]}")

                y = parseFloat @height - height - 1
                
                text = w.append("svg:text")
                .attr('x', @ticks.maxWidth + left + (width / 2))
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
                end = left + width + @ticks.maxWidth

                j++
            
            # Add an onhover showing tooltip description text.
            g.append("svg:title").text group['description']

            # Update the position of the description text wrapping `g` element.
            x = @ticks.maxWidth + left + width ; y = @height + @textHeight
            descG = descriptions.select(".g#{index}")
            .attr('transform', "translate(#{x},#{y})")
            
            # (A better) naive fce to determine if we should rotate the text.
            if @description.maxWidth > width
                desc = descG.select("text")
                desc.attr("transform", "rotate(-#{@description.triangle.degrees} 0 0)")
                # Maybe still, it is one of the first descriptions and is longer than the distance from left (margin + x + width + translate).
                while (desc.node().getComputedTextLength() * @description.triangle.sideB) > end
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