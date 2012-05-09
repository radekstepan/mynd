### Parent for all Widgets, handling templating, validation and errors.###

class InterMineWidget

    # Inject wrapper inside the target `div` that we have control over.
    constructor: ->
        $(@el).html $ '<div/>',
            class: "inner"
            style: "height:572px;overflow:hidden;position:relative"
        @el = "#{@el} div.inner"

    # Where is eco?
    template: (name, context = {}) -> JST["#{name}.eco"]?(context)

    # Validate JSON object against the spec.
    validateType: (object, spec) =>
        fails = []
        for key, value of object
            if (r = new spec[key]?(value) or r = new type.isUndefined()) and not r.is()
                fails.push @template "invalidjsonkey",
                    key:      key
                    actual:   r.is()
                    expected: new String(r)
        
        if fails.length then @error fails, "JSONResponse"

    # The possible errors we handle.
    error: (opts={'title': 'Error', 'text': 'Generic error'}, type) =>
        # Add the name of the widget.
        opts.name = @name or @id
        
        # Which?
        switch type
            when "AJAXTransport"
                opts.title = opts.statusText
                opts.text = opts.responseText
            when "JSONResponse"
                opts.title = "Invalid JSON Response"
                opts.text = "<ol>#{opts.join('')}</ol>"

        # Show.
        $(@el).html @template "error", opts

        # Throw an error so we do not process further.
        throw new Error type

    # Init, return an IMJS service instance.
    imService: () =>
        if not @imjs? then @imjs = new intermine.Service('root': @service, 'token': @token)
        @imjs