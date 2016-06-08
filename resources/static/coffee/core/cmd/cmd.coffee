platform = require '../platform'
{fromArray, Nil} = require '../list'

# aliases
map = platform.map

batch = platform.batch

none = batch Nil

action = (model) -> (cmd) ->
  ctor: '_Tuple2'
  _0: model
  _1: batch(cmd)

module.exports =
  map: map
  batch: batch
  none: none
  action: action
