{identity, curry, constant} = require '../core/lambda'

# data Maybe a = Just a | Nothing

toString = Object::toString

noop = -> @

class Maybe

class Just extends Maybe

  constructor: (@value0) ->

  @of: (val) ->
    new Just val

  of: Just.of

  map: (fun) ->
    Just.of fun(@value0)

  chain: (fun) ->
    fun @value0

  ap: (b) ->
    b.map @value0

  equals: (b) ->
    b instanceof Just && b.value0 == @value0

  show: ->
    val = if typeof @value0.show == 'function' then @value0.show() else @value
    "Just(#{val})"

class Nothing extends Maybe
  map: noop
  chain: noop
  ap: noop

  equals: (b) ->
    b instanceof Nothing

  show: ->
    'Nothing'

  @value = new Nothing()

Maybe.Nothing = ->
  Nothing.value

Maybe.Just = (val) ->
  new Just val

Maybe.of = (val) ->
  new Just val

Maybe.maybe = curry (def, fun, maybe) ->
  return def if maybe instanceof Nothing
  return fun maybe.chain(identity) if maybe instanceof Just
  show = if typeof maybe.show == 'function' then maybe.show() else toString.call(maybe)
  throw new Error('maybe expect argument 3 to be a Maybe, you give' + show)

Maybe.fromNullable = (potentiallyNull) ->
  if potentiallyNull? then new Just(potentiallyNull) else Nothing.value

Maybe.isNothing = Maybe.maybe true, constant(false)
Maybe.isJust = Maybe.maybe false, constant(true)

module.exports = Maybe
