{unit} = require './control'
ord = require './ord'

Bounded = (bottom, top) ->
  {
    ctor: 'Bounded'
    bottom: bottom
    top: top
  }

BooleanAlgebra = (bounded, conj, disj, _not) ->
  {
    ctor: 'BooleanAlgebra'
    conj: conj
    disj: disj
    not: _not
  }

bottom = (dictBounded) ->
  dictBounded.bottom

top = (dictBounded) ->
  dictBounded.top

conj = (dictBooleanAlgebra) ->
  dictBooleanAlgebra.conj

disj = (dictBooleanAlgebra) ->
  dictBooleanAlgebra.disj

$not = (dictBooleanAlgebra) ->
  dictBooleanAlgebra.not

# unit
boundedUnit = Bounded unit, unit
boundedOrdering = Bounded ord.LT, ord.GT
boundedInt = Bounded -2147483648, 2147483647
boundedChar = Bounded String.fromCharCode(0), String.fromCharCode(65535)
boundedBoolean = Bounded false, true
boundedFn = (dictBounded) ->
  Bounded (v) ->
    bottom(dictBounded)
  , (v) ->
    top(dictBounded)

booleanAlgebraUnit = BooleanAlgebra ->
  boundedUnit
, (v) ->
    (v1) ->
      unit
, (v) ->
    (v1) ->
      unit
, (v) ->
  unit

booleanAlgebraBoolean = BooleanAlgebra ->
  boundedBoolean
, (b) ->
    (b1) ->
      b and b1
, (b) ->
    (b1) ->
      b or b1
, (b) ->
  not b

module.exports =
  Bounded: Bounded
  BooleanAlgebra: BooleanAlgebra
  boundedUnit: boundedUnit
  boundedChar: boundedChar
  boundedInt: boundedInt
  boundedBoolean: boundedBoolean
  boundedFn: boundedFn
  booleanAlgebraBoolean: boundedBoolean
  booleanAlgebraUnit: booleanAlgebraUnit
  bottom: bottom
  top: top
  disj: disj
  "||": disj
  conj: conj
  "&&": conj
  "not": $not
  "!": $not
