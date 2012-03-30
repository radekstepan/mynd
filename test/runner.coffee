# Asynchronously load resources by adding them to the `<head>` and use callback.
class Loader

    getHead: -> document.getElementsByTagName('head')[0]

    setCallback: (tag, callback) ->
        tag.onload = callback
        tag.onreadystatechange = ->
            state = tag.readyState
            if state is "complete" or state is "loaded"
                tag.onreadystatechange = null
                window.setTimeout callback, 0


# JavaScript Loader.
class JSLoader extends Loader

    constructor: (path, callback) ->
        script = document.createElement "script"
        script.src = path;
        script.type = "text/javascript"
        @setCallback(script, callback) if callback
        @getHead().appendChild(script)


# Pass resources to Load and it will call you back once everything is done.
class Load

    wait: false

    constructor: (resources, @callback) ->
        # We need to sort out this much.
        @count = resources.length
        
        # Initial load.
        @load resources.reverse()

    load: (resources) =>   
        # Do we need to wait before continuing?
        if @wait then window.setTimeout((=> @load resources), 0)
        else
            # Is that all?
            if resources.length
                # Remove the 'first' resource from the queue.
                resource = resources.pop()

                # Wait?
                @wait = true if resource.wait?

                # What type is it?            
                switch resource.type
                    when "js"
                        # Do we need to actually download it? Check for resource name.
                        if resource.name?
                            # Bastardly browsers (IE, Webkit, Opera) attach `<div>` elements by their id to `window`.
                            if window[resource.name]? and typeof window[resource.name] is "function" then @done resource
                            else new JSLoader(resource.path, => @done resource)
                        # Standard load.
                        else new JSLoader(resource.path, => @done resource)

            # Call back when all is done.
            if @count or @wait then window.setTimeout((=> @load(resources, @callback)), 0) else @callback()

    done: (resource) =>
        @wait = false if resource.wait? # Wait no more.
        @count -= 1 # One less.


class Runner

    # JavaScript libraries as resources. Will be loaded if not present already.
    resources: [
        name:  "jQuery"
        path:  "http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"
        type:  "js"
        wait:  true
    ,
        name:  "mocha"
        path:  "https://raw.github.com/visionmedia/mocha/master/mocha.js"
        type:  "js"
    ,
        name:  "chai"
        path:  "https://raw.github.com/logicalparadox/chai/master/chai.js"
        type:  "js"
    ,
        name:  "Widgets"
        path:  "../js/widgets.js"
        type:  "js"
    ]

    # Check and load core external resources if needed.
    constructor: -> new Load @resources, @setup

    # Setup Mocha and Chai, load JS tests through JSON.
    setup: =>
        # Mocha.
        chai.should()
        mocha.setup "bdd"

        # Get JSON with links to tests.
        $.getJSON 'js/tests.json', (tests) =>
            # We need to load this many.
            @wait = tests.length
            for test in tests
                new JSLoader("js/tests/#{test}.js", =>
                    # One less thing...
                    @wait -= 1
                    @run() unless @wait
                )

    # Run the tests (and prevent global leaks detected Error).
    run: -> mocha.run().globals [ "Widgets", "_", "Backbone", "google", "googleLT_", "google_exportSymbol", "google_exportProperty" ]

new Runner()