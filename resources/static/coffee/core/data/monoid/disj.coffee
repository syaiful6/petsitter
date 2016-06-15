{Monoid} = require '../monoid'
{identity} = require '../../basic'
{Extend} = require '../../control/extend'
{Comonad} = require '../../control/comonad'
prelude = require '../../prelude/control'
{Show, show} = require '../../prelude/show'
{Comonad} = require '../../control/comonad'
{Semiring} = require '../../prelude/ring'
{Semigroup} = require '../../prelude/semigroup'
boolAlgebra = require '../../prelude/boolean-algebra'
{Eq, Ord, eq, compare} = require '../../prelude/ord'

Disj = identity

showDisj = (dictShow) ->
  Show (v) ->
    "Disj(" + show(dictShow)(v) + ")"

semiringDisj = (dictBooleanAlgebra) ->
  Semiring (v) ->
    (v1) ->
      boolAlgebra.disj(dictBooleanAlgebra)(v)(v1)
  , (v) ->
      (v1) ->
        boolAlgebra.conj(dictBooleanAlgebra)(v)(v1)
  , boolAlgebra.top(dictBooleanAlgebra.bounded())
  , boolAlgebra.bottom(dictBooleanAlgebra.bounded())

semigroupDisj = (dictBooleanAlgebra) ->
  Semigroup (v) ->
    (v1) ->
      boolAlgebra.disj(dictBooleanAlgebra)(v)(v1)

runDisj = identity

monoidDisj = (dictBooleanAlgebra) ->
  Monoid ->
    semiringDisj(dictBooleanAlgebra)
  , boolAlgebra.bottom(dictBooleanAlgebra.bounded())

functorDisj = prelude.Functor (f) ->
  (v) ->
    f(v)

extendDisj = Extend ->
  extendDisj
, (f) ->
    (x) ->
      f(x)

eqDisj = (dictEq) ->
  Eq (v) ->
    (v1) ->
      eq(dictEq)(v)(v1)

ordDisj = (dictOrd) ->
  Ord ->
    eqDisj(dictOrd.eq())
  , (v) ->
      (v1) ->
        compare(dictOrd)(v)(v1)

comonadDisj = Comonad ->
  extendDisj
, runDisj

boundedDisj = (dictBounded) ->
  boolAlgebra.Bounded boolAlgebra.bottom(dictBounded), boolAlgebra.top(dictBounded)

applyDisj = prelude.Apply ->
  functorDisj
, (v) ->
    (v1) ->
      v(v1)

bindDisj = prelude.Bind ->
  applyDisj
, (v) ->
    (f) ->
      f(v)

applicativeDisj = prelude.Applicative ->
  applyDisj
, Disj

monadDisj = prelude.Monad ->
  applicativeDisj
, ->
  bindDisj

module.exports =
  Disj: Disj,
  runDisj: runDisj,
  eqDisj: eqDisj,
  ordDisj: ordDisj,
  boundedDisj: boundedDisj,
  functorDisj: functorDisj,
  applyDisj: applyDisj,
  applicativeDisj: applicativeDisj,
  bindDisj: bindDisj,
  monadDisj: monadDisj,
  extendDisj: extendDisj,
  comonadDisj: comonadDisj,
  showDisj: showDisj,
  semigroupDisj: semigroupDisj,
  monoidDisj: monoidDisj,
  semiringDisj: semiringDisj
