## Mynd/Chart means/þýðir chart/mynd in/í icelandic/íslensku
window.Mynd = {} 
Mynd.Scale = {}
Mynd.Chart = {}

Mynd.VERSION = '0.1.0'

# Selects the first element that matches the specified selector string, returning a single-element selection. If no
#  elements in the current document match the specified selector, returns the empty selection. If multiple elements match
#  the selector, only the first matching element (in document traversal order) will be selected.
Mynd.select = (selector) ->
    if typeof selector is "string"
        (new Selection([ document ])).select selector
    else
        # Select single node.
        new Selection [ [ selector ] ]

# Selects all elements that match the specified selector. The elements will be selected in document traversal order
#  (top-to-bottom). If no elements in the current document match the specified selector, returns the empty selection.
Mynd.selectAll = (selector) ->
    if typeof selector is "string"
        (new Selection([ document ])).selectAll(selector)
    else
        throw new Error 'Mynd.selectAll(Nodes): this function is not implemented'

# Ordinal scales have a discrete domain (chart bars).
Mynd.Scale.ordinal = ->
    ( ->
        internal = {}

        # Given a value `x` in the input domain, returns the corresponding value in the output range.
        scale = (x) ->
            if not internal.range? then throw new Error 'Mynd.Scale.ordinal: you need to set input range first'
            
            internal.range[x]

        # Sets the input domain of the ordinal scale to the specified array of values. The first element in values will
        #  be mapped to the first element in the output range, the second domain value to the second range value, and so
        #  on.
        # Example: [0..5] for 5 chart bars
        scale.setDomain = (domain = []) ->
            # Make sure the domain is actually discrete.
            d = {}
            for element in domain then d[element] = element
            internal.domain = (value for key, value of d)

            scale

        # Sets the output range from the specified continuous interval. The array interval contains two elements
        #  representing the minimum and maximum numeric value. This interval is subdivided into n evenly-spaced bands,
        #  where n is the number of (unique) values in the domain.

        # The `bands` may be offset from the edge of the interval and other bands according to the specified padding,
        #  which defaults to zero.
        # Example: [0, 400] for a column chart 400px wide

        # The `padding` is in the range [0,1] and corresponds to the amount of space in the range interval to allocate
        #  to padding.
        scale.setRangeBands = (bands, padding = 0) ->
            if not internal.domain? then throw new Error 'Mynd.Scale.ordinal: you need to set input domain first'

            start = bands[0] ; stop = bands[1]
            
            # Do we need to reverse the range?
            reverse = bands[1] < bands[0]
            [stop, start] = [start, stop] if reverse

            step = (stop - start) / (internal.domain.length + padding)

            range = [0...internal.domain.length].map (i) -> (start + (step * padding)) + (step * i)
            range.reverse() if reverse

            internal.range = range
            internal.rangeBand = step * (1 - padding)

            scale

        # Returns the band width.
        scale.getRangeBand = -> internal.rangeBand

        scale.setDomain()
    )()

# Linear scales map a continuous input domain to a continuous output range.
Mynd.Scale.linear = ->
    ( ->
        internal = {}

        # Returns a numeric deinterpolator between two numbers `a` and `b` representing the domain (bar min/max values).
        deinterpolate = (a, b) ->
            (x) -> (x - a) * 1 / (b - a)

        # Returns a numeric interpolator between the two numbers `a` and `b` representing the range (column chart height).
        interpolate = (a, b, round) ->
            if round
                (x) -> Math.round a + b * x
            else
                (x) -> a + b * x

        scaleBilinear = (domain, range, round) ->
            (x) -> interpolate(range[0], range[1], round)( deinterpolate(domain[0], domain[1])( x ) )
        
        scale = (x) ->
            if not internal.output?
                # Set domain and range?
                if internal.domain? and internal.range?
                    # ...then apply bilinear scale de/interpolator.
                    internal.output = scaleBilinear internal.domain, internal.range, internal.round
                else
                    throw new Error 'Mynd.Scale.linear: you need to set both input domain and range'

            internal.output x

        # Set the scale's input domain to the specified array of numbers.
        # Example: [0, 2] for bar values ranging from 0 to a maximum of 2
        scale.setDomain = (domain) -> internal.domain = domain ; scale

        # Sets the scale's output range to the specified array of values.
        # Enable `round` to get round numbers avoid antialiasing artifacts.
        # Example: [0, 100] for a column chart bar that is to be at most 100px tall.
        scale.setRange = (range, round=false) ->
            internal.range = range
            internal.round = round

            scale

        # Returns approximately count representative values from the scale's input domain. The returned tick values are
        #  uniformly spaced, have human-readable values (such as multiples of powers of 10), and are guaranteed to be
        #  within the extent of the input domain.
        scale.getTicks = (amount) ->
            if not internal.domain? then throw new Error 'Mynd.Scale.linear: you need to set input domain first'

            start = internal.domain[0] ; stop = internal.domain[1]

            # Do we need to reverse the domain?
            reverse = internal.domain[1] < internal.domain[0]
            [stop, start] = [start, stop] if reverse

            span = stop - start
            step = Math.pow( 10, Math.floor( Math.log( span / amount ) / Math.LN10 ) )

            # Adjust the step.
            x = amount / span * step
            if x <= .15 then step *= 10
            else if x <= .35 then step *= 5
            else if x <= .75 then step *= 2
            
            # Create the ticks list.
            ticks = []
            x = Math.ceil(start / step) * step
            (ticks.push x ; x += step) while x <= Math.floor(stop / step) * step + step * .5

            ticks

        scale
    )()


