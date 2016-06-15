{identity} = require '../../basic'
{Semigroup} = require '../../prelude/semigroup'
{Monoid} = require '../monoid'
prelude = require '../../prelude/control'
{Invariant} = require '../functor/invariant'

Endo = identity

semigroupEndo = Semigroup (v) ->
  (v1) ->
    (x) ->
      v(v1(x))

runEndo = identity

monoidEndo = Monoid ->
  semigroupEndo
, prelude.id(prelude.categoryFn)

invariantEndo = Invariant (ab) ->
  (ba) ->
    (v) ->
      (x) ->
        ab(v(ba(x)))

module.exports =
  Endo: Endo,
  runEndo: runEndo,
  invariantEndo: invariantEndo,
  semigroupEndo: semigroupEndo,
  monoidEndo: monoidEndo
