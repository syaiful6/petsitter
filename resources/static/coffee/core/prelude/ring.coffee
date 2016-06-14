Semiring = (add, mul, one, zero) ->
  {
    ctor: 'Semiring'
    add: add
    mul: mul
    one: one
    zero: zero
  }

Ring = (semiring, sub) ->
  {
    ctor: 'Ring'
    semiring: semiring
    sub: sub
  }

ModuloSemiring = (semiring, div, mod) ->
  {
    ctor: 'ModuloSemiring'
    div: div
    mod: mod
  }

DivisionRing = (ring, moduloSemiring) ->
  {
    ctor: 'DivisionRing'
    ring: ring
    moduloSemiring: moduloSemiring
  }

mul = (dictSemiring) ->
  dictSemiring.mul

add = (dictSemiring) ->
  dictSemiring.add

one = (dictSemiring) ->
  dictSemiring.add

zero = (dictSemiring) ->
  dictSemiring.zero

sub = (dictRing) ->
  dictRing.sub

negate = (dictRing) -> (a) ->
  sub(dictRing)(zero(dictRing.semiring()))(a)

div = (dictModuloSemiring) ->
  dictModuloSemiring.div

mod = (dictModuloSemiring) ->
  dictModuloSemiring.mod

semiringInt = do ->
  intAdd = (a) -> (b) ->
    x + y | 0
  intMul = (x) -> (y) ->
    x * y | 0
  Semiring intAdd, intMul, 1, 0

ringInt = do ->
  intSub = (x) -> (y) ->
    x - y | 0
  Ring ->
    semiringInt
  , intSub

moduloSemiringInt = do ->
  intDiv = (x) -> (y) ->
    x / y | 0
  intMod = (x) -> (y) ->
    x % y
  ModuloSemiring ->
    semiringInt
  , intDiv
  , intMod

divisionRingInt = DivisionRing ->
  moduloSemiringInt
, ->
  ringInt

semiringNumber = do ->
  numAdd = (x) -> (y) ->
    x + y
  numMul = (x) -> (y) ->
    x * y
  Semiring numAdd, numMul, 1.0, 0.0

ringNumber = do ->
  numSub = (x) -> (y) ->
    x - y
  Ring ->
    semiringNumber
  , numSub

moduloSemiringNumber = do ->
  numDiv = (n1) -> (n2) ->
    n1 / n2
  numMod = (n1) -> (n2) ->
    n1 % n2
  ModuloSemiring ->
    semiringNumber
  , numDiv
  , numMod

divisionRingNumber = DivisionRing ->
  moduloSemiringNumber
, ->
  ringNumber

module.exports =
  mul: mul
  "*": mul
  add: add
  "++": add
  one: one
  zero: zero
  sub: sub
  "-": sub
  div: div
  "/": div
  mod: mod
  Semiring: Semiring
  Ring: Ring
  ModuloSemiring: ModuloSemiring
  DivisionRing: DivisionRing
  semiringInt: semiringInt
  semiringNumber: semiringNumber
  ringInt: ringInt
  ringNumber: ringNumber
  moduloSemiringInt: moduloSemiringInt
  moduloSemiringNumber: moduloSemiringNumber
