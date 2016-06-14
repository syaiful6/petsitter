monoid = require './monoid'
basic = require '../basic'
ord = require '../prelude/ord'
semigroup = require '../prelude/semigroup'
control = require '../prelude/control'
alt = require '../control/alt'
plus = require '../control/plus'
alternative = require '../control/alternative'
extend = require '../control/extend'

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

maybe$prime = (v) -> (v1) -> (v2) ->
  if v2.ctor == 'Nothing' then v({}) else v1(v2.value0)

# isNothing :: forall a. Maybe a -> Boolean
isNothing = maybe(true)(basic["const"](false))

# isJust :: forall a. Maybe a -> Boolean
isJust = maybe(false)(basic["const"](true))

# fromMaybe :: forall a. a -> Maybe a -> a
# Takes a default value, and a `Maybe` value. If the `Maybe` value is Nothing then
# the default value returned othewise the the value inside Just returned
fromMaybe = (a) ->
  maybe(a)(control.id(control.categoryFn))

# similiar to fromMaybe
fromMaybe$prime = (a) ->
  maybe$prime(a)(control.id(control.categoryFn))

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

altMaybe = alt.Alt ->
  functorMaybe
, (v) -> (v1) ->
  if v.ctor == 'Nothing' then v1 else v

plusMaybe = plus.Plus ->
  altMaybe
, Nothing

extendMaybe = extend.Extend ->
  functorMaybe
, (v) -> (v1) ->
  if v1.ctor == 'Nothing' then Nothing else Just(v(v1))

alternativeMaybe = alternative.Alternative ->
  plusMaybe
, ->
  applicativeMaybe

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
  maybe: maybe
  "maybe'": maybe$prime
  fromMaybe: fromMaybe
  "fromMaybe'": fromMaybe$prime
  isJust: isJust
  isNothing: isNothing
  semigroupMaybe: semigroupMaybe
  monadMaybe: monoidMaybe
  functorMaybe: functorMaybe
  applyMaybe: applyMaybe
  applicativeMaybe: applicativeMaybe
  bindMaybe: bindMaybe
  monadMaybe: monadMaybe
  extendMaybe: extendMaybe
  alternativeMaybe: alternativeMaybe
  eqMaybe: eqMaybe
  ordMaybe: ordMaybe
