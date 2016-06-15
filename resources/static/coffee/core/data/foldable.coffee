maybe = require './maybe'
preludeOrd = require '../prelude/ord'
preludeControl = require '../prelude/control'
controlApply = require '../control/apply'
preludeRing = require '../prelude/ring'
monoid = require './monoid'
monoidDisj = require './monoid/disj'
basic = require '../basic'
{append} = require '../prelude/semigroup'
{ invoke2, invoke3 } = require '../../utils/functools'

Foldable = (foldMap, foldl, foldr) ->
  {
    ctor: 'Foldable'
    # foldMap :: forall a m. (Monoid m) => (a -> m) -> f a -> m
    foldMap: foldMap
    # foldl :: forall a b. (a -> b -> b) -> b -> f a -> b
    foldl: foldl
    # foldr :: forall a b. (b -> a -> b) -> b -> f a -> b
    foldr: foldr
  }

foldr = (dictFoldable) ->
  dictFoldable.foldr

foldl = (dictFoldable) ->
  dictFoldable.foldl

foldMap = (dictFoldable) ->
  dictFoldable.foldMap

fold = (dictFoldable) -> (dictMonoid) ->
  invoke3 foldMap, dictFoldable, dictMonoid, preludeControl.id(preludeControl.categoryFn)

traverse_ = (dictApplicative) -> (dictFoldable) -> (f) ->
  u = preludeControl.pure(dictApplicative)(preludeControl.unit)
  do (u) ->
    rs = foldr(dictFoldable) (v) ->
      controlApply["*>"](dictApplicative.apply())(f(v))
    rs(u)

for_ = (dictApplicative) -> (dictFoldable) ->
  basic.flip invoke2(traverse_, dictApplicative, dictFoldable)

sequence_ = (dictApplicative) -> (dictFoldable) ->
  invoke3 traverse_, dictApplicative, dictFoldable, preludeControl.id(preludeControl.categoryFn)

maximumBy = (dictFoldable) -> (cmp) ->
  max$prime = (v) -> (v1) ->
    if v.ctor == 'Nothing'
      return maybe.Just(v1)
    if v.ctor == 'Just'
      return maybe.Just do ->
        c = cmp(v.value0)(v1)
        if c.ctor == 'GT' then v.value0 else v1
  invoke3 foldl, dictFoldable, max$prime, maybe.Nothing

maximum = (dictOrd) -> (dictFoldable) ->
  invoke2 maximumBy, dictFoldable, preludeOrd.compare(dictOrd)

mconcat = (dictFoldable) -> (dictMonoid) ->
  invoke2 foldl(dictFoldable), append(dictMonoid.semigroup()), monoid.mempty(dictMonoid)

minimumBy = (dictFoldable) -> (cmp) ->
  min$prime = (v) -> (v1) ->
    if v.ctor == 'Nothing'
      return maybe.Just(v1)
    if v.ctor == 'Just'
      return maybe.Just do ->
        c = cmp(v.value0)(v1)
        if c.ctor == 'LT' then v.value0 else v1
  invoke3 foldl, dictFoldable, min$prime, maybe.Nothing

minimum = (dictOrd) -> (dictFoldable) ->
  invoke2 minimumBy, dictFoldable, preludeOrd.compare(dictOrd)

sum = (dictFoldable) -> (dictSemiring) ->
  invoke2 foldl(dictFoldable), preludeRing.add(dictSemiring), preludeRing.zero(dictSemiring)

product = (dictFoldable) -> (dictSemiring) ->
  invoke2 foldl(dictFoldable), preludeRing.mul(dictSemiring), preludeRing.one(dictSemiring)

foldMapDefaultR = (dictFoldable) ->
  (dictMonoid) ->
    (f) ->
      (xs) ->
        foldr(dictFoldable)((x) ->
          (acc) ->
            append(dictMonoid.semigroup())(f(x))(acc)
        )(monoid.mempty(dictMonoid))(xs)

foldMapDefaultL = (dictFoldable) ->
  (dictMonoid) ->
    (f) ->
      (xs) ->
        foldl(dictFoldable)((x) ->
          (acc) ->
            append(dictMonoid.semigroup())(f(x))(acc)
        )(monoid.mempty(dictMonoid))(xs)

foldableArray = do ->
  foldrArray = (f) -> (init) -> (xs) ->
    acc = init
    i = xs.length
    while i--
      acc = f(xs[item])(acc)
    acc
  foldlArray = (f) -> (init) -> (xs) ->
    acc = init
    for item in xs
      acc = f(item)(acc)
    acc
  Foldable (dictMonoid) ->
    foldMapDefaultR(foldableArray)(dictMonoid)
  , foldlArray
  , foldrArray

foldableMaybe = do ->
  foldMMaybe = (dictMonoid) -> (f) -> (v) ->
    return monoid.mempty(dictMonoid) if v.ctor == 'Nothing'
    return f(v.value0) if v.ctor == 'Just'
    throw new Error("unexpected value detected")
  foldLMaybe = (f) -> (z) -> (v) ->
    return z if v.ctor == 'Nothing'
    return f(z)(v.value0) if v.ctor == 'Just'
    throw new Error("unexpected value detected")
  foldRMaybe = (f) -> (z) -> (v) ->
    return z if v.ctor == 'Nothing'
    return f(v.value0)(z) if v.ctor == 'Just'
    throw new Error("unexpected value detected")
  Foldable foldMMaybe, foldLMaybe, foldRMaybe

find = (dictFoldable) -> (p) ->
  $finder = (r) -> (x) ->
    pred = p(x)
    if pred then maybe.Just(x) else r
  invoke3 foldl, dictFoldable, $finder, maybe.Nothing

any = (dictFoldable) -> (dictBooleanAlgebra) -> (p) -> (x) ->
  wrapper = (t) ->
    monoidDisj.Disj p(t)
  runIt = invoke3 foldMap(dictFoldable), monoidDisj.monoidDisj(dictBooleanAlgebra), wrapper, x
  monoidDisj.runDisj runIt

module.exports =
  Foldable: Foldable
  foldMap: foldMap
  foldl: foldl
  foldr: foldr
  fold: fold
  maximumBy: maximumBy
  maximum: maximum
  minimumBy: minimumBy
  minimum: minimum
  sum: sum
  foldMapDefaultR: foldMapDefaultR
  foldMapDefaultL: foldMapDefaultL
  foldableArray: foldableArray
  foldableMaybe: foldableMaybe
  sequence_: sequence_
  for_: for_
