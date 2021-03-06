{curry} = require '../core/lambda'

counter = 0

toString = Object::toString

guid = ->
  counter++

Tuple0 =
  ctor: '_Tuple0'

Tuple2 = (x, y) ->
  ctor: '_Tuple2'
  value0: x
  value1: y

# type :: * -> String
type = (x) ->
  toString.call(x).slice 8, -1

isType = (tp, v) ->
  type(v) == tp

chr = (x) ->
  new String(x)

# update Old record to new fields
update = (oldRecord, updatedFields) ->
  newRecord = {}
  for own key of oldRecord
    value = if key of updatedFields then updatedFields[key] else oldRecord[key]
    newRecord[key] = value
  newRecord

getInstance = (self, ctor) ->
  if self instanceof ctor then self else Object.create ctor.prototype

module.exports =
  guid: guid
  Tuple0: Tuple0
  Tuple2: curry Tuple2
  update: curry update
  chr: chr
  getInstance: curry getInstance
  isType: curry isType
  type: type
