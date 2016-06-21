counter = 0

guid = ->
  counter++

Tuple0 =
  ctor: '_Tuple0'

Tuple2 = (x, y) ->
  ctor: '_Tuple2'
  value0: x
  value1: y

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
  Tuple2: Tuple2
  update: update
  chr: chr
  getInstance: getInstance
