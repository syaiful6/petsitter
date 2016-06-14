control = require '../prelude/control'
semigroup = require '../prelude/semigroup'
foldable = require './foldable'
monoid = require './monoid'
extend = require '../control/extend'
comonad = require '../control/comonad'

# tuple data structure
Tuple = (value0, value1) ->
  {
    ctor: 'Tuple'
    value0: value0
    value1: value1
  }

create = (value0) ->
  (value1) ->
    Tuple value0, value1

uncurry = (fun) -> (tuple) ->
  fun(tuple.value0)(tuple.value1)

curry = (fun) -> (a) -> (b) ->
  fun(Tuple(a, b))

swap = (v) ->
  Tuple v.value1, v.value0

snd = (v) ->
  v.value1

fst = (v) ->
  v.value0

semigroupoidTuple = control.Semigroupoid (v) ->
  (v1) ->
    Tuple v1.value0, v.value1

semigroupTuple = (dictSemigroup) ->
  (dictSemigroup1) ->
    semigroup.Semigroup (v) ->
      (v1) ->
        Tuple(
          semigroup.append(dictSemigroup)(v.value0)(v1.value0),
          semigroup.append(dictSemigroup1)(v.value1)(v1.value1)
        )

monoidTuple = (dictMonoid) ->
  (dictMonoid1) ->
    monoid.Monoid ->
      semigroupoidTuple(dictMonoid.semigroup())(dictMonoid1.semigroup())
    , Tuple monoid.mempty(dictMonoid), monoid.mempty(dictMonoid1)

functorTuple = control.Functor (fun) ->
  (v) ->
    Tuple v.value0, fun(v.value1)

foldableTuple = do ->
  fTupM = (dictMonoid) -> (f) -> (v) ->
    f(v.value1)
  foldlTup = (f) -> (z) -> (v) ->
    f(z)(v.value1)
  foldRTup = (f) -> (z) -> (v) ->
    f(v.value1)(z)
  foldable.Foldable fTupM, foldlTup, foldRTup

extendTuple = extend.Extend ->
  functorTuple
, (f) ->
    (v) ->
      Tuple(v.value0, f(v))

comonadTuple = comonad.Comonad ->
  extendTuple
, snd

applyTuple = (dictSemigroup) ->
  control.Apply ->
    functorTuple
  , (v) ->
      (v1) ->
        Tuple semigroup.append(dictSemigroup)(v.value0)(v1.value0), v.value1(v1.value1)

bindTuple = (dictSemigroup) ->
  control.Bind ->
    applyTuple(dictSemigroup)
  , (v) ->
      (f) ->
        res = f(v.value1)
        Tuple semigroup.append(dictSemigroup)(v.value0)(res.value0), res.value1

applicativeTuple = (dictMonoid) ->
  control.Applicative ->
    applicativeTuple dictMonoid.semigroup()
  , create(monoid.mempty(dictMonoid))

monadTuple = (dictMonoid) ->
  control.Monad ->
    applicativeTuple(dictMonoid)
  , ->
    bindTuple(dictMonoid.semigroup())

module.exports =
  Tuple: Tuple
  create: create
  snd: snd
  fst: fst
  curry: curry
  uncurry: uncurry
  swap: swap
  semigroupoidTuple: semigroupoidTuple
  semigroupTuple: semigroupTuple
  monoidTuple: monoidTuple
  functorTuple: functorTuple
  foldableTuple: foldableTuple
  extendTuple: extendTuple
  comonadTuple: comonadTuple
  applyTuple: applyTuple
  bindTuple: bindTuple
  applicativeTuple: applicativeTuple
  monadTuple: monadTuple
