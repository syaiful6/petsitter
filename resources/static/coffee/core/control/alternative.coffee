{functorArray} = require '../prelude/control'
{applicativeArray} = require './plus'

# it just specifies that the type constructor has both `Applicative` and `Plus` instances.
Alternative = (plus, applicative) ->
  {
    ctor: 'Alternative'
    plus: plus
    applicative: applicative
  }

alternativeArray = Alternative ->
  plusArray
, ->
  applicativeArray

module.exports =
  Alternative: Alternative
  alternativeArray: alternativeArray
