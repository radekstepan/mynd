Chart = {}


# A vertical bar chart that is rendered within the browser using SVG.
class Chart.Column

    # Are we drawing a stacked chart?
    isStacked:         false

    # Number of ColorBrewer classes.
    colorbrewer:       4

    # Padding between elements.
    padding:
        # ...nudge bar text above/below bar
        'barValue':    2 # px
        # ...axis labels
        'axisLabels':  5 # px
        # ...space between bars
        'barPadding':  0.05 # [0..1]

    # The ticks/the numbers axis.
    ticks:
        # The number of ticks axis should have (roughly).
        'count':       10

    # Description...
    description:
        # ... rotation triangle (http://www.calculatorsoup.com/calculators/geometry-plane/triangle-theorems.php).
        'triangle':
            'degrees': 30
            'sideA':   0.5
            'sideB':   0.866025

    # Expand object values on us.
    constructor: (o) ->
        @[k] = v for k, v of o

        # Update the height of the outer element.
        $(@el).css 'height', @height

    render: () ->
        height = @height ; width = @width

        # Clear any previous content.
        $(@el).empty()

        # Create the chart wrapper.
        canvas = d3.select(@el[0])
        .append('svg:svg') # append svg
        .attr('class', 'canvas')

        # -------------------------------------------------------------------
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

        # -------------------------------------------------------------------
        # Axis Labels?
        if @axis?
            labels = canvas.append('svg:g').attr('class', 'labels')
            if @axis.horizontal?
                text = labels.append("svg:text")
                    .attr("class",       "horizontal")
                    .attr("text-anchor", "middle")
                    .attr("x",           width / 2)
                    .attr("y",           height - @padding.axisLabels)
                    .text @axis.horizontal

                # Adjust the size of the remaining area.
                height = height - text.node().getBBox().height - @padding.axisLabels

            if @axis.vertical?
                text = labels.append("svg:text")
                    .attr("class",       "vertical")
                    .attr("text-anchor", "middle")
                    .attr("x",           0)
                    .attr("y",           height / 2)
                    .text @axis.vertical

                verticalAxisLabelHeight = text.node().getBBox().height
                text.attr("transform",   "rotate(-90 #{verticalAxisLabelHeight} #{height / 2})")

                # Adjust the size of the remaining area.
                width = width - verticalAxisLabelHeight - @padding.axisLabels

        # -------------------------------------------------------------------
        # Descriptions.
        descriptions = canvas.append('svg:g').attr('class', 'descriptions')
        @description.maxWidth = -Infinity ; @description.totalWidth = 0 ; descriptionTextHeight = 0
        for index, group of @data
            # Wrapper for the text and title.
            g = descriptions.append("svg:g")
            .attr("class", "g#{index}")
            
            # Text.
            text = g.append("svg:text")
                .attr("class",       "text")
                .attr("text-anchor", "end")
                .text group.description

            # Update the max width.
            textWidth = text.node().getComputedTextLength()
            @description.maxWidth = textWidth if textWidth > @description.maxWidth
            # Update the total width.
            @description.totalWidth = @description.totalWidth + textWidth

            # Add an onhover description title.
            g.append("svg:title").text group.description

            # Save the text height.
            if descriptionTextHeight is 0 then descriptionTextHeight = text.node().getBBox().height

        # -------------------------------------------------------------------
        
        # Reduce the chart space by accomodating the description.
        height = height - descriptionTextHeight

        # Add a wrapping `g` for the grid ticks and lines.
        grid = canvas.append("svg:g").attr("class", "grid")

        # Init the domain, with ticks for now.
        domain = {}
        domain.ticks = do () =>
            # Modify ticks to use whole numbers where appropriate.
            ( t for t in d3.scale.linear().domain([ 0, @maxValue ]).ticks(@ticks.count) when ( (parseInt(t) is t) or !@useWholeNumbers ) )

        # -------------------------------------------------------------------
        # Render the tick numbers so we can get the @ticks.maxWidth.
        # The width (from left) to be left for axis numbers.
        @ticks.maxWidth = -Infinity
        for index, tick of domain.ticks
            t = grid.append("svg:g").attr('class', "t#{index}")
            
            text = t.append("svg:text")
            .attr("class",       "tick")
            .attr("text-anchor", "begin")
            .attr("x",           0)
            .text tick

            # Update the max width.
            textWidth = text.node().getComputedTextLength()
            @ticks.maxWidth = textWidth if textWidth > @ticks.maxWidth

        # -------------------------------------------------------------------
        
        # Now that we know the width of the axis, reduce the area width.
        width = width - @ticks.maxWidth

        # Will we (probably) need to rotate the descriptions? Then reduce the @height by the height of one side of the triangle created by a 30 deg rotation.
        if @description.totalWidth > width then height = height - (@description.maxWidth * @description.triangle.sideA)

        # Update the location of the vertical axis label if present.
        if @axis?.vertical?
            labels.select('.vertical')
            .attr("transform",   "rotate(-90 #{verticalAxisLabelHeight} #{height / 2})")
            .attr("y",           height / 2)

        # -------------------------------------------------------------------
        # Get the domain as @width & @height are fixed now.
        domain.x =     d3.scale.ordinal().domain([0..@data.length - 1]).rangeBands([ 0, width ], @padding.barPadding)
        domain.y =     d3.scale.linear().domain([ 0, @maxValue ]).range([ 0, height ])
        domain.color = d3.scale.linear().domain([ 0, @maxValue ]).rangeRound([ 0, @colorbrewer - 1 ])

        # -------------------------------------------------------------------
        # Horizontal lines among ticks.
        for index, tick of domain.ticks
            # Get the wrapping `g`.
            t = grid.select(".t#{index}")

            # Draw the line
            t.append("svg:line")
            .attr("class", "line")
            .attr("x1",    @ticks.maxWidth)
            .attr("x2",    width + @ticks.maxWidth)

            # Update the position of the wrapping `g` to shift both ticks and lines.
            t.attr 'transform', "translate(0,#{height - domain['y'](tick)})"

        # -------------------------------------------------------------------

        # Chart `g`.
        chart = canvas.append("svg:g").attr("class", "chart")

        # -------------------------------------------------------------------
        # The bars.
        bars = chart.append("svg:g").attr("class", "bars") ; values = chart.append("svg:g").attr("class", "values")
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
                    .attr("y2",    height)

            # -------------------------------------------------------------------
            # Traverse the data in the series.
            y = height
            for series, value of group.data
                # Height.
                barHeight = domain['y'](value)

                # Skip bars that do not show anything if we are a stacked chart.
                if not barHeight and @isStacked then continue

                # From the left.
                x = domain['x'](index) + @ticks.maxWidth
                if !@isStacked then x = x + (series * barWidth)
                
                # For unstacked bars, always from the bottom...
                if !@isStacked then y = height
                # ...otherwise adjust from the last position.
                y = y - barHeight
                
                # ColorBrewer band.
                color = domain['color'](value).toFixed(0)

                # -------------------------------------------------------------------
                # Append the actual rectangle.
                bar = g.append("svg:rect")
                .attr("class",  "bar s#{series} q#{color}-#{@colorbrewer}")
                .attr('x',      x)
                .attr('y',      y)
                .attr('width',  barWidth)
                .attr('height', barHeight)
                
                bar.transition().attr('opacity', 1)

                # Add a text value.
                w = values.append("svg:g").attr('class', "g#{index} s#{series} q#{color}-#{@colorbrewer}")
                
                # Add a text in the middle of the bar.
                text = w.append("svg:text")
                .attr('x',           x + (barWidth / 2))
                .attr("text-anchor", "middle")
                .text value

                # -------------------------------------------------------------------

                if @isStacked
                    ty = y + text.node().getBBox().height + @padding.barValue

                    text.attr('y', ty)
                    if text.node().getComputedTextLength() > barWidth
                        text.attr("class", "value on beyond")
                    else
                        text.attr("class", "value on")
                else
                    ty = y - @padding.barValue

                    barValueHeight = text.node().getBBox().height

                    # Maybe the value is too 'high' and would be left off the grid?
                    if ty < barValueHeight
                        text.attr('y', ty + barValueHeight)
                        # Maybe it is also too wide and thus stretches beyond the bar?
                        if text.node().getComputedTextLength() > barWidth
                            text.attr("class", "value on beyond")
                        else
                            text.attr("class", "value on")
                    else
                        text.attr('y', ty)
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
            descG = descriptions.select(".g#{index}")
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
            descG.attr('transform', "translate(#{x},#{height + descriptionTextHeight})")

        # If we have used vertical axis, shift the whole shebang to the right.
        if @axis?.vertical?
            grid.attr('transform', "translate(#{verticalAxisLabelHeight + @padding.axisLabels}, 0)")
            chart.attr('transform', "translate(#{verticalAxisLabelHeight + @padding.axisLabels}, 0)")
            descriptions.attr('transform', "translate(#{verticalAxisLabelHeight + @padding.axisLabels}, 0)")


