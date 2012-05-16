### <IE9 does not have a whole lot of JS functions.###

unless "bind" of Function::
  Function::bind = (owner) ->
    that = this
    if arguments.length <= 1
      ->
        that.apply owner, arguments
    else
      args = Array::slice.call(arguments, 1)
      ->
        that.apply owner, (if arguments.length is 0 then args else args.concat(Array::slice.call(arguments)))

unless "trim" of String::
  String::trim = ->
    @replace(/^\s+/, "").replace /\s+$/, ""

unless "indexOf" of Array::
  Array::indexOf = (find, i) ->
    i = 0  if i is `undefined`
    i += @length  if i < 0
    i = 0  if i < 0
    n = @length

    while i < n
      return i  if i of this and this[i] is find
      i++
    -1

unless "lastIndexOf" of Array::
  Array::lastIndexOf = (find, i) ->
    i = @length - 1  if i is `undefined`
    i += @length  if i < 0
    i = @length - 1  if i > @length - 1
    i++
    while i-- > 0
      return i  if i of this and this[i] is find
    -1

unless "forEach" of Array::
  Array::forEach = (action, that) ->
    i = 0
    n = @length

    while i < n
      action.call that, this[i], i, this  if i of this
      i++

unless "map" of Array::
  Array::map = (mapper, that) ->
    other = new Array(@length)
    i = 0
    n = @length

    while i < n
      other[i] = mapper.call(that, this[i], i, this)  if i of this
      i++
    other

unless "filter" of Array::
  Array::filter = (filter, that) ->
    other = []
    v = undefined
    i = 0
    n = @length

    while i < n
      other.push v  if i of this and filter.call(that, v = this[i], i, this)
      i++
    other

unless "every" of Array::
  Array::every = (tester, that) ->
    i = 0
    n = @length

    while i < n
      return false  if i of this and not tester.call(that, this[i], i, this)
      i++
    true

unless "some" of Array::
  Array::some = (tester, that) ->
    i = 0
    n = @length

    while i < n
      return true  if i of this and tester.call(that, this[i], i, this)
      i++
    false