{constant} = require './lambda'
{getInstance} = require '../utils/common'

tagged = ->
  fields = [].slice.apply arguments

  toString = (args) ->
    x = [].slice.apply args
    ->
      value = x.map (y) ->
        y.toString()
      "("+ value.join(', ') + ")"

  wrapped = ->
    self = getInstance this, wrapped
    if arguments.length != fields.length
      throw new TypeError "Expected #{fields.length}  but got #{arguments.length}"

    for field, i in arguments
      self[fields[i]] = field

    self.toString = toString arguments
    self

  wrapped.__length__ = fields.length
  wrapped

taggedSum = (ctor) ->

  definitions = ->
    throw new TypeError "Tagged sum was called instead of one of its properties."

  makeCata = (key) ->
    (dispatches) ->
      fields = ctor[key]

      unless dispatches[key]
        throw new TypeError "Constructors given to cata didn't include: #{key}"

      args = (this[field] for field in fields)

      dispatches[key].apply this, args

  makeProto = (key) ->
    proto = Object.create definitions.prototype
    proto.cata = makeCata key
    proto

  for k of ctor
    unless ctor[k].length
      definitions[k] = makeProto k
      definitions[k].toString = constant "()"
      continue
    tag = tagged.apply(null, ctor[k])
    definitions[k] = tag
    definitions[k].prototype = makeProto k
    definitions[k].prototype.constructor = tag

  definitions

module.exports =
  tagged: tagged
  taggedSum: taggedSum
