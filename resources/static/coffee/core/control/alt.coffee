{append, semigroupArray} = require '../prelude/semigroup'
{functorArray} = require '../prelude/control'

Alt = (functor, alt) ->
  {
    ctor: 'Alt'
    functor: functor
    alt: alt
  }

alt = (dictAlt) ->
  dictAlt.alt

altArray = Alt ->
  functorArray
, append(semigroupArray)

module.exports =
  Alt: Alt
  alt: alt
  "<|>": alt
  altArray: altArray
