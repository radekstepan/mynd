Chart =
    # The names of consecutive series.
    'series': [ 'first', 'second', 'third', 'fourth', 'fifth' ]


# A vertical bar chart that is rendered within the browser using SVG.
class Chart.Column

    # Are we drawing a stacked chart?
    isStacked:         false

    # Number of ColorBrewer classes.
    colorbrewer:       4

    # Assumed height of text.
    textHeight:        10

    # Constant to nudge text above/below bar.
    pisvejc:           2

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
        if @isStacked
            for group in @data
                groupValue = 0
                for key, value of group.data
                    # Does the chart only contain whole numbers?
                    @useWholeNumbers = false if parseInt(value) isnt value
                    groupValue = groupValue + value
                
                # Get a maximum value as a sum from a group.
                @maxValue = groupValue if groupValue > @maxValue
        else
            for group in @data
                for key, value of group.data
                    # Does the chart only contain whole numbers?
                    @useWholeNumbers = false if parseInt(value) isnt value
                    # Get a maximum value from all series.
                    @maxValue = value if value > @maxValue

        # Update the height of the outer element.
        $(@el).css 'height', @height

        # Create the chart wrapper.
        @canvas = d3.select(@el[0])
        .append('svg:svg') # append svg
        .attr('class', 'canvas')

    render: () ->
        # -------------------------------------------------------------------
        # Descriptions.
        @descriptions = @canvas.append('svg:g').attr('class', 'descriptions')
        for index, group of @data
            # Wrapper for the text and title.
            g = @descriptions.append("svg:g")
            .attr("class", "g#{index}")
            
            # Text.
            text = g.append("svg:text")
                .attr("class",       "text")
                .attr("text-anchor", "end")
                .text group.description

            # Update the max width.
            width = text.node().getComputedTextLength()
            @description.maxWidth = width if width > @description.maxWidth
            # Update the total width.
            @description.totalWidth = @description.totalWidth + width

            # Add an onhover description title.
            g.append("svg:title").text group.description

        # -------------------------------------------------------------------
        
        # Reduce the chart space by accomodating the description.
        @height = @height - @textHeight

        # Add a wrapping `g` for the grid ticks and lines.
        @grid = @canvas.append("svg:g").attr("class", "grid")

        # Init the domain, with ticks for now.
        domain = {}
        domain.ticks = do () =>
            # Modify ticks to use whole numbers where appropriate.
            ( t for t in d3.scale.linear().domain([ 0, @maxValue ]).ticks(@ticks.count) when ( (parseInt(t) is t) or !@useWholeNumbers ) )

        # -------------------------------------------------------------------
        # Render the tick numbers so we can get the @ticks.maxWidth.
        for index, tick of domain.ticks
            t = @grid.append("svg:g").attr('class', "t#{index}")
            
            text = t.append("svg:text")
            .attr("class",       "tick")
            .attr("text-anchor", "begin")
            .attr("x",           0)
            .text tick

            # Update the max width.
            width = text.node().getComputedTextLength()
            @ticks.maxWidth = width if width > @ticks.maxWidth

        # -------------------------------------------------------------------
        
        # Now that we know the width of the axis, reduce the width.
        @width = @width - @ticks.maxWidth

        # Will we (probably) need to rotate the descriptions? Then reduce the @height by the height of one side of the triangle created by a 30 deg rotation.
        if @description.totalWidth > @width then @height = @height - (@description.maxWidth * @description.triangle.sideA)

        # Get the domain as @width & @height are fixed now.
        domain.x =     d3.scale.ordinal().domain([0..@data.length - 1]).rangeBands([ 0, @width ], .05)
        domain.y =     d3.scale.linear().domain([ 0, @maxValue ]).range([ 0, @height ])
        domain.color = d3.scale.linear().domain([ 0, @maxValue ]).range([ 0, @colorbrewer - 1 ])

        # -------------------------------------------------------------------
        # Horizontal lines among ticks.
        for index, tick of domain.ticks
            # Get the wrapping `g`.
            t = @grid.select(".t#{index}")

            # Draw the line
            t.append("svg:line")
            .attr("class", "line")
            .attr("x1",    @ticks.maxWidth)
            .attr("x2",    @width + @ticks.maxWidth)

            # Update the position of the wrapping `g` to shift both ticks and lines.
            t.attr 'transform', "translate(0,#{@height - domain['y'](tick)})"

        # -------------------------------------------------------------------

        # Chart `g`.
        @chart = @canvas.append("svg:g").attr("class", "chart")

        # -------------------------------------------------------------------
        # The bars.
        bars = @chart.append("svg:g").attr("class", "bars") ; values = @chart.append("svg:g").attr("class", "values")
        for index, group of @data
            # A wrapper group.
            g = bars
            .append("svg:g")
            .attr("class", "g#{index}")
            
            # The width of the bar.
            barWidth = domain['x'].rangeBand()
            # Split among the number of series we have.
            if !@isStacked then barWidth = barWidth / group['data'].length

            # -------------------------------------------------------------------
            # Place vertical line on unstacked chart of two series.
            if !@isStacked and group['data'].length is 2
                do () =>
                    # Get the distance 'x' from left for the vertical line.
                    x = @ticks.maxWidth + domain['x'](index) + barWidth
                    
                    # The actual line.
                    g.append("svg:line")
                    .attr("class", "line dashed")
                    .attr("style", "stroke-dasharray: 10, 5;")
                    .attr("x1",    x)
                    .attr("x2",    x)
                    .attr("y1",    0)
                    .attr("y2",    @height)

            # -------------------------------------------------------------------
            # Traverse the data in the series.
            barHeight = 0
            for series, value of group.data
                # Height.
                previousHeight = barHeight ; barHeight = domain['y'](value)

                # From the left.
                x = domain['x'](index) + @ticks.maxWidth
                if !@isStacked then x = x + (series * barWidth)
                
                # From the top.
                y = @height - barHeight
                if @isStacked then y = y - previousHeight
                
                # ColorBrewer band.
                color = domain['color'](value).toFixed(0)

                # -------------------------------------------------------------------
                # Append the actual rectangle.
                bar = g.append("svg:rect")
                .attr("class",  "bar #{Chart.series[series]} q#{color}-#{@colorbrewer}")
                .attr('x',      x)
                .attr('y',      y)
                .attr('width',  barWidth)
                .attr('height', barHeight)

                # Add a text value.
                w = values.append("svg:g").attr('class', "g#{index} #{Chart.series[series]}")
                
                # Add a text in the middle of the bar.
                text = w.append("svg:text")
                .attr('x',           x + (barWidth / 2))
                .attr("text-anchor", "middle")
                .text value

                # -------------------------------------------------------------------

                if @isStacked
                    y = y + @textHeight + @pisvejc
                else
                    # Distance from top for the value.
                    y = y - @pisvejc

                if @isStacked
                    text.attr('y', y)
                    if text.node().getComputedTextLength() > barWidth
                        text.attr("class", "value on beyond")
                    else
                        text.attr("class", "value on")
                else
                    # Maybe the value is too 'high' and would be left off the grid?
                    if y < 15
                        text.attr('y', y + 15)
                        # Maybe it is also too wide and thus stretches beyond the bar?
                        if text.node().getComputedTextLength() > barWidth
                            text.attr("class", "value on beyond")
                        else
                            text.attr("class", "value on")
                    else
                        text.attr('y', y)
                        text.attr("class", "value above")

                # Add a title element for the value.
                w.append("svg:title").text value

                # Attach onclick event for the bar.
                if @onclick?
                    do (bar, group, series, value) =>
                        bar.on 'click', => @onclick group.description, series, value
            
            # Add an onhover showing tooltip description text.
            g.append("svg:title").text group.description
            
            # -------------------------------------------------------------------
            # (A better) naive fce to determine if we should rotate the text.
            descG = @descriptions.select(".g#{index}")
            desc =  descG.select("text")
            if @description.maxWidth > barWidth
                desc.attr("transform", "rotate(-#{@description.triangle.degrees} 0 0)")

                # The text will be pointing towards the end of the group.
                x = x + barWidth

                # Maybe still, it is one of the first descriptions and is longer than the distance from left (margin + x + width + translate).
                while (desc.node().getComputedTextLength() * @description.triangle.sideB) > x
                    # Trim the text.
                    desc.text desc.text().replace('...', '').split('').reverse()[1..].reverse().join('') + '...'
            else
                # The text will be in the middle of the group.
                x = (x + barWidth) - 0.5 * ( barWidth * group.data.length )

                # Update the anchor.
                desc.attr("text-anchor", "middle")
            
            # Update the position of the description text wrapping `g` element.
            descG.attr('transform', "translate(#{x},#{@height + @textHeight})")


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
                'click': (e) => @clickAction e.target, index
            )

    # Onclick on series legend.
    clickAction: (el, series) ->
        # Toggle the disabled state.
        $(el).toggleClass 'disabled'

        # Change the opacity to 'toggle' the series bars.
        d3.select(@chart[0]).selectAll("rect.bar.#{Chart.series[series]}")
        .attr('fill-opacity', () -> if $(el).hasClass 'disabled' then 0.2 else 1 )