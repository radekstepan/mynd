fs =  require "fs" # I/O
cs =  require 'coffee-script' # take a guess
jsp = require("uglify-js").parser
pro = require("uglify-js").uglify

# ANSI Terminal colors.
COLORS =
    BOLD:    '\u001b[0;1m'
    RED:     '\u001b[0;31m'
    GREEN:   '\u001b[0;32m'
    BLUE:    '\u001b[0;34m'
    YELLOW:  '\u001b[0;33m'
    DEFAULT: '\u001b[0m'

# --------------------------------------------

# Compile.
task "compile", "compile .coffee to .js (and minify)", (options) ->

    console.log "#{COLORS.BOLD}Compiling#{COLORS.DEFAULT}"

    try
        js = cs.compile fs.readFileSync 'mynd.coffee', 'utf-8'
        write 'js/mynd.js', js
        write 'js/mynd.min.js', uglify js
  
        # We are done.
        console.log "#{COLORS.GREEN}Done#{COLORS.DEFAULT}"

    catch err
        console.log "#{COLORS.RED}#{err}#{COLORS.DEFAULT}"

# Compile tests.
task "tests", "compile tests to run in the browser", (options) ->
    console.log "#{COLORS.BOLD}Compiling tests#{COLORS.DEFAULT}"
    
    # Compile the test runner.
    write 'test/js/runner.js', cs.compile fs.readFileSync 'test/runner.coffee', "utf-8"

    # Compile tests in test/src/ to test/js/tests/.
    walk 'test/src/', (err, files) ->
        if err then throw new Error('problem walking tests')
        else
            tests = []
            for file in files
                # Read in, compile.
                source = cs.compile fs.readFileSync(file, "utf-8")
                # Get the filename wo/ extension.
                name = file.split('/').pop().replace '.coffee', ''
                # Write to equivalent JS file
                write "test/js/tests/#{name}.js", source
                # Save the path to JSON output.
                tests.push "\"#{name}\""

            # Write JSON so we can reference all tests. 
            write 'test/js/tests.json', "[#{tests.join(',')}]"

    # That's it.
    console.log "#{COLORS.GREEN}Done#{COLORS.DEFAULT}"

# Append to existing file.
write = (path, text, mode = "w") ->
    fs.open path, mode, 0o0666, (e, id) ->
        if e then throw new Error(e)
        fs.write id, text, null, "utf8"

# Compress using `uglify-js`.
uglify = (input) -> pro.gen_code pro.ast_squeeze pro.ast_mangle jsp.parse input

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