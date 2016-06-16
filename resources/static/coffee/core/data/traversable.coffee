prelude = require '../prelude/control'
maybe = require './maybe'
{ invoke2, invoke3 } = require '../../utils/functools'

# Traversable type class, `Traversable` represents data structures which
# can be traversed. accumulating results and effects in some `Applicative` functor.
# traverse` runs an action for every element in a data structure,
# and accumulates the results.
# `sequence` runs the actions _contained_ in a data structure, and accumulates the results.
Traversable = (foldable, functor, sequence, traverse) ->
  {
    ctor: 'Traversable'
    foldable: foldable
    functor: functor
    sequence: sequence
    traverse: traverse
  }

traverse = (dictTraversable) ->
  dictTraversable.traverse

sequence = (dictTraversable) ->
  dictTraversable.sequence

sequenceDefault = (dictTraversable) ->
  (dictApplicative) ->
    (tma) ->
      idt = prelude.id(prelude.categoryFn)
      invoke3 traverse(dictTraversable), dictApplicative, idt, tma

traversableMaybe = do ->
  # sequence implementation
  seqMaybe = (dictApplicative) -> (v) ->
    if maybe.isNothing(v)
      prelude.pure(dictApplicative)(maybe.Nothing)
    else
      prelude.map((dictApplicative.apply())['functor']())(maybe.Just)(v.value0)
  travMaybe = (dictApplicative) -> (v) -> (v1) ->
    if maybe.isNothing(v1)
      prelude.pure(dictApplicative)(maybe.Nothing)
    else
      prelude.map((dictApplicative.apply())['functor']())(maybe.Just)(v(v1.value0))
  Traversable ->
    foldable.foldableMaybe
  , ->
    maybe.functorMaybe
  , seqMaybe
  , travMaybe

# to do, definde traversable array

module.exports =
  Traversable: Traversable
  traverse: traverse
  sequence: sequence
  traversableMaybe: traversableMaybe
