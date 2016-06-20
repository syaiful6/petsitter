maybe = require './maybe'
{ curry } = require '../core/lambda'

Nil =
  ctor: '[]'

Cons = (hd, tl) ->
  ctor: '::'
  value0: hd
  value1: tl

uncons = (ls) ->
  return maybe.Nothing() if v.ctor == '[]'
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
    acc = f(arr[i], acc)
  acc

foldl = (func, acc, list) ->
  loop
    val = list
    if val.ctor == '[]'
      return acc
    else
      acc = func val.value0, acc
      list = val.value1

map = (f, xs) ->
  accumulator = curry (a, b) ->
    Cons(f(a), b)
  foldr(accumulator, fromArray([]), xs)

map2 = (f, xs, ys) ->
  arr = []
  while xs.ctor != '[]' and ys.ctor != '[]'
    arr.push f(xs.value0, ys.value0)
    xs = xs.value1
    ys = ys.value1
  fromArray(arr)

length = (list) ->
  accumulator = curry (_, a) ->
    a + 1
  foldl(accumulator, 0, list)

sum = (numbers) ->
  accumulator = curry (a, b) ->
    a + b
  foldl(accumulator, 0, numbers)

product = (numbers) ->
  accumulator = curry (a, b) ->
    a * b
  foldl(accumulator, 1, numbers)

isEmpty = (list) ->
  list.ctor == '[]'

# tail :: List -> Maybe a
tail = (list) ->
  if list.ctor == '::' then maybe.Just(list.value1) else maybe.Nothing()

# head :: List -> Maybe a
head = (list) ->
  if list.ctor == '::' then maybe.Just(list.value0) else maybe.Nothing()

filter = (pred, xs) ->
  cond = curry (a, b) ->
    if pred(a) then Cons(a, b) else b
  foldr(cond, fromArray([]), xs)

reverse = (xs) ->
  foldl(curry(Cons), fromArray([]), xs)

scanl = (f, b, xs) ->
  acc = (x) -> (y) ->
    if y.ctor == '::'
      Cons f(x, y.value0), y
    else
      fromArray([])
  reverse(foldl(acc, fromArray[b], xs))

append = (xs, ys) ->
  return xs if ys.ctor == '[]'
  foldl(curry(Cons), ys, xs)

concat = (xs) ->
  foldr(curry(append), fromArray([]), xs)

concatMap = (fun, list) ->
  concat(map(fun, list))

class List
  constructor: (@link) ->

  @of: (val) ->
    new List singleton(val)

  toArray: ->
    toArray @link

  foldl: (func, acc) ->
    foldl(func, acc, @link)

  foldr: (func, acc) ->
    foldr(func, acc, @link)

  reduce: (func, acc) ->
    @foldl func, acc

  map: (fun) ->
    new List map(fun, @link)

module.exports =
  Nil: Nil
  Cons: Cons
  cons: curry(Cons)
  fromArray: fromArray
  toArray: toArray
  range: curry(range)
  map: curry(map)
  map2: curry(map2)
  foldr: curry(foldr)
  foldl: curry(foldl)
  length: length
  sum: sum
  product: product
  filter: curry(filter)
  reverse: reverse
  scanl: curry(scanl)
  append: curry(append)
  tail: tail
  head: head
  concat: concat
  concatMap: curry(concatMap)