# Selection backed by an Array.
class Selection

    # Event.
    event: null

    # Elements in the selection backed by an Array.
    constructor: (@elements=[]) ->

    # Quality element with SVG prefix or without.
    qualify: (name) ->
        if (!index = name.indexOf('svg:'))
            return {
                space: 'http://www.w3.org/2000/svg'
                local: name[4...]
            }
        else
            return name

    # Selects the first element that matches the specified selector string, returning a single-element selection. If no
    #  elements in the current document match the specified selector, returns the empty selection. If multiple elements match
    #  the selector, only the first matching element (in document traversal order) will be selected.
    select: (selector) ->
        if typeof selector isnt "function" then selector = do (selector) -> ( -> @.querySelector selector )

        subgroups = []
        for i in [0...@elements.length]
            subgroups.push subgroup = []
            
            # For all subgroups.
            for j in [0...@elements[i].length]
                if node = @elements[i][j]
                    subgroup.push subnode = selector.call(node, node.__data__, j)
                    subnode.__data__ = node.__data__ if subnode and "__data__" of node
                else
                    subgroup.push null

        new Selection subgroups

    # Selects all elements that match the specified selector. The elements will be selected in document traversal order
    #  (top-to-bottom). If no elements in the current document match the specified selector, returns the empty selection.
    selectAll: (selector) ->
        subgroups = []
        if typeof selector isnt "function"
            selector = do (selector) -> ( -> @.querySelectorAll selector )

        for i in [0...@elements.length]
            for j in [0...@elements[i].length]
                if node = @elements[i][j]
                    subgroups.push subgroup = Array::slice.call selector.call(node, node.__data__, j)
        
        new Selection subgroups

    # Appends a new element with the specified name as the last child of each element in the current selection. Returns a new
    #  selection containing the appended elements. Each new element inherits the data of the current elements, if any, in the
    #  same manner as select for subselections. The name must be specified as a constant, though in the future we might allow
    #  appending of existing elements or a function to generate the name dynamically.
    # If value is not specified, returns the value of the specified attribute for the first non-null element in the selection.
    #  This is generally useful only if you know that the selection contains exactly one element.
    append: (name) ->
        name = @qualify name

        if name.local
            @select -> @appendChild document.createElementNS(name.space, name.local)
        else
            @select -> @appendChild document.createElementNS(@namespaceURI, name)

    # Invokes the specified function for each element in the current selection, passing in the current data, index, context of
    #  the current DOM element.
    each: (callback) ->
        for i in [0...@elements.length]
            for j in [0...@elements[i].length]
                node = @elements[i][j]
                callback.call node, node.__data__, i, j if node
      
        @

    # If value is specified, sets the attribute with the specified name to the specified value on all selected elements. If
    #  value is a constant, then all elements are given the same attribute value; otherwise, if value is a function, then the
    #  function is evaluated for each selected element (in order), being passed the current datum d and the current index `i`,
    #  with the `this` context as the current DOM element. The function's return value is then used to set each element's
    #  attribute. A null value will remove the specified attribute.
    attr: (name, value) ->      
        name = @qualify name

        @each do ->
            if not value?
                if name.local
                    -> @removeAttributeNS name.space, name.local
                else
                    -> @removeAttribute name
            else
                if typeof value is "function"
                    if name.local
                        ->
                            x = value.apply(@, arguments)
                            unless x?
                                @removeAttributeNS name.space, name.local
                            else
                                @setAttributeNS name.space, name.local, x
                    else
                        ->
                            x = value.apply(@, arguments)
                            unless x?
                                @removeAttribute name
                            else
                                @setAttribute name, x
                else
                    if name.local
                        -> @setAttributeNS name.space, name.local, value
                    else
                        -> @setAttribute name, value

    # Gets a computed property value (defined by CSS) on an element by `name`.
    css: (name) ->
        window.getComputedStyle(@node(), null).getPropertyValue name

    # Get or set text content.
    text: (value) ->
        return @node().textContent unless value?
        
        @each do ->
            if typeof value is "function"
                -> @textContent = value.apply(@, arguments) or ''
            else
                -> @textContent = value

    # Returns the first non-null element in the current `@elements` selection or null.
    node: (callback) ->
        for i in [0..@elements.length]
            for j in [0..@elements[i].length]
                return @elements[i][j] if @elements[i][j]?
        
        null

    # Adds or removes an event listener to each element in the current selection, for the specified type.
    #  `type` is a string event type name, such as "click", "mouseover", or "submit".
    #  `listener` is invoked in the same manner as other operator functions, being passed the current datum, index and context
    #  (the current DOM element).
    on: (type, listener) ->
        name = "__on#{type}"
      
        # If listener is not specified, returns the currently-assigned listener for the specified type, if any (untested).
        return (i = @node()[name])._ unless listener?
      
        @each (x, index) ->
            # The object that receives a notification when an event of the specified type occurs.
            eventListener = (event) =>
                # Backup current event.
                bak = Selection.event
                # Current event.
                Selection.event = event
                try
                    # The specified listener is invoked passing current datum, index and element context.
                    listener.call @, @.__data__, index
                finally
                    # Save back.
                    Selection.event = bak
            
            o = @[name]
            # Remove event listeners from the event target.
            if o
                @.removeEventListener type, o, o.$
                delete @[name]
            
            # Register a single event listener on a single target.
            if listener
                @.addEventListener type, @[name] = eventListener, eventListener.$ = false # W3C useCapture flag
                # Save it so we can retrieve it later.
                eventListener._ = listener


