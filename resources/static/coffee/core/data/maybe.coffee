ord = require './ord'
semigroup = require './semigroup'
monoid = require './monoid'
control = require '../control'
basic = require '../basic'

Just = (a) ->
  ctor: 'Just'
  value0: a

Nothing =
  ctor: 'Nothing'

semigroupMaybe = (dictSemigroup) ->
  semigroup.Semigroup (v) -> (v1) ->
    return v1 if v.ctor == 'Nothing'
    return v if v1.ctor == 'Nothing'
    if v.ctor == 'Just' and v1.ctor == 'Just'
      Just semigroup.append(dictSemigroup)(v.value0)(v1.value0)

monoidMaybe = (dictSemigroup) ->
  monoid.Monoid ->
    semigroupMaybe(dictSemigroup)
  , Nothing

maybe = (v) -> (v1) -> (v2) ->
  return v if v2.ctor == 'Nothing'
  return v1(v2.value0) if v2.ctor == 'Just'

isNothing = maybe(true)(basic["const"](false))
isJust = maybe(false)(basic["const"](true))

functorMaybe = control.Functor (v) -> (v1) ->
  if v1.ctor == 'Just' then Just(v(v1)) else Nothing

applyMaybe = control.Apply ->
  functorMaybe
, (v) -> (v1) ->
  if v.ctor == 'Just'
    control.map(functorMaybe)(v.value0)(v1)
  else
    Nothing

bindMaybe = control.Bind ->
  applyMaybe
, (v) -> (v1) ->
  if v.ctor == 'Just'
    v1(v.value0)
  else
    Nothing

applicativeMaybe = control.Applicative ->
  applyMaybe
, Just

monadMaybe = control.Monad ->
  applicativeMaybe
, ->
  bindMaybe

eqMaybe = (dictEq) ->
  ord.Eq (v) -> (v1) ->
    return true if v.ctor == 'Nothing' and v1.ctor == 'Nothing'
    if v.ctor == 'Just' and v1.ctor == 'Just'
      return ord.eq(dictEq)(v.value0)(v1.value0)
    return false

ordMaybe = (dictOrd) ->
  ord.Ord ->
    eqMaybe(dictOrd)
  , (v) -> (v1) ->
    if v.ctor == 'Just' and v1.ctor == 'Just'
      return ord.compare(dictOrd)(v.value0)(v1.value0)
    if v.ctor == 'Nothing' and v1.ctor == 'Nothing'
      return ord.EQ
    if v.ctor == 'Nothing'
      return ord.LT
    if v1.ctor == 'Nothing'
      return ord.GT
    throw new Error('invalid value detected')

module.exports =
  Nothing: Nothing
  Just: Just
  isJust: isJust
  isNothing: isNothing
  semigroupMaybe: semigroupMaybe
  monadMaybe: monoidMaybe
  functorMaybe: functorMaybe
  applyMaybe: applyMaybe
  applicativeMaybe: applicativeMaybe
  bindMaybe: bindMaybe
  monadMaybe: monadMaybe
  eqMaybe: eqMaybe
  ordMaybe: ordMaybe
