## Mynd/Chart means/þýðir chart/mynd in/í icelandic/íslensku
Mynd = {}
Mynd.Scale = {}

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