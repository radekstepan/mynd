## Mynd/Chart means/þýðir chart/mynd in/í icelandic/íslensku
Mynd = {}
Mynd.Scale = {}


temp = {}

temp_selectionPrototype = []

temp.selection = -> temp_selectionRoot

temp.selection:: = temp_selectionPrototype

temp_select = (s, n) -> n.querySelector s

temp_selectAll = (s, n) -> n.querySelectorAll s

temp_selection_selector = (selector) ->
    ->
        temp_select selector, @

temp_selection_selectorAll = (selector) ->
    ->
        temp_selectAll selector, @

temp_selectionPrototype.select = (selector) ->
    subgroups = []
    subgroup = undefined
    subnode = undefined
    group = undefined
    node = undefined
    selector = temp_selection_selector(selector) if typeof selector isnt "function"
    j = -1
    m = @length

    while ++j < m
        subgroups.push subgroup = []
        subgroup.parentNode = (group = @[j]).parentNode
        i = -1
        n = group.length

        while ++i < n
            if node = group[i]
                subgroup.push subnode = selector.call(node, node.__data__, i)
                subnode.__data__ = node.__data__  if subnode and "__data__" of node
            else
                subgroup.push null
      
    temp_selection subgroups

temp_selectionPrototype.selectAll = (selector) ->
    subgroups = []
    subgroup = undefined
    node = undefined
    selector = temp_selection_selectorAll(selector) if typeof selector isnt "function"
    j = -1
    m = @length

    while ++j < m
        group = @[j]
        i = -1
        n = group.length

        while ++i < n
            if node = group[i]
                subgroups.push subgroup = temp_array(selector.call(node, node.__data__, i))
                subgroup.parentNode = node
    
    temp_selection subgroups

temp_selectionPrototype.append = (name) ->
    append = ->
        @appendChild document.createElementNS(@namespaceURI, name)
    appendNS = ->
        @appendChild document.createElementNS(name.space, name.local)
    
    name = temp.ns.qualify(name)
    @select (if name.local then appendNS else append)

temp_nsPrefix =
    svg: "http://www.w3.org/2000/svg"
    xhtml: "http://www.w3.org/1999/xhtml"

temp.ns =
    prefix: temp_nsPrefix
  
    qualify: (name) ->
        i = name.indexOf(":")
        prefix = name
        
        if i >= 0
            prefix = name.substring(0, i)
            name = name.substring(i + 1)
        (if temp_nsPrefix.hasOwnProperty(prefix)
            space: temp_nsPrefix[prefix]
            local: name
        else name)

temp_selectionPrototype.attr = (name, value) ->
    attrNull = -> @removeAttribute name
    attrNullNS = -> @removeAttributeNS name.space, name.local
    attrConstant = -> @setAttribute name, value
    attrConstantNS = -> @setAttributeNS name.space, name.local, value
  
    attrFunction = ->
        x = value.apply(@, arguments)
        unless x?
            @removeAttribute name
        else
            @setAttribute name, x
  
    attrFunctionNS = ->
        x = value.apply(@, arguments)
        unless x?
            @removeAttributeNS name.space, name.local
        else
            @setAttributeNS name.space, name.local, x
    
    name = temp.ns.qualify(name)
    if arguments.length < 2
        node = @node()
        return (if name.local then node.getAttributeNS(name.space, name.local) else node.getAttribute(name))
    
    ret = do ->
        if not value?
            if name.local
                return attrNullNS
            else
                return attrNull
        else
            if typeof value is "function"
                if name.local
                    return attrFunctionNS
                else
                    return attrFunction
            else
                if name.local
                    return attrConstantNS
                else
                    return attrConstant
    
    @each ret

temp_selectionPrototype.each = (callback) ->
    j = -1
    m = @length

    while ++j < m
        group = @[j]
        i = -1
        n = group.length

        while ++i < n
            node = group[i]
            callback.call node, node.__data__, i, j if node
  
    @

