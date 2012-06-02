### Types in JS.###

type = {}
class type.Root
    result: false
    is: -> @result
    toString: -> "#{@expected} but got #{@actual}"

#### String
class type.isString extends type.Root
    expected: "String"
    constructor: (@actual) -> @result = typeof actual is 'string'

#### Integer
class type.isInteger extends type.Root
    expected: "Integer"
    constructor: (@actual) -> @result = typeof actual is 'number'

#### Boolean
class type.isBoolean extends type.Root
    expected: "Boolean true"
    constructor: (@actual) -> @result = typeof actual is 'boolean'

#### Null
class type.isNull extends type.Root
    expected: "Null"
    constructor: (@actual) -> @result = actual is null

#### Array
class type.isArray extends type.Root
    expected: "Array"
    constructor: (@actual) -> @result = actual instanceof Array

#### HTTP Success
class type.isHTTPSuccess extends type.Root
    expected: "HTTP code 200"
    constructor: (@actual) -> @result = actual is 200

#### JSON
class type.isJSON extends type.Root
    expected: "JSON Object"
    constructor: (@actual) ->
        @result = true
        try
            JSON?.parse actual
        catch e
            @result = false

#### Undefined
class type.isUndefined extends type.Root
    expected: "it to be undefined"