# Type classes

LT = ctor: 'LT'

GT = ctor: 'GT'

EQ = ctor: 'EQ'

# A `Semigroupoid` is similar to a [`Category`](#category) but does not
# require an identity element `id`, just composable morphisms.
# `Semigroupoid`s must satisfy the following law:
# Associativity: `p <<< (q <<< r) = (p <<< q) <<< r`
Semigroupoid = (compose) ->
  ctor: 'Semigroupoid'
  # compose :: forall b c d. a c d -> a b c -> a b d
  compose: compose

Category = (semigroupoid, id) ->
  ctor: 'Category'
  semigroupoid: semigroupoid
  id: id

Functor = (map) ->
  ctor: 'Functor'
  # map :: forall a b. (a -> b) -> f a -> f b
  map: map

Apply = (functor, apply) ->
  ctor: 'Apply'
  apply: apply
  functor: functor

Applicative = (apply, pure) ->
  ctor: 'Applicative'
  apply: apply
  pure: pure

Bind = (apply, bind) ->
  ctor: 'Bind'
  apply: apply
  bind: bind

Monad = (applicative, bind) ->
  ctor: 'Monad'
  applicative: applicative
  bind: bind

Semigroup = (semigroup) ->
  ctor: 'Semigroup'
  semigroup: semigroup

Semiring = (add, mul, one, zero) ->
  ctor: 'Semiring'
  add: add
  mul: mul
  one: one
  zero: zero

Ring = (semiring, sub) ->
  ctor: 'Ring'
  semiring: semiring
  sub: sub

ModuloSemiring = (semiring, div, mod) ->
  ctor: 'ModuloSemiring'
  semiring: semiring
  div: div
  mod: mod

DivisionRing = (ring, moduloSemiring) ->
  ctor: 'DivisionRing'
  ring: ring
  moduloSemiring: moduloSemiring

Num = (divisionRing) ->
  ctor: 'Num'
  divisionRing: divisionRing

Eq = (eq) ->
  ctor: 'Eq'
  eq: eq

Ord = (eq, compare) ->
  ctor: 'Ord'
  eq: eq
  compare: compare

Bounded = (bottom, top) ->
  ctor: 'Bounded'
  bottom: bottom
  top: top

BoundedOrd = (bounded, ord) ->
  ctor: 'BoundedOrd'
  bounded: bounded
  ord: ord

BooleanAlgebra = (bounded, conj, disj, _not) ->
  ctor: 'BooleanAlgebra'
  bounded: bounded
  conj: conj
  disj: disj
  not: _not

Show = (show) ->
  ctor: 'Show'
  show: show

# return its argument
# identity :: a -> a
identity = (x) ->
  x

# Flips the order of the arguments to a function of two arguments.
# flip :: forall a b c. (a -> b -> c) -> b -> a -> c
flip = (f) -> (a) -> (b) ->
  f(b)(a)

# return the first argument
# first :: forall a b. a -> b -> a
first = (a) -> (_) ->
  a

nativeCompareImpl = (lt) -> (eq) -> (gt) -> (x) -> (y) ->
  if x < y then lt else (if x < y then gt else eq)

nativeCompare = nativeCompareImpl(LT)(EQ)(GT)

top = (dict) ->
  dict.top

sub = (dict) ->
  dict.sub

unit = {}

showUnit = Show (v) -> 'unit'

showString = Show identity

showOrdering = Show (v) ->
  v.ctor if v.ctor in ['LT', 'GT', 'EQ']
  throw new Error 'Unexpected value given'

showNumber = Show (v) ->
  if v == (v | 0) then v + '.0' else v

showInt = Show (v) ->
  v.toString()

showBoolean = Show (v) ->
  if v then 'true' else 'false'

show = (dict) ->
  dict.show

showArrayImpl = (f) -> (xs) ->
  ss = (f(item) for item in xs)
  '[' + ss.join(',') + ']'

showArray = (dictShow) ->
  Show show(dictShow)

showChar = Show identity

semiringUnit = do ->
  a = (x) -> (y) -> unit
  Semiring(a, a, unit, unit)

semiringNumber = do ->
  ad = (x) -> (y) -> x + y
  mul = (x) -> (y) -> x * y
  Semiring ad, mul, 1.0, 0.0

semiringInt = do ->
  ad = (x) -> (y) -> x + y | 0
  mul = (x) -> (y) -> x * y | 0
  Semiring ad, mul, 1, 0

