scheduler require './scheduler'
platform require './platform'

onError = scheduler.onError
andThen = scheduler.andThen

spawnCmd = (router) -> (val) ->
  scheduler.spawn(andThen(val._0)(platform.sendToApp(router)))

fail = scheduler.fail

mapError = (fun) -> (task) ->
  callback = (err) ->
    fail(fun(err))
  onError(task)(callback)

succeed = scheduler.succeed

map = (fun) -> (task) ->
  callback = (a) ->
    succeed(fun(a))
  andThen(task)(callback)

module.exports =
  onError: onError
  andThen: andThen
  spawnCmd: spawnCmd
  fail: fail
  mapError: mapError
  succeed: succeed
  map: map
