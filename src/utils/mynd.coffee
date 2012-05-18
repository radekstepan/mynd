## Mynd/Chart means/þýðir chart/mynd in/í icelandic/íslensku
Mynd = {}
Mynd.Scale = {}

# Ordinal scales have a discrete domain (chart bars).
Mynd.Scale.ordinal = ->
    ( ->
        internal = {}

        # Given a value `x` in the input domain, returns the corresponding value in the output range.
        scale = (x) -> internal.range[x]

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

        uninterpolateNumber = (a, b) ->
            b = (if b - (a = +a) then 1 / (b - a) else 0)
            (x) ->
                (x - a) * b

        interpolateNumber = (a, b) ->
            b -= a
            (t) ->
                a + b * t

        scale_bilinear = ->
            u = uninterpolateNumber internal.domain[0], internal.domain[1]
            i = interpolateNumber internal.range[0], internal.range[1]
            (x) ->
                i u(x)

        rescale = ->
            if internal.domain? and internal.range?
                internal.output = internal.input = scale_bilinear()
            
            scale
        
        scale = (x) -> internal.output x

        # Set the scale's input domain to the specified array of numbers.
        # Example: [0, 3] for bar values ranging from 0 to a maximum of 3
        scale.domain = (x) ->
            internal.domain = x.map(Number)
            
            rescale()

        # Setsthe scale's output range to the specified array of values.
        # Example: [0, 100] for a column chart bar that is to be at most 100px tall.
        scale.range = (x) ->
            internal.range = x
            
            rescale()

        scale
    )()

mynd = Mynd.Scale.linear().domain([ 0, 3 ]).range([ 0, 15.7 ])

console.log '---- mynd ----'
for value in [1, 2.3, 3]
    console.log mynd value