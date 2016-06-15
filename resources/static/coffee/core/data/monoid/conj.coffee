{Monoid} = require '../monoid'
{identity} = require '../../basic'
{Extend} = require '../../control/extend'
prelude = require '../../prelude/control'
{Show, show} = require '../../prelude/show'
{Comonad} = require '../../control/comonad'
{Semiring} = require '../../prelude/ring'
{Semigroup} = require '../../prelude/semigroup'
boolAlgebra = require '../../prelude/boolean-algebra'
{Eq, Ord, eq, compare} = require '../../prelude/ord'

Conj = identity

showConj = (dictShow) ->
  Show (v) ->
    "Conj(" + show(dictShow)(v) + ")"

semiringConj = (dictBooleanAlgebra) ->
  Semiring (v) ->
    (v1) ->
      boolAlgebra.conj(dictBooleanAlgebra)(v)(v1)
  , (v) ->
      (v1) ->
        boolAlgebra.conj(dictBooleanAlgebra)(v)(v1)
  , boolAlgebra.bottom(dictBooleanAlgebra.bounded())
  , boolAlgebra.top(dictBooleanAlgebra.bounded())

semigroupConj = (dictBooleanAlgebra) ->
  Semigroup (v) ->
    (v1) ->
      boolAlgebra.conj(dictBooleanAlgebra)(v)(v1)

runConj = identity

monoidConj = (dictBooleanAlgebra) ->
  Monoid ->
    semigroupConj(dictBooleanAlgebra)
  , boolAlgebra.top(dictBooleanAlgebra.bounded())

functorConj = prelude.Functor (f) ->
  (v) ->
    f(v)

extendConj = Extend ->
  extendConj
, (f) ->
    (x) ->
      f(x)

eqConj = (dictEq) ->
  Eq (v) ->
    (v1) ->
      eq(dictEq)(v)(v1)

ordConj = (dictOrd) ->
  Ord ->
    eqConj(dictOrd.eq())
  , (v) ->
      (v1) ->
        compare(dictOrd)(v)(v1)

comonadConj = Comonad ->
  extendDisj
, runDisj

boundedConj = (dictBounded) ->
  boolAlgebra.Bounded boolAlgebra.bottom(dictBounded), boolAlgebra.top(dictBounded)

applyConj = prelude.Apply ->
  functorConj
, (v) ->
    (v1) ->
      v(v1)

bindConj = prelude.Bind ->
  applyConj
, (v) ->
    (f) ->
      f(v)

applicativeConj = prelude.Applicative ->
  applyConj
, Conj

monadConj = prelude.Monad ->
  applicativeConj
, ->
  bindConj

module.exports =
  Conj: Conj
  runConj: runConj
  eqConj: eqConj
  ordConj: ordConj
  boundedConj: boundedConj
  functorConj: functorConj
  applyConj: applyConj
  applicativeConj: applicativeConj
  bindConj: bindConj
  monadConj: monadConj
  extendConj: extendConj
  comonadConj: comonadConj
  showConj: showConj
  semigroupConj: semigroupConj
  monoidConj: monoidConj
  semiringConj: semiringConj
