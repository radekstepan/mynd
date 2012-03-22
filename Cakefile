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
    OUTPUT: "js/widgets.js"
# Test input/output.
SPEC =
    INPUT: "tests/spec.coffee"
    OUTPUT: "tests/spec.js"
# Templates dir.
TEMPLATES = "src/templates"
# Which folders to watch for changes?
WATCH = [ "src", "src/templates" ]
# Path to InterMine SVN output.
INTERMINE =
    ROOT: "/home/rs676/svn/ws_widgets"
    OUTPUT: "intermine/webapp/main/resources/webapp/js/widget.js"

# ANSI Terminal colors.
COLORS =
    BOLD: '\033[0;1m'
    RED: '\033[0;31m'
    GREEN: '\033[0;32m'
    BLUE: '\033[0;34m'
    YELLOW: '\033[0;33m'
    DEFAULT: '\033[0m'

# --------------------------------------------


option '-m', '--minify', 'should we minify main library for production?'
option '-w', '--watch', 'should we watch source directories for changes?'
option '-c', '--commit [MESSAGE]', 'make an SVN commit in InterMine passing the message'

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
    write SPEC.OUTPUT, cs.compile fs.readFileSync SPEC.INPUT, "utf-8"

    # Done.
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


# --------------------------------------------


main = (minify, callback) ->
    console.log "#{COLORS.BOLD}Compiling main#{COLORS.DEFAULT}"

    # Clean.
    fs.unlink MAIN.OUTPUT

    # Head.
    head = (cb) -> cb "(function() {"

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
                        # Read in, precompile & compress.
                        js = eco.precompile fs.readFileSync file, "utf-8"
                        name = file.split('/').pop()
                        tmpl.push uglify "JST['#{name}'] = #{js}"
                cb tmpl

    # Compile main library (and optionally minify).
    widgets = (cb) ->
        compiled = cs.compile fs.readFileSync(MAIN.INPUT, "utf-8"), bare: "on"
        if minify then cb uglify compiled else cb compiled

    # Close.
    close = (cb) -> cb "}).call(this);"

    done = (results) ->
        output = []

        # Combine them all.
        for result in results
            for index, item of result
                if item instanceof Array then output.push sub for sub in item else output.push item
        
        # Write them all at once
        write MAIN.OUTPUT, output.join "\n"
        
        # We are done.
        console.log "#{COLORS.GREEN}Done#{COLORS.DEFAULT}"

    # This is the queue order.
    queue [ head, templates, widgets, close ], done

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
write = (path, text, mode = "a") ->
    fs.open path, mode, 0666, (e, id) ->
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