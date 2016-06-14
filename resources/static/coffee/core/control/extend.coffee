preludeControl = require '../prelude/control'
{append} = require '../prelude/semigroup'

Extend = (functor, extend) ->
  {
    ctor: 'Extend'
    functor: functor
    extend: extend
  }

extend = (dictExtend) ->
  dictExtend.extend

extendFn = (dictSemigroup) ->
  Extend ->
    preludeControl.functorFn
  , (f) -> (g) -> (w) ->
    f (v) ->
      g append(dictSemigroup)(w)(v)

$eq$less$eq = (dictExtend) ->
  (f) ->
    (g) ->
      (w) ->
        f extend(dictExtend)(g)(w)

$eq$greater$eq = (dictExtend) ->
  (f) ->
    (g) ->
      (w) ->
        g $less$less$eq(dictExtend)(f)(w)

$eq$greater$greater = (dictExtend) ->
  (w) ->
    (f) ->
      extend(dictExtend)(f) w

duplicate = (dictExtend) ->
  extend(dictExtend) preludeControl.id(preludeControl.categoryFn)

module.exports =
  Extend: Extend
  extend: extend
  extendFn: extendFn
  duplicate: duplicate
  "=<=": $eq$less$eq,
  "=>=": $eq$greater$eq,
  "=>>": $eq$greater$greater,
  "<<=": extend