class Chart.Legend

    # Expand object values on us.
    constructor: (o) ->
        @[k] = v for k, v of o

    render: () ->
        $(@el).append ul = $('<ul/>')

        for index, name of @series then do (index, name) =>
            ul.append $('<li/>',
                'class': 's' + index
                'html':  name
                'click': (e) => @clickAction e.target, index
            )

    # Onclick on series legend.
    clickAction: (el, series) ->
        # Toggle the disabled state.
        $(el).toggleClass 'disabled'

        # Change the opacity to 'toggle' the series bars.
        d3.select(@chart[0]).selectAll(".s#{series}")
        .transition().attr('fill-opacity', () -> if $(el).hasClass 'disabled' then 0.1 else 1 )


class Chart.Settings

    # Expand object values on us.
    constructor: (o) ->
        @[k] = v for k, v of o

    render: () ->
        # Is the chart stacked?
        stacked = $(@el).append $('<a/>',
            'class': "btn btn-mini stacked #{if @isStacked then 'active' else ''}"
            'text':  if @isStacked then 'Unstack' else 'Stack'
            'click': (e) =>
                $(e.target).toggleClass 'active'
                if $(e.target).hasClass 'active'
                    @chart.isStacked = true ; $(e.target).text('Unstack')
                else
                    @chart.isStacked = false ; $(e.target).text('Stack')
                @chart.render()
        )