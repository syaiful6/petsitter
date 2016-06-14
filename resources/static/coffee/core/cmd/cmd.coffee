platform = require '../platform'
{fromArray, Nil} = require '../data/list'

# aliases
map = platform.map

batch = platform.batch

none = batch Nil

action = (model) -> (cmd) ->
  ctor: '_Tuple2'
  value0: model
  value1: batch(cmd)

module.exports =
  map: map
  batch: batch
  none: none
  action: action
