counter = 0

guid = ->
  counter++

Tuple0 =
  ctor: '_Tuple0'

Tuple2 = (x, y) ->
  ctor: '_Tuple2'
  _0: x
  _1: y

chr = (x) ->
  new String(x)

update = (oldRecord, updatedFields) ->
  newRecord = {}
  for key of oldRecord
    value = if key of updatedFields then updatedFields[key] else oldRecord[key]
    newRecord[key] = value
  newRecord

module.exports =
  guid: guid
  Tuple0: Tuple0
  Tuple2: Tuple2
  update: update
  chr: chr