semigroupoidFn = do ->
  impl = (f) -> (x) -> (y) ->
    f x y
  Semigroupoid impl

semigroupUnit = Semigroup -> -> unit

semigroupString = do ->
  con = (s1) -> (s2) -> s1 + s2
  Semigroup con

semigroupOrdering = do ->
  impl = (v1) -> (v2) ->
    switch v1.ctor
      when 'LT' then LT
      when 'GT' then GT
      when 'EQ' then v2
  Semigroup impl

semigroupArray = do ->
  con = (a1) -> (a2) -> a1.concat(a2)

ringUnit = do ->
  impl = (x) -> (y) -> unit
  Ring first(unit), impl

ringNumber = do ->
  subst = (x) -> (y) -> x - y
  Ring first(semiringNumber), subst

ringInt = do ->
  subst = (x) -> (y) -> x - y | 0
  Ring first(semiringInt), subst

pure = (dict) -> dict.pure

zero = (dict) -> dict.zero

one = (dict) -> dict.one

negate = (dictRing) -> (a) ->
  sub(dictRing)(zero(dictRing.semiring()))(a)

mul = (dict) -> dict.mul

moduloSemiringUnit = do ->
  always = (x) -> (y) -> unit
  ModuloSemiring first(semiringUnit), always, always

moduloSemiringNumber = do ->
  numDiv = (x) -> (y) -> x / y
  always = (x) -> (y) -> 0.0
  ModuloSemiring first(semiringNumber), numDiv, always

moduloSemiringInt = do ->
  intDiv = (x) -> (y) -> x / y | 0
  intMod = (x) -> (y) -> x % y
  ModuloSemiring first(semiringInt), intDiv, intMod

mod = (dict) -> dict.mod

map = (dict) -> dict.map

id = (dict) -> dict.id

functorArray = do ->
  arrayMap = (f) -> (arr) ->
    (f(item) for item in arr)
  Functor arrayMap

eqUnit = do ->
  alwaysTrue = (x) -> (y) -> true
  Eq alwaysTrue

ordUnit = do ->
  alwaysEQ = (x) -> (y) -> EQ
  Ord first(eqUnit), alwaysEQ

refEq = (x) -> (y) -> x == y

refIneq = (x) -> (y) -> x != y

eqString = Eq refEq

ordString = Ord first(eqString), nativeCompare

eqOrdering = do ->
  inner = (v) -> (v1) ->
    return true if v.ctor == 'LT' and v1.ctor == 'LT'
    return true if v.ctor == 'GT' and v1.ctor == 'GT'
    return true if v.ctor == 'EQ' and v1.ctor == 'EQ'
    false
  Eq inner

ordOrdering = do ->
  inner = (v) -> (v1) ->
    return EQ if v.ctor == 'LT' and v1.ctor == 'LT'
    return EQ if v.ctor == 'GT' and v1.ctor == 'GT'
    return EQ if v.ctor == 'EQ' and v1.ctor == 'EQ'
    return LT if v.ctor == 'LT'
    return LT if v.ctor == 'EQ' and v1.ctor == 'GT'
    return GT if v.ctor == 'EQ' and v1.ctor == 'LT'
    return GT if v.tor == 'GT'
  Ord first(eqOrdering), inner

eqNumber = eqInt = eqChar = eqBoolean = eqString
ordNumber = ordInt = ordChar = ordBoolean = ordString

eq = (dict) -> dict.eq

eqArray = (dictEq) ->
  eqArrayImpl = (xs) -> (ys) ->
    return false if xs.length != ys.length
    for i in [0...xs.length]
      return false unless eq(dictEq)(xs[i])(ys[i])
    true
  Eq eqArrayImpl

divisionRingUnit = DivisionRing ->
  moduloSemiringUnit
, -> ringUnit

numUnit = Num -> divisionRingUnit

divisionRingNumber = DivisionRing ->
  moduloSemiringNumber
, -> ringNumber

numNumber = Num -> divisionRingNumber

div = (dict) -> dict.div

disj = (dict) -> dict.disj

conj = (dict) -> dict.conj

compose = (dict) -> dict.compose

functorFn = Functor compose(semigroupoidFn)

compare = (dict) -> dict.compare

