lambda = require '../core/lambda'

# tuple data structure
Tuple = (value0, value1) ->
  {
    ctor: 'Tuple'
    value0: value0
    value1: value1
  }

create = lambda.curry (value0, value1) ->
  Tuple value0, value1

uncurry = lambda.curry (fun, tuple) ->
  fun(tuple.value0)(tuple.value1)

curry = (fun) -> (a) -> (b) ->
  fun(Tuple(a, b))

swap = (v) ->
  Tuple v.value1, v.value0

snd = (v) ->
  v.value1

fst = (v) ->
  v.value0

module.exports =
  Tuple: Tuple
  create: create
  snd: snd
  fst: fst
  curry: curry
  uncurry: uncurry
  swap: swap
