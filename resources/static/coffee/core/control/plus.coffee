alt = require './alt'

Plus = (alt, empty) ->
  {
    ctor: 'Plus'
    alt: alt
    empty: empty
  }

plusArray = Plus ->
  alt.altArray
, []

empty = (dictPlus) ->
  dictPlus.empty

module.exports =
  Plus: Plus
  plusArray: plusArray
  empty: empty
