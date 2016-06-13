# Tuple data utility

# represent tuple
Tuple = (x) -> (y) ->
  ctor: 'Tuple'
  value0: x
  value1: y

uncurry = (f) -> (tuple) ->
  f(tuple.value0)(tuple.value1)

curry = (f) -> (a) -> (b) ->
  f(Tuple(a, a))

swap = (tuple) ->
  Tuple(value1)(value0)

fst = (tuple) ->
  tuple.value0

snd = (tuple) ->
  tuple.value1
