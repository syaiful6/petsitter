{ invoke2 } = require '../utils/functools'

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
