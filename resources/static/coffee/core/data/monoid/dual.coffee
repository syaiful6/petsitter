{Monoid, mempty} = require '../monoid'
{identity} = require '../../basic'
{Extend} = require '../../control/extend'
{Comonad} = require '../../control/comonad'
prelude = require '../../prelude/control'
{Show, show} = require '../../prelude/show'
{Comonad} = require '../../control/comonad'
{Semiring} = require '../../prelude/ring'
{Semigroup, append} = require '../../prelude/semigroup'
boolAlgebra = require '../../prelude/boolean-algebra'
{Eq, Ord, eq, compare} = require '../../prelude/ord'
{Invariant, imapF} = require '../functor/invariant'

Dual = identity

showDual = (dictShow) ->
  return Show (v) ->
    "Dual (" + show(dictShow)(v) + ")"

semigroupDual = (dictSemigroup) ->
  Semigroup (v) ->
    (v1) ->
      append(dictSemigroup)(v)(v1)

runDual = identity

monoidDual = (dictMonoid) ->
  Monoid ->
    semigroupDual dictMonoid.semigroup()
  , mempty(dictMonoid)

invariantDual = Invariant (f) ->
  (v) ->
    (v1) ->
      f(v1)

functorDual = prelude.Functor (f) ->
  (v) ->
    f(v)

extendDual = Extend ->
  functorDual
, (f) ->
    (x) ->
      f(x)

eqDual = (dictEq) ->
  Eq eq(dictEq)

ordDual = (dictOrd) ->
  Ord ->
    eqDual dictOrd.eq()
  , compare(dictOrd)

comonadDual = Comonad ->
  extendDual
, runDual

applyDual = prelude.Apply ->
  functorDual
, (v) ->
    (v1) ->
      v(v1)

bindDual = prelude.Bind ->
  applyDual
, (v) ->
    (f) ->
      f(v)

applicativeDual = prelude.Applicative ->
  applyDual
, Dual

monadDual = prelude.Monad ->
  applicativeDual
, ->
  bindDual

module.exports =
  Dual: Dual
  runDual: runDual
  eqDual: eqDual
  ordDual: ordDual
  functorDual: functorDual
  applyDual: applyDual
  applicativeDual: applicativeDual
  bindDual: bindDual
  monadDual: monadDual
  extendDual: extendDual
  comonadDual: comonadDual
  invariantDual: invariantDual
  showDual: showDual
  semigroupDual: semigroupDual
  monoidDual: monoidDual
