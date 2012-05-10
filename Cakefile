fs = require "fs" # I/O
npath = require "path" # does path exist?
cs = require 'coffee-script' # take a guess
eco = require "eco" # templating
crypto = require "crypto" # md5 hashing
exec = require('child_process').exec # execute custom commands


# --------------------------------------------


# Main input/output.
MAIN =
    INPUT: "src/widgets.coffee"
    OUTPUT: "js/intermine.widgets.js"

# Tests input/output and runner.
TESTS =
    INPUT:  "test/src"
    OUTPUT: "test/js"
    RUNNER: "test/runner.coffee"

# Templates dir.
TEMPLATES = "src/templates"
# Utils dir.
UTILS = "src/utils"
# Classes dir.
CLASSES = "src/class"
# Which folders to watch for changes?
WATCH = [ "src", "src/templates", "src/utils", "src/class" ]

# Path to InterMine SVN output.
INTERMINE =
    ROOT: "/home/rs676/svn/ws_widgets"
    OUTPUT: "intermine/webapp/main/resources/webapp/js/intermine.widgets.js"

# ANSI Terminal colors.
COLORS =
  BOLD:    '\u001b[0;1m'
  RED:     '\u001b[0;31m'
  GREEN:   '\u001b[0;32m'
  BLUE:    '\u001b[0;34m'
  YELLOW:  '\u001b[0;33m'
  DEFAULT: '\u001b[0m'

# --------------------------------------------


option '-w', '--watch', 'should we watch source directories for changes?'
option '-c', '--commit [MESSAGE]', 'make an SVN commit in InterMine passing the message'

# Compile widgets.coffee and .eco templates into one output. Do not use globals for JST.
task "compile:main", "compile widgets library and templates together", (options) ->
    main ->

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
                        main -> done = true

# Compile tests.
task "compile:tests", "compile tests so we can run them in the browser", (options) ->
    console.log "#{COLORS.BOLD}Compiling tests in #{TESTS.INPUT}#{COLORS.DEFAULT}"
    
    # Compile the test runner.
    source = cs.compile fs.readFileSync(TESTS.RUNNER, "utf-8")
    write [ TESTS.OUTPUT, TESTS.RUNNER.split('/').pop().replace '.coffee', '.js' ].join('/'), source

    # Compile tests in test/src/ to test/js/tests/.
    walk TESTS.INPUT, (err, files) ->
        if err then throw new Error('problem walking tests')
        else
            tests = []
            for file in files
                # Read in, compile.
                source = cs.compile fs.readFileSync(file, "utf-8")
                # Get the filename wo/ extension.
                name = file.split('/').pop().replace '.coffee', ''
                # Write to equivalent JS file
                write [ TESTS.OUTPUT, "tests", "#{name}.js" ].join('/'), source
                # Save the path to JSON output.
                tests.push "\"#{name}\""

            # Write JSON so we can reference all tests. 
            write [ TESTS.OUTPUT, 'tests.json' ].join('/'), "[#{tests.join(',')}]"

    # That's it.
    console.log "#{COLORS.GREEN}Done#{COLORS.DEFAULT}"

# Release the latest version of the .js library into InterMine SVN.
task "release", "release compiled widgets.js into target InterMine directory", (options) ->
    console.log "#{COLORS.BOLD}Releasing to #{INTERMINE.ROOT}#{COLORS.DEFAULT}"

    # Does the source and target path exist?
    exist(MAIN.OUTPUT) and exist([ INTERMINE.ROOT, INTERMINE.OUTPUT ].join('/'), 'dir')

    # Have files changed?
    if md5(MAIN.OUTPUT) is md5([ INTERMINE.ROOT, INTERMINE.OUTPUT ].join('/'))
        console.log "#{COLORS.YELLOW}No change detected#{COLORS.DEFAULT}"
        return
    
    # Write it.
    write [ INTERMINE.ROOT, INTERMINE.OUTPUT ].join('/'), fs.readFileSync(MAIN.OUTPUT, "utf-8"), "w"

    # Make an SVN commit?
    if options.commit
        child = exec("(cd #{INTERMINE.ROOT};svn ci #{INTERMINE.OUTPUT} -m \"#{options.commit}\")", (error, stdout, stderr) ->
            if error
                console.log [ COLORS.RED, error, COLORS.DEFAULT ].join ''
                throw new Error e
        )

    console.log "#{COLORS.GREEN}Done#{COLORS.DEFAULT}"

