semigroup = require '../prelude/semigroup'

Monoid = (semigroup, mempty) ->
  ctor: 'Monoid'
  semigroup: semigroup
  mempty: mempty

monoidString = Monoid ->
  semigroup.semigroupString
, ""

monoidArray = Monoid ->
  semigroup.semigroupArray
, []

mempty = (dictMonoid) ->
  dictMonoid.mempty

module.exports =
  Monoid: Monoid
  mempty: mempty
  monoidArray: monoidArray
  monoidString: monoidString
