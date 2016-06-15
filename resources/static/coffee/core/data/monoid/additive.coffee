{Monoid} = require '../monoid'
{Extend} = require '../../control/extend'
{Comonad} = require '../../control/comonad'
{identity} = require '../../basic'
prelude = require '../../prelude/control'
{Show, show} = require '../../prelude/show'
{Semiring, add, zero} = require '../../prelude/ring'
{Eq, Ord, eq, compare} = require '../../prelude/ord'
{Semigroup} = require '../../prelude/semigroup'
{Invariant, imapF} = require '../functor/invariant'

Additive = identity

showAdditive = (dictShow) ->
  Show (v) ->
    "Additive(" + show(dictShow)(v) + ")"

semigroupAdditive = (dictSemiring) ->
  Semigroup (v) ->
    (v1) ->
      add(dictSemiring)(v)(v1)

runAdditive = identity

monoidAdditive = (dictSemiring) ->
  Monoid ->
    semigroupAdditive(dictSemiring)
  , zero(dictSemiring)

invariantAdditive = Invariant (f) ->
  (v) ->
    (v1) ->
      f(v1)

functorAdditive = prelude.Functor (f) ->
  (v) ->
    f(v)

extendAdditive = Extend ->
  functorAdditive
, (f) ->
    (x) ->
      f(x)

eqAdditive = (dictEq) ->
  Eq (v) ->
    (v1) ->
      eq(dictEq)(v)(v1)

ordAdditive = (dictOrd) ->
  Ord ->
    eqAdditive(dictOrd.eq())
  , (v) ->
      (v1) ->
        compare(dictOrd)(v)(v1)

comonadAdditive = Comonad ->
  extendAdditive
, runAdditive

applyAdditive = prelude.Apply ->
  functorAdditive
, (v) ->
    (v1) ->
      v(v1)

bindAdditive = prelude.Bind ->
  applyAdditive
, (v) ->
    (f) ->
      f(v)

applicativeAdditive = prelude.Applicative ->
  applyAdditive
, Additive

monadAdditive = prelude.Monad ->
  applicativeAdditive
, ->
  bindAdditive

module.exports =
  Additive: Additive
  runAdditive: runAdditive
  eqAdditive: eqAdditive
  ordAdditive: ordAdditive
  functorAdditive: functorAdditive
  applyAdditive: applyAdditive
  applicativeAdditive: applicativeAdditive
  bindAdditive: bindAdditive
  monadAdditive: monadAdditive
  extendAdditive: extendAdditive
  comonadAdditive: comonadAdditive
  invariantAdditive: invariantAdditive
  showAdditive: showAdditive
  semigroupAdditive: semigroupAdditive
  monoidAdditive: monoidAdditive
