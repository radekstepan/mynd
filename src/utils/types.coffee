# JSON Types.
type = {}
class type.Root
    result: false
    is: -> @result
    toString: -> @expected

class type.isString extends type.Root
    expected: "String"
    constructor: (key) -> @result = typeof key is 'string'

class type.isInteger extends type.Root
    expected: "Integer"
    constructor: (key) -> @result = typeof key is 'number'

class type.isBoolean extends type.Root
    expected: "Boolean true"
    constructor: (key) -> @result = typeof key is 'boolean'

class type.isNull extends type.Root
    expected: "Null"
    constructor: (key) -> @result = key is null

class type.isArray extends type.Root
    expected: "Array"
    constructor: (key) -> @result = key instanceof Array

class type.isHTTPSuccess extends type.Root
    expected: "HTTP code 200"
    constructor: (key) -> @result = key is 200

class type.isUndefined extends type.Root
    expected: "it to be undefined"