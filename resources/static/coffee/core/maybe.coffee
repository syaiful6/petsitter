{curry2, curry3} = require '../utils/functools'

Just = (a) ->
  ctor: 'Just'
  _0: a

Nothing =
  ctor: 'Nothing'

withDefault = curry2 (def, maybe) ->
  p = maybe
  if p.ctor == 'Just' then p._0 else def

andThen = curry2 (maybeValue, callback) ->
  p = maybeValue
  if p.ctor == 'Just' then callback(p._0) else Nothing

map = curry2 (f, maybe) ->
  p = maybe
  if p.ctor == 'Just' then Just(f(p._0)) else Nothing

module.exports =
  Nothing: Nothing
  Just: Just
  withDefault: withDefault
  andThen: andThen
  map: map