# Create docco docs from hardcoded paths.
task "docs", "create docco docs", ->
    exec "docco src/*.coffee src/utils/*.coffee src/class/*.coffee"


# --------------------------------------------


main = (callback) ->
    console.log "#{COLORS.BOLD}Compiling main#{COLORS.DEFAULT}"

    # Head.
    head = (cb) -> cb "(function() {\nvar o = {};\n"

    # Compile templates.
    templates = (cb) ->
        tmpl = [ "var JST = {};" ]
        walk TEMPLATES, (err, files) ->
            if err then throw new Error('problem walking templates')
            else
                # Only take eco files.
                match = /\.eco$/
                for file in files
                    if file.match match
                        console.log file
                        # Read in, precompile & compress.
                        js = eco.precompile fs.readFileSync file, "utf-8"
                        name = file.split('/').pop()
                        tmpl.push uglify "JST['#{name}'] = #{js}"
                cb tmpl

    # Compile utils in any order.
    utils = (cb) ->
        utils = []
        walk UTILS, (err, files) ->
            if err then throw new Error('problem walking utils')
            else
                for file in files
                    console.log file
                    # Read in, compile.
                    utils.push cs.compile fs.readFileSync(file, "utf-8"), bare: "on"
                cb utils

    # Compile the main classes in any order (access through factory).
    classes = (cb) ->
        classes = [ "var factory;\nfactory = function(Backbone) {\n" ]
        walk CLASSES, (err, files) ->
            if err then throw new Error('problem walking classes')
            else
                names = []
                for file in files
                    console.log file
                    # Read in, compile.
                    source = cs.compile fs.readFileSync(file, "utf-8"), bare: "on"
                    # Insert spaces as we are inside the factory function (nicety).
                    source = ( "  #{line}\n" for line in source.split("\n") ).join('')
                    # `InterMineWidget.coffee` needs to go first...
                    if file.match /InterMineWidget\.coffee$/ then classes.splice 1, 0, source
                    else classes.push source
                    # Get the class name (it better match).
                    names.push file.split('/').pop().split('.')[0]
                
                # Create a closing return statement exposing all classes.
                classes.push "  return {\n"
                classes.push ( "    \"#{name}\": #{name},\n" for name in names ).join('')
                classes.push "  };\n};"

                cb classes

    # Compile the public library.
    widgets = (cb) ->
        console.log MAIN.INPUT
        compiled = cs.compile fs.readFileSync(MAIN.INPUT, "utf-8"), bare: "on"
        cb compiled

    # Close.
    close = (cb) -> cb "}).call(this);"

    done = (results) ->
        output = []

        # Combine them all.
        for result in results
            for index, item of result
                if item instanceof Array then output.push sub for sub in item else output.push item
        
        output = output.join "\n"

        # Write them all at once.
        write MAIN.OUTPUT, output
        
        # Minify.
        write MAIN.OUTPUT.replace('.js', '.min.js'), uglify output

        # We are done.
        console.log "#{COLORS.GREEN}Done#{COLORS.DEFAULT}"

    # This is the queue order.
    queue [ head, templates, utils, classes, widgets, close ], done

# A serial queue that waits until all resources have returned and then calls back.
queue = (calls, callback) ->
    make = (index) ->
      ->
        counter--
        all[index] = arguments
        callback(all) unless counter

    # How many do we have?
    counter = calls.length
    # Store results here.
    all = []

    i = 0
    for call in calls
        call make i++

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
write = (path, text, mode = "w") ->
    fs.open path, mode, 0o0666, (e, id) ->
        if e then throw new Error(e)
        fs.write id, text, null, "utf8"

# Compress using `uglify-js`.
uglify = (input) ->
    jsp = require("uglify-js").parser
    pro = require("uglify-js").uglify

    pro.gen_code pro.ast_squeeze pro.ast_mangle jsp.parse input

# Does the target path exist?
exist = (path, type = "file") ->
    # Dir or file?
    if type is 'dir' then path = npath.dirname path
    
    try
        fs.lstatSync path
    catch e
        console.log [ COLORS.RED, "Path #{path} does not exist", COLORS.DEFAULT ].join ''
        throw new Error e

    return true

# Will give an MD5 of a file and fail silently.
md5 = (path) ->
    try
        file = fs.readFileSync path, "utf-8"
        return crypto.createHash('md5').update(file).digest('hex')
    catch e