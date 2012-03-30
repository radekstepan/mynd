### Parent for both Widgets, handling templating, validation and errors.###

class InterMineWidget

    # Inject wrapper inside the target `div` that we have control over.
    constructor: ->
        $(@el).html $ '<div/>',
            class: "inner"
            style: "height:572px;overflow:hidden"
            html:  "Loading &hellip;"
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
        
        if fails.length then @error "JSONResponse", fails

    # The possible errors we handle.
    error: (type, data) =>
        opts = title: "Error", text: "Generic error"

        # Which?
        switch type
            when "AJAXTransport"
                opts.title = data.statusText
                opts.text = data.responseText
            when "JSONResponse"
                opts.title = "Invalid JSON"
                opts.text = "<ol>#{data.join('')}</ol>"

        # Show.
        $(@el).html @template "error", opts

        # Throw an error so we do not process further.
        throw new Error type