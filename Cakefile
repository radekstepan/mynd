fs = require "fs"
cs = require 'coffee-script'
eco = require "eco"


# --------------------------------------------


# Main input/output.
MAIN =
    INPUT: "src/widgets.coffee"
    OUTPUT: "js/widgets.js"
# Test input/output.
SPEC =
    INPUT: "tests/spec.coffee"
    OUTPUT: "tests/spec.js"
# Templates dir.
TEMPLATES = "src/templates"
# Which folders to watch for changes?
WATCH = [ "src", "src/templates" ]

# ANSI Terminal colors.
COLORS =
    BOLD: '\033[0;1m'
    RED: '\033[0;31m'
    GREEN: '\033[0;32m'
    BLUE: '\033[0;34m'
    DEFAULT: '\033[0m'

# --------------------------------------------


option '-m', '--minify', 'should we minify main library for production?'
option '-w', '--watch', 'should we watch source directories for changes?'

# Compile widgets.coffee and .eco templates into one output. Do not use globals for JST.
task "compile:main", "compile widgets library and templates together", (options) ->
    main options.minify, ->

    # Watch for changes?
    if options.watch
        done = true # Have we finished with main compilation step?
        for dir in WATCH
            console.log "#{COLORS.BOLD}Watching #{dir}#{COLORS.DEFAULT}"
            fs.watch dir, (event, file) ->
                if event in [ "rename", "change" ]
                    console.log "#{COLORS.BLUE}Change detected in #{file}#{COLORS.DEFAULT}"
                    if done
                        done = false
                        main options.minify, -> done = true

# Compile tests spec.coffee.
task "compile:tests", "compile tests spec", (options) ->
    console.log "#{COLORS.BOLD}Compiling tests#{COLORS.DEFAULT}"

    # Clean.
    fs.unlink SPEC.OUTPUT

    # CoffeeScript compile.
    append SPEC.OUTPUT, cs.compile fs.readFileSync SPEC.INPUT, "utf-8"

    # Done.
    console.log "#{COLORS.GREEN}Tests compilation a success#{COLORS.DEFAULT}"


# --------------------------------------------


main = (minify, callback) ->
    console.log "#{COLORS.BOLD}Compiling main#{COLORS.DEFAULT}"

    # Clean.
    fs.unlink MAIN.OUTPUT

    # Open.
    append MAIN.OUTPUT, "(function() {"

    # Compile templates.
    done = false
    walk TEMPLATES, (err, files) ->
        if err then throw new Error('problem walking templates')
        else
            append MAIN.OUTPUT, "var JST = {};"
            # Only take eco files.
            match = /\.eco$/
            for file in files
                if file.match match
                    # Read in, precompile & compress.
                    js = eco.precompile fs.readFileSync file, "utf-8"
                    name = file.split('/').pop()
                    append MAIN.OUTPUT, uglify "JST['#{name}'] = #{js}"
            done = true

    (blocking = ->
        if done
            # Compile main library (and optionally minify).
            compiled = cs.compile fs.readFileSync(MAIN.INPUT, "utf-8"), bare: "on"
            if minify then append MAIN.OUTPUT, uglify compiled else append MAIN.OUTPUT, compiled

            # Close.
            append MAIN.OUTPUT, "}).call(this);"
            
            # We are done here?
            console.log "#{COLORS.GREEN}Main compilation a success#{COLORS.DEFAULT}"
            callback()
        else
            setTimeout blocking, 0
    )()

# Traverse a directory and return a list of files (async, recursive).
walk = (path, callback) ->
    results = []
    # Read directory.
    fs.readdir path, (err, list) ->
        # Problems?
        return callback err if err
        
        # Get listing length.
        pending = list.length
        
        return callback null, results unless pending # Done already?
        
        # Traverse.
        list.forEach (file) ->
            # Form path
            file = "#{path}/#{file}"
            fs.stat file, (err, stat) ->
                # Subdirectory.
                if stat and stat.isDirectory()
                    walk file, (err, res) ->
                        # Append result from sub.
                        results = results.concat(res)
                        callback null, results unless --pending # Done yet?
                # A file.
                else
                    results.push file
                    callback null, results unless --pending # Done yet?

# Append to existing file.
append = (path, text) ->
    fs.open path, "a", 0666, (e, id) ->
        if e then throw new Error(e)
        fs.write id, "#{text}\n", null, "utf8"

# Compress using `uglify-js`.
uglify = (input) ->
    jsp = require("uglify-js").parser
    pro = require("uglify-js").uglify

    pro.gen_code pro.ast_squeeze pro.ast_mangle jsp.parse input