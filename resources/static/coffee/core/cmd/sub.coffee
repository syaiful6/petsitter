platform = require '../platform'
{fromArray, Nil} = require '../list'

map = platform.map

batch = platform.batch

none = batch Nil

module.exports =
  map: map
  batch: batch
  none: none