ordArrayImpl = (f) -> (xs) -> (ys) ->
  [xlen, ylen, i] = [xs.length, ys.length, 0]
  while i < xlen && i < ylen
    [x, y] = [xs[i], ys[i]]
    ord = f(x)(y)
    return ord if ord != 0
    i++
  if xlen == ylen
    0
  else if xlen > ylen
    -1
  else
    1

ordArray = (dictOrd) ->
  cmp = (xs) -> (ys) ->
    compareZero = compare(ordInt)(0)
    wrapper = (x) -> (y) ->
      result = compare(dictOrd)(x)(y)
      switch result.ctor
        when EQ then 0
        when LT then 1
        when GT then -1
        else throw new Error('Not valid compare returned')
    compareZero ordArrayImpl(ordArrayImpl)(xs)(ys)
  Ord -> eqArray(dictOrd.eq(), cmp)

less = (dictOrd) -> (a1) -> (a2) ->
  rs = compare(dictOrd)(a1)(a2)
  if rs.ctor == 'LT' then true else false

lessEqual = (dictOrd) -> (a1) -> (a2) ->
  rs = compare(dictOrd)(a1)(a2)
  if rs.ctor == 'GT' then false else true

greater = (dictOrd) -> (a1) -> (a2) ->
  rs = compare(dictOrd)(a1)(a2)
  if rs.ctor == 'GT' then true else false

lessEqual = (dictOrd) -> (a1) -> (a2) ->
  rs = compare(dictOrd)(a1)(a2)
  if rs.ctor == 'LT' then false else true

categoryFn = Category ->
  semigroupoidFn
, identity

boundedUnit = Bounded unit, unit
boundedOrdering = Bounded LT, GT

boundedOrdUnit = BoundedOrd ->
  boundedUnit
, -> ordUnit
boundedOrdOrdering = BoundedOrd ->
  boundedOrdering
, -> ordOrdering

boundedInt = Bounded -2147483648, 2147483647

boundedOrdInt = BoundedOrd ->
  boundedInt
, -> ordInt

boundedChar = Bounded String.fromCharCode(0), String.fromCharCode(65535)
boundedOrdChar = BoundedOrd ->
  BoundedChar
, -> ordChar

boundedBoolean = Bounded false, true
boundedOrdBoolean = BoundedOrd ->
  boundedBoolean
, -> ordBoolean

bottom = (dict) -> dict.bottom

boundedFn = (dictBounded) ->
  Bounded ->
    bottom(dictBounded)
  , -> top(dictBounded)

booleanAlgebraUnit = do ->
  always2 = (x) -> (y) -> unit
  always1 = (x) -> unit
  BooleanAlgebra ->
    boundedUnit
  , always2, always2, always1

booleanAlgebraFn = (dictBooleanAlgebra) ->
  bdFn = ->
    boundedFn(dictBooleanAlgebra.bounded)
  conjOrdisj = (met) -> (fx) -> (fy) -> (a) ->
    met(dictBooleanAlgebra)(fx(a))(fy(a))
  _not = (fx) -> (a) ->
    dictBooleanAlgebra.not(fx(a))
  BooleanAlgebra bdFn, conjOrdisj(conj), conjOrdisj(disj), _not

booleanAlgebraBoolean = do ->
  boolOr = (b1) -> (b2) ->
    b1 or b2
  boolAnd = (b1) -> (b2) ->
    b1 and b2
  boolNot = (b) ->
    not b
  BooleanAlgebra ->
    boundedBoolean
  , boolAnd, boolOr, boolNot

bind = (dict) -> dict.bind

liftM1 = (dictMonad) -> (f) -> (a) ->
  wrapper = (v) ->
    pure(dictMonad.applicative())(f(v))
  bind(dictMonad.bind())(a)(wrapper)

applyFn = do ->
  funct = -> functorFn
  applyImpl = (f) -> (g) -> (x) ->
    f(x)(g(x))
  Apply funct, applyImpl

bindFn = do ->
  binder = (m) -> (f) -> (x) ->
    f(m(x))(x)
  Bind ->
    applyFn
  , binder

apply = (dict) ->
  dict.apply

liftA1 = (dictApplicative) -> (f) -> (a) ->
  apply(dictApplicative.apply())(pure(dictApplicative)(f))(a)

applicativeFn = Applicative ->
  applyFn
, first

monadFn = Monad ->
  applicativeFn
, -> bindFn

append = (dict) ->
  dict.append

