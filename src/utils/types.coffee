### Types in JS.###

type = {}
class type.Root
    result: false
    is: -> @result
    toString: -> @expected

#### String
class type.isString extends type.Root
    expected: "String"
    constructor: (key) -> @result = typeof key is 'string'

#### Integer
class type.isInteger extends type.Root
    expected: "Integer"
    constructor: (key) -> @result = typeof key is 'number'

#### Boolean
class type.isBoolean extends type.Root
    expected: "Boolean true"
    constructor: (key) -> @result = typeof key is 'boolean'

#### Null
class type.isNull extends type.Root
    expected: "Null"
    constructor: (key) -> @result = key is null

#### Array
class type.isArray extends type.Root
    expected: "Array"
    constructor: (key) -> @result = key instanceof Array

#### HTTP Success
class type.isHTTPSuccess extends type.Root
    expected: "HTTP code 200"
    constructor: (key) -> @result = key is 200

#### JSON
class type.isJSON extends type.Root
    expected: "JSON Object"
    constructor: (key) ->
        @result = true
        try
            JSON?.parse key
        catch e
            console?.log key
            @result = false

#### Undefined
class type.isUndefined extends type.Root
    expected: "it to be undefined"