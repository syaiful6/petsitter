{curry} = require '../core/lambda'

singleton = (k, v) ->
  obj = {}
  obj[k] = v
  obj

extend = (original, update) ->
  rec = (a, b) ->
    for i of b
      a[i] = b[i]
    a
  rec rec({}, original), update

prop = (key, obj) ->
  obj[key]

module.exports =
  singleton: curry singleton
  extend: curry extend
  prop: curry prop