temp_selectionPrototype.text = (value) ->
    if arguments.length < 1
        @node().textContent
    else
        ret = do ->
            if typeof value is "function"
                ->
                    v = value.apply(@, arguments)
                    @textContent = (if not v? then "" else v)
            else
                if not value?
                    ->
                        @textContent = ""
                else
                    ->
                        @textContent = value
    
        @each ret

temp_selectionPrototype.node = (callback) ->
    j = 0
    m = @length

    while j < m
        group = @[j]
        i = 0
        n = group.length

        while i < n
            node = group[i]
            return node  if node
            i++
        j++
    null

temp_eventCancel = ->
    temp.event.stopPropagation()
    temp.event.preventDefault()

temp_eventSource = ->
    e = temp.event
    s = undefined
    e = s while s = e.sourceEvent
    e

temp_dispatch = ->

temp_dispatch::on = (type, listener) ->
    i = type.indexOf(".")
    name = ""
    if i > 0
        name = type.substring(i + 1)
        type = type.substring(0, i)
    (if arguments.length < 2 then this[type].on(name) else this[type].on(name, listener))

temp_dispatch_event = (dispatch) ->
    
    event = ->
        z = listeners
        i = -1
        n = z.length
        l = undefined
        l.apply this, arguments  if l = z[i].on  while ++i < n
        dispatch
    
    listeners = []
    listenerByName = new d3_Map
    
    event.on = (name, listener) ->
        l = listenerByName.get(name)
        i = undefined
        return l and l.on  if arguments.length < 2
    
        if l
            l.on = null
            listeners = listeners.slice(0, i = listeners.indexOf(l)).concat(listeners.slice(i + 1))
            listenerByName.remove name
    
        if listener
            listeners.push listenerByName.set(name,
                on: listener
            )
    
        dispatch

    event

temp_eventDispatch = (target) ->
    dispatch = new temp_dispatch
    i = 0
    n = arguments.length
    dispatch[arguments[i]] = temp_dispatch_event(dispatch)  while ++i < n
    dispatch.of = (thiz, argumentz) ->
        (e1) ->
            try
                e0 = e1.sourceEvent = temp.event
                e1.target = target
                temp.event = e1
                dispatch[e1.type].apply thiz, argumentz
            finally
                temp.event = e0
    
    dispatch

temp.event = null

temp_selectionPrototype.on = (type, listener, capture) ->
    capture = false  if arguments.length < 3
    name = "__on" + type
    i = type.indexOf(".")
    type = type.substring(0, i)  if i > 0
    
    return (i = @node()[name]) and i._  if arguments.length < 2
  
    @each (d, i) ->
        l = (e) ->
            o = temp.event
            temp.event = e
            try
                listener.call node, node.__data__, i
            finally
                temp.event = o
        node = @
        o = node[name]
        if o
            node.removeEventListener type, o, o.$
            delete node[name]
        if listener
            node.addEventListener type, node[name] = l, l.$ = capture
            l._ = listener

temp_selection = (groups) ->
    groups.__proto__ = temp_selectionPrototype
    return groups

temp_selectionRoot = temp_selection([ [ document ] ])

temp_selectRoot = document.documentElement

temp_selectionRoot[0].parentNode = temp_selectRoot

temp_arraySlice = (pseudoarray) ->
    Array::slice.call pseudoarray

temp_arrayCopy = (pseudoarray) ->
    i = -1
    n = pseudoarray.length
    array = []
    array.push pseudoarray[i] while ++i < n
    array

try
    temp_array(document.documentElement.childNodes)[0].nodeType
catch e
    temp_array = temp_arrayCopy

temp_array = temp_arraySlice

Mynd.selectAll = (selector) ->
    if typeof selector is "string"
        temp_selectionRoot.selectAll(selector)
    else
        temp_selection([ temp_array(selector) ])

Mynd.select = (selector) ->
    if typeof selector is "string"
        return temp_selectionRoot.select(selector)
    else
        return temp_selection([ [ selector ] ])


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