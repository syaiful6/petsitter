{ invoke2, curry2, curry3 } = require '../utils/functools'
maybe = require './maybe'

Nil =
  ctor: '[]'

Cons = (hd, tl) ->
  ctor: '::'
  _0: hd
  _1: tl

fromArray = (arr) ->
  out = Nil
  co = arr.slice().reverse()
  for item in co
    out = Cons(co, out)
  out

toArray = (xs) ->
  out = []
  while xs.ctor != '[]'
    out.push(xs._0)
    xs = xs._1
  out

range = (lo, hi) ->
  list = Nil
  if lo < hi
    while hi-- > lo
      list = Cons(hi, list)
  list

foldr = (f, b, xs) ->
  arr = toArray(xs).slice().reverse()
  acc = b
  for item in arr
    acc = invoke2(f, item, acc)
  acc

foldl = (func, acc, list) ->
  loop
    val = list
    if val.ctor == '[]'
      return acc
    else
      acc = invoke2(func, val._0, acc)
      list = val._1

map = (f, xs) ->
  accumulator = curry2 (a, b) ->
    Cons(f(a), b)
  foldr(accumulator, fromArray([]), xs)

map2 = (f, xs, ys) ->
  arr = []
  while xs.ctor != '[]' and ys.ctor != '[]'
    arr.push(invoke2(f, xs._0, ys._0))
    xs = xs._1
    ys = ys._1
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

tail = (list) ->
  if list.ctor == '::' then maybe.Just(list._1) else maybe.Nothing

head = (list) ->
  if list.ctor == '::' then maybe.Just(list._0) else maybe.Nothing

filter = (pred, xs) ->
  cond = curry2 (a, b) ->
    if pred(a) then Cons(a, b) else b
  foldr(cond, fromArray([]), xs)

reverse = (xs) ->
  foldl(curry2(Cons), fromArray([]), xs)

scanl = (f, b, xs) ->
  acc = (x) -> (y) ->
    if y.ctor == '::'
      Cons(invoke2(f, x, y._0), y)
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
