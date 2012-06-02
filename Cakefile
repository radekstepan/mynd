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

# Append to existing file.
write = (path, text, mode = "w") ->
    fs.open path, mode, 0o0666, (e, id) ->
        if e then throw new Error(e)
        fs.write id, text, null, "utf8"

# Compress using `uglify-js`.
uglify = (input) -> pro.gen_code pro.ast_squeeze pro.ast_mangle jsp.parse input