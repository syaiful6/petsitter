basic = require '../basic'
ord = require '../prelude/ord'
foldable = require './foldable'
semigroup = require '../prelude/semigroup'
control = require '../prelude/control'
alt = require '../control/alt'
monoid = require './monoid'
extend = require '../control/extend'

Left = (v) ->
  {
    ctor: 'Left',
    value0: v
  }

Right = (v) ->
  {
    ctor: 'Right',
    value0: v
  }

semigroupEither = (dictSemigroup) ->
  semigroup.Semigroup (x) -> (y) ->
    control.apply(applyEither)(control.map(functorEither)(semigroup.append(dictSemigroup))(x))(y)

functorEither = control.Functor (v) -> (v1) ->
  return Left v1.value0 if v1.ctor == 'Left'
  return Right v(v1.value0) if v1.ctor == 'Right'
  throw new Error('Failed pattern. Unexpected value received')

foldableEither = foldable.Foldable (dictMonoid) ->
  (f) ->
    (v) ->
      return monoid.mempty dictMonoid if v.ctor == 'Left'
      return f v.value0 if v.ctor == 'Right'
      throw new Error('Failed pattern. Unexpected value received')
, (f) ->
    (z) ->
      (v) ->
        return z if v.ctor == 'Left'
        return f(z)(v1.value0) if v.ctor == 'Right'
        throw new Error('Failed pattern. Unexpected value received')
, (f) ->
    (z) ->
      (v) ->
        return z if v.ctor == 'Left'
        return f(v.value0)(z) if v.ctor == 'Right'
        throw new Error('Failed pattern. Unexpected value received')

extendEither = extend.Extend ->
  functorEither
, (v) -> (v1) ->
  return Left(v1.value0) if v1.ctor == 'Left'
  Right(v(v1))

eqEither = (dictEq) -> (dictEq1) ->
  ord.Eq (v) -> (v1) ->
    if v.ctor == 'Left' and v1.ctor == 'Left'
      return ord.eq(dictEq)(v.value0)(v1.value0)
    if v.ctor == 'Right' and v1.ctor == 'Right'
      return ord.eq(dictEq1)(v.value0)(v1.value0)
    false

ordEither = (dictOrd) -> (dictOrd1) ->
  ord.Ord ->
    eqEither(dictOrd.eq())(dictOrd1.eq())
  , (v) -> (v1) ->
    if v.ctor == 'Left' and v1.ctor == 'Left'
      ord.compare(dictOrd)(v.value0)(v1.value0)
    if v.ctor == 'Right' and v1.ctor == 'Right'
      ord.compare(dictOrd1)(v.value0)(v1.value0)
    if v.ctor == 'Left'
      ord.LT
    if v1.ctor == 'Right'
      ord.GT

either = (v) -> (v1) -> (v2) ->
  return v(v2.value0) if v2.ctor == 'Left'
  return v1(v2.value0) if v2.ctor == 'Right'
  throw new Error('Failed pattern. Unexpected value received')

isLeft = either(basic['const'](true))(basic['const'](false))
isRight = either(basic['const'](false))(basic['const'](true))

applyEither = control.Apply ->
  functorEither
, (v) -> (v1) ->
  return Left(v.value0) if v.ctor == 'Left'
  if v.ctor == 'Right'
    return control.map(functorEither)(v.value0)(v1)
  throw new Error('Failed pattern. Unexpected value received')

bindEither = control.Bind ->
  applyEither
, do ->
  ifL = (e) -> (v) ->
    Left(e)
  ifR = (a) -> (f) ->
    f(a)
  either(ifL)(ifR)

applicativeEither = control.Applicative ->
  applyEither
, Right

monadEither = control.Monad ->
  applicativeEither
, ->
  bindEither

altEither = alt.Alt ->
  functorEither
, (v) -> (v1) ->
  if v.ctor == 'Left' then v1 else v

module.exports =
  Left: Left
  Right: Right
  isRight: isRight
  isLeft: isLeft
  either: either
  semigroupEither: semigroupEither
  functorEither: functorEither
  extendEither: extendEither
  eqEither: eqEither
  ordEither: ordEither
  applyEither: applyEither
  bindEither: bindEither
  applicativeEither: applicativeEither
  monadEither: monadEither
  altEither: altEither
  foldableEither: foldableEither
