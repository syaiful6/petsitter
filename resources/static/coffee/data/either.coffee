{identity, curry, constant} = require '../core/lambda'

noop = -> @

class Either

class Right extends Either

  constructor: (@value0) ->

  @of: (value) ->
    new Right value

  of: Right.of

  ap: (b) ->
    b.map @value0

  map: (fun) ->
    Right.of fun @value0

  bimap: (_, g) ->
    if arguments.length == 1
      return (g) => g(@value0)
    g(@value0)

  foldl: (fun, z) ->
    if arguments.length == 1
      return (z) =>
        fun z, @value0
    fun z, @value0

  foldr: (fun, z) ->
    if arguments.length == 1
      return (z) =>
        fun @value0, z
    fun @value0, z

  chain: (fun) ->
    fun @value0

  equals: (other) ->
    other instanceof Right and other.value0 == @value0

  show: ->
    val = if typeof @value0.show == 'function' then @value0.show() else @value
    "Right(#{val})"

class Left extends Either

  constructor: (@value0) ->

  map: noop
  chain: noop
  ap: noop

  bimap: (f, _) ->
    if arguments.length == 1
      return (_) => f(@value0)
    f(@value0)

  foldl: (fun, z) ->
    return identity if arguments.length == 1
    identity

  foldr: (fun, z) ->
    return identity if arguments.length == 1
    identity

  show: ->
    val = if typeof @value0.show == 'function' then @value0.show() else @value
    "Right(#{val})"

Either.either = curry (onLeft, onRight, either) ->
  return onLeft(either.value0) if either instanceof Left
  return onRight(either.value0) if either instanceof Right
  throw new Error('Failed pattern. Unexpected value received')

Either.isLeft = Either.either constant(true), constant(false)
Either.isRight = Either.either constant(false), constant(true)

Either.Right = (val) ->
  new Right val

Either.Left = (val) ->
  new Left val

module.exports = Either
