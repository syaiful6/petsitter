maybe = require './maybe'
control = require '../prelude/control'
foldable = require './foldable'
monoid = require './monoid'
semigroup = require '../prelude/semigroup'
{ invoke2, invoke3, curry2, curry3 } = require '../../utils/functools'

Nil =
  ctor: '[]'

Cons = (hd, tl) ->
  ctor: '::'
  value0: hd
  value1: tl

uncons = (ls) ->
  return maybe.Nothing if v.ctor == '[]'
  maybe.Just {
    head: value0
    tail: value1
  }

# fromArray :: Array -> List
fromArray = (arr) ->
  out = Nil
  i = arr.length
  while i--
    out = Cons(arr[i], out)
  out

# toArray :: List -> Array
toArray = (xs) ->
  out = []
  while xs.ctor != '[]'
    out.push(xs.value0)
    xs = xs.value1
  out

# range :: Int -> Int -> List Int
range = (lo, hi) ->
  list = Nil
  if lo < hi
    while hi-- > lo
      list = Cons(hi, list)
  list

# singleton :: forall a. a -> List a
singleton = (a) ->
  Cons a, Nil

# foldr ::
foldr = (f, b, xs) ->
  arr = toArray(xs)
  acc = b
  i = arr.length
  while i--
    acc = invoke2(f, arr[i], acc)
  acc

foldl = (func, acc, list) ->
  loop
    val = list
    if val.ctor == '[]'
      return acc
    else
      acc = invoke2(func, val.value0, acc)
      list = val.value1

map = (f, xs) ->
  accumulator = curry2 (a, b) ->
    Cons(f(a), b)
  foldr(accumulator, fromArray([]), xs)

map2 = (f, xs, ys) ->
  arr = []
  while xs.ctor != '[]' and ys.ctor != '[]'
    arr.push(invoke2(f, xs.value0, ys.value0))
    xs = xs.value1
    ys = ys.value1
  fromArray(arr)

length = (list) ->
  accumulator = curry2 (_, a) ->
    a + 1
  foldl(accumulator, 0, list)

sum = (numbers) ->
  accumulator = curry2 (a, b) ->
    a + b
  foldl(accumulator, 0, numbers)

product = (numbers) ->
  accumulator = curry2 (a, b) ->
    a * b
  foldl(accumulator, 1, numbers)

isEmpty = (list) ->
  list.ctor == '[]'

# tail :: List -> Maybe a
tail = (list) ->
  if list.ctor == '::' then maybe.Just(list.value1) else maybe.Nothing

# head :: List -> Maybe a
head = (list) ->
  if list.ctor == '::' then maybe.Just(list.value0) else maybe.Nothing

filter = (pred, xs) ->
  cond = curry2 (a, b) ->
    if pred(a) then Cons(a, b) else b
  foldr(cond, fromArray([]), xs)

reverse = (xs) ->
  foldl(curry2(Cons), fromArray([]), xs)

scanl = (f, b, xs) ->
  acc = (x) -> (y) ->
    if y.ctor == '::'
      Cons(invoke2(f, x, y.value0), y)
    else
      fromArray([])
  reverse(foldl(acc, fromArray[b], xs))

append = (xs, ys) ->
  return xs if ys.ctor == '[]'
  foldl(curry2(Cons), ys, xs)

concat = (xs) ->
  foldr(curry2(append), fromArray([]), xs)

concatMap = (fun, list) ->
  concat(map(fun, list))

functorList = control.Functor curry2(map)
foldableList = foldable.Foldable (dictMonoid) ->
  (f) ->
    foldMWrapper = (acc) ->
      (v) ->
        invoke3 semigroup.append, dictMonoid.semigroup(), acc, f(v)
    invoke3 foldable.foldl, foldableList, foldMWrapper, monoid.mempty(dictMonoid)
, curry3(foldl)
, curry3(foldr)

module.exports =
  Nil: Nil
  Cons: Cons
  cons: curry2(Cons)
  fromArray: fromArray
  toArray: toArray
  range: curry2(range)
  map: curry2(map)
  map2: curry3(map2)
  foldr: curry3(foldr)
  foldl: curry3(foldl)
  length: length
  sum: sum
  product: product
  filter: curry2(filter)
  reverse: reverse
  scanl: curry3(scanl)
  append: curry2(append)
  tail: tail
  head: head
  concat: concat
  concatMap: curry2(concatMap)
  functorList: functorList
  foldableList: foldableList