semigroupFn = (dictSemigroup) ->
  Semigroup (f) -> (g) -> (x) ->
    append(dictSemigroup)(f(x))(g(x))

ap = (dictMonad) -> (f) -> (a) ->
  bind(dictMonad.bind())(f)((v) ->
    bind(dictMonad.bind())(a)((v2) ->
      pure(dictMonad.applicative())(v(v1))
    )
  )

applyArray = Apply ->
  functorArray
, ap(monadArray)

bindArray = do ->
  appli = -> applyArray
  arrayBind = (arr) -> (f) ->
    (f(item) for item in arr)
  Bind appli, arrayBind

applicativeArray = Applicative ->
  applyArray
, (x) -> [x]

monadArray = Monad ->
  applicativeArray
, -> bindArray

add = (dict) ->
  dict.add

module.exports =
  LT: LT
  GT: GT
  EQ: EQ
  Show: Show
  BooleanAlgebra: BooleanAlgebra
  BoundedOrd: BoundedOrd
  Bounded: Bounded
  Ord: Ord
  Eq: Eq
  DivisionRing: DivisionRing
  Num: Num
  Ring: Ring
  ModuloSemiring: ModuloSemiring
  Semiring: Semiring
  Semigroup: Semigroup
  Monad: Monad
  Bind: Bind
  Applicative: Applicative
  Apply: Apply
  Functor: Functor
  Category: Category
  Semigroupoid: Semigroupoid
  show: show
  disj: disj
  conj: conj
  bottom: bottom
  top: top
  nativeCompare: nativeCompare
  compare: compare
  eq: eq
  negate: negate
  sub: sub
  mod: mod
  div: div
  one: one
  mul: mul
  zero: zero
  add: add
  append: append
  ap: ap
  liftM1: liftM1
  bind: bind
  liftA1: liftA1
  pure: pure
  apply: apply
  map: map
  id: id
  compose: compose
  first: first
  flip: flip
  unit: unit
  semigroupoidFn: semigroupoidFn
  categoryFn: categoryFn
  functorFn: functorFn
  functorArray: functorArray
  applyFn: applyFn
  applyArray: applyArray
  applicativeFn: applicativeFn
  applicativeArray: applicativeArray
  bindFn: bindFn
  bindArray: bindArray
  monadFn: monadFn
  monadArray: monadArray
  semigroupString: semigroupString
  semigroupUnit: semigroupUnit
  semigroupFn: semigroupFn
  semigroupOrdering: semigroupOrdering
  semigroupArray: semigroupArray
  semiringInt: semiringInt
  semiringNumber: semiringNumber
  semiringUnit: semiringUnit
  ringInt: ringInt
  ringNumber: ringNumber
  ringUnit: ringUnit
  moduloSemiringInt: moduloSemiringInt
  moduloSemiringNumber: moduloSemiringNumber
  moduloSemiringUnit: moduloSemiringUnit
  divisionRingNumber: divisionRingNumber
  divisionRingUnit: divisionRingUnit
  numNumber: numNumber
  numUnit: numUnit
  eqBoolean: eqBoolean
  eqInt: eqInt
  eqNumber: eqNumber
  eqChar: eqChar
  eqString: eqString
  eqUnit: eqUnit
  eqArray: eqArray
  eqOrdering: eqOrdering
  ordBoolean: ordBoolean
  ordInt: ordInt
  ordNumber: ordNumber
  ordString: ordString
  ordChar: ordChar
  ordUnit: ordUnit
  ordArray: ordArray
  ordOrdering: ordOrdering
  boundedBoolean: boundedBoolean
  boundedUnit: boundedUnit
  boundedOrdering: boundedOrdering
  boundedInt: boundedInt
  boundedChar: boundedChar
  boundedFn: boundedFn
  boundedOrdBoolean: boundedOrdBoolean
  boundedOrdUnit: boundedOrdUnit
  boundedOrdOrdering: boundedOrdOrdering
  boundedOrdInt: boundedOrdInt
  boundedOrdChar: boundedOrdChar
  booleanAlgebraBoolean: booleanAlgebraBoolean
  booleanAlgebraUnit: booleanAlgebraUnit
  booleanAlgebraFn: booleanAlgebraFn
  showBoolean: showBoolean
  showInt: showInt
  showNumber: showNumber
  showChar: showChar
  showString: showString
  showUnit: showUnit
  showArray: showArray
  showOrdering: showOrdering
