Eq = (eq) ->
  ctor: 'Eq'
  eq: eq

Ord = (eq, compare) ->
  ctor: 'Ord'
  eq: eq
  compare: compare

eq = (dictEq) ->
  dictEq.eq

compare = (dictOrd) ->
  dictOrd.compare

less = (dictOrd) -> (a1) -> (a2) ->
  res = compare(dictOrd)(a1)(a2)
  if res.ctor == 'LT' then true else false

lessEq = (dictOrd) -> (a1) -> (a2) ->
  res = compare(dictOrd)(a1)(a2)
  if res.ctor == 'GT' then false else true

greater = (dictOrd) -> (a1) -> (a2) ->
  res = compare(dictOrd)(a1)(a2)
  if res.ctor == 'GT' then true else false

greateEq = (dictOrd) -> (a1) -> (a2) ->
  res = compare(dictOrd)(a1)(a2)
  if res.ctor == 'LT' then false else true

LT = ctor: 'LT'
GT = ctor: 'GT'
EQ = ctor: 'EQ'

unsafeCompareImpl = (lt) -> (eq) -> (gt) -> (x) -> (y) ->
  if x < y then lt else (if x > y then gt else eq)

unsafeCompare = unsafeCompareImpl(LT)(EQ)(GT)

# string
eqString = Eq (v) -> (v1) -> v == v1
ordString = Ord ->
  eqString
, unsafeCompare

# number
eqNumber = Eq (v) -> (v1) -> v == v1
ordNumber = Ord ->
  eqNumber
, unsafeCompare

eqInt = Eq (v) -> (v1) -> v == v1
ordInt = Ord ->
  eqInt
, unsafeCompare

eqArray = (dictEq) ->
  eqArrayImpl = (f) -> (xs) -> (ys) ->
    return false if xs.length != ys.length
    for i in [0...xs.length]
      return false unless f(xs[i])(ys[i])
    true
  Eq eqArrayImpl(eq(dictEq))

ordArray = (dictOrd) ->
  ordArrayImpl = (f) -> (xs) -> (ys) ->
    i = 0
    xlen = xs.length
    ylen = ys.length
    while i < xlen and i < ylen
      x = xs[i]
      y = ys[i]
      res = f(x)(y)
      return res if res != 0
      i++
    return 0 if xlen == ylen
    return -1 if xlen > ylen
    return 1
  compareWithZero = compare(ordNumber)(0)
  result = ordArrayImpl (x) -> (y) ->
    a = compare(dictOrd)(x)(y)
    return 0 if a.ctor == 'EQ'
    return 1 if a.ctor == 'LT'
    return -1 if a.ctor == 'GT'
  Ord ->
    eqArray(dictOrd.eq())
  , (xs) -> (ys) ->
    compareWithZero(result(xs)(ys))

module.exports =
  Eq: Eq
  Ord: Ord
  LT: LT
  GT: GT
  EQ: EQ
  compare: compare
  eq: eq
  less: less
  lessEq: lessEq
  greater: greater
  greateEq: greateEq
  eqNumber: eqNumber
  eqString: eqString
  eqArray: eqArray
  ordNumber: ordNumber
  ordString: ordString
  ordArray: ordArray
  eqInt: eqInt
  ordInt: ordInt