# A vertical bar chart that is rendered within the browser using SVG.
class Mynd.Chart.column

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

    # Series and their visibility on us.
    series: {}

    # Expand object values on us.
    constructor: (o) ->
        @[k] = v for k, v of o

        # Update the height of the outer element.
        $(@el).css 'height', @height

    render: () ->
        # Preserve the original.
        height = @height ; width = @width

        # Clear any previous content.
        $(@el).empty()

        # Create the chart wrapper.
        canvas = Mynd.select(@el[0])
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

                # Make properties explicit.
                text.attr 'fill'       , text.css 'fill'
                text.attr 'font-size'  , text.css 'font-size'
                text.attr 'font-family', text.css 'font-family'

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

                # Make properties explicit.
                text.attr 'fill'       , text.css 'fill'
                text.attr 'font-size'  , text.css 'font-size'
                text.attr 'font-family', text.css 'font-family'

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

            # Make properties explicit.
            text.attr 'fill'       , text.css 'fill'
            text.attr 'font-size'  , text.css 'font-size'
            text.attr 'font-family', text.css 'font-family'

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
            ( t for t in Mynd.Scale.linear().setDomain([ 0, @maxValue ]).getTicks(@ticks.count) when ( (parseInt(t) is t) or !@useWholeNumbers ) )

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

            # Make properties explicit.
            text.attr 'fill'       , text.css 'fill'
            text.attr 'font-size'  , text.css 'font-size'
            text.attr 'font-family', text.css 'font-family'

        # Now that we know the width of the axis, reduce the area width.
        width = width - @ticks.maxWidth

        # -------------------------------------------------------------------
        # Get the domain.
        domain.x =     Mynd.Scale.ordinal().setDomain([0...@data.length]).setRangeBands([ 0, width ], @padding.barPadding)
        
        # Given this domain and subsequent bar width, will we need to rotate text?
        if @description.maxWidth > domain['x'].getRangeBand()
            # ...then reduce the @height by the height of one side of the triangle created by a (future) 30 deg text rotation.
            height = height - (@description.maxWidth * @description.triangle.sideA)

        # Height is fixed now.
        domain.y =     Mynd.Scale.linear().setDomain([ 0, @maxValue ]).setRange([ 0, height ])
        # Color was never an issue.
        domain.color = Mynd.Scale.linear().setDomain([ 0, @maxValue ]).setRange([ 0, @colorbrewer - 1 ], true)

        # -------------------------------------------------------------------
        # Horizontal lines among ticks.
        for index, tick of domain.ticks
            # Get the wrapping `g`.
            t = grid.select(".t#{index}")

            # Draw the line
            line = t.append("svg:line")
            .attr("class", "line")
            .attr("x1",    @ticks.maxWidth)
            .attr("x2",    width + @ticks.maxWidth)

            # Make properties explicit.
            line.attr 'stroke', line.css 'stroke'

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
            barWidth = domain['x'].getRangeBand()
            # Split among the number of series we have.
            if !@isStacked then barWidth = barWidth / group['data'].length

            # -------------------------------------------------------------------
            # Place vertical line on unstacked chart of two series.
            if !@isStacked and group['data'].length is 2
                do () =>
                    # Get the distance 'x' from left for the vertical line.
                    x = @ticks.maxWidth + domain['x'](index) + barWidth
                    
                    # The actual line.
                    line = g.append("svg:line")
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

                bar.attr('opacity', 1)

                # Make properties explicit.
                bar.attr 'fill'  , bar.css 'fill'
                bar.attr 'stroke', bar.css 'stroke'

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

                # Make properties explicit.
                text.attr 'fill'       , text.css 'fill'
                text.attr 'font-size'  , text.css 'font-size'
                text.attr 'font-family', text.css 'font-family'

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

        # If vertical axis present...
        if @axis?.vertical?
            # Update its location
            labels.select('.vertical')
            .attr("transform",   "rotate(-90 #{verticalAxisLabelHeight} #{height / 2})")
            .attr("y",           height / 2)

            # Shift the whole shebang to the right.
            grid.attr('transform', "translate(#{verticalAxisLabelHeight + @padding.axisLabels}, 0)")
            chart.attr('transform', "translate(#{verticalAxisLabelHeight + @padding.axisLabels}, 0)")
            descriptions.attr('transform', "translate(#{verticalAxisLabelHeight + @padding.axisLabels}, 0)")

    hideSeries: (series) ->
        Mynd.select(@el[0]).selectAll(".s#{series}")
        .attr('fill-opacity', 0.1 )

    showSeries: (series) ->
        Mynd.select(@el[0]).selectAll(".s#{series}")
        .attr('fill-opacity', 1 )


