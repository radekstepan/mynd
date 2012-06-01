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


class Runner

    # Check and load core external resources if needed.
    constructor: ->
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
    run: -> mocha.run().globals [ "_", "Backbone", "canvg", "RGBColor", "d3", "d3_time_weekdays" ]

new Runner()