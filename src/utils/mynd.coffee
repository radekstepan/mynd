## Mynd/Chart means/þýðir chart/mynd in/í icelandic/íslensku
Mynd = {}
Mynd.Scale = {}

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

# Put on InterMine namespace
intermine.mynd = Mynd