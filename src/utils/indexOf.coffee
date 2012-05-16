### <IE9 does not have Array::indexOf, use MDC implementation.###

unless Array::indexOf
    Array::indexOf = (elt) ->
        len = @length >>> 0
        from = Number(arguments[1]) or 0
        from = (if (from < 0) then Math.ceil(from) else Math.floor(from))
        from += len if from < 0
        while from < len
            return from if from of this and this[from] is elt
            from++
        -1