class Mynd.Chart.legend

    # Expand object values on us.
    constructor: (o) ->
        @[k] = v for k, v of o

    render: () ->
        # Clear.
        $(@el).empty()

        # List of series.
        $(@el).append ul = $('<ul/>')

        for index, name of @series then do (index, name) =>
            ul.append $('<li/>',
                'class': 's' + index
                'html':  name
                # Toggle series.
                'click': (e) => @clickAction e.target, index
            )

    # Onclick on series legend.
    clickAction: (el, series) ->
        # Toggle the disabled state.
        $(el).toggleClass 'disabled'

        # Change the visibility of series on a chart.
        if $(el).hasClass 'disabled'
            @chart.hideSeries series
        else
            @chart.showSeries series


class Mynd.Chart.settings

    # Expand object values on us.
    constructor: (o) ->
        @[k] = v for k, v of o

    render: () ->
        # Clear.
        $(@el).empty()

        # Is the chart stacked?
        stacked = $(@el).append $('<a/>',
            'class': "btn btn-mini #{if @isStacked then 'active' else ''}"
            'text':  if @isStacked then 'Unstack' else 'Stack'
            'click': (e) =>
                $(e.target).toggleClass 'active'
                if $(e.target).hasClass 'active'
                    @chart.isStacked = true ; $(e.target).text('Unstack')
                else
                    @chart.isStacked = false ; $(e.target).text('Stack')
                
                # Re-render components.
                @legend.render()
                @chart.render()
        )