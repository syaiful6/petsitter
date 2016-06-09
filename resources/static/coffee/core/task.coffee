scheduler require './scheduler'
platform require './platform'
maybe require './maybe'
list = require './list'

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

map2 = (fun) -> (taskA) -> (taskB) ->
  callback = (a) ->
    inner = (b) ->
      succeed(fun(a)(b))
    andThen(taskB)(inner)
  andThen(taskA)(callback)

map3 = (fun) -> (taskA) -> (taskB) -> (taskC) ->
  callback = (a) ->
    inner1 = (b) ->
      inner2 = (c) ->
        succeed(fun(a)(b)(c))
      andThen(taskC)(inner2)
    andThen(taskB)(inner1)
  andThen(taskA)(callback)

map4 = (fun) -> (taskA) -> (taskB) -> (taskC) -> (taskD) ->
  callback = (a) ->
    inner1 = (b) ->
      inner2 = (c) ->
        inner3 = (d) ->
          succeed(fun(a)(b)(c)(d))
        andThen(taskD)(inner3)
      andThen(taskC)(inner2)
    andThen(taskB)(inner1)
  andThen(taskA)(callback)

map5 = (fun) -> (taskA) -> (taskB) -> (taskC) -> (taskD) -> (taskE) ->
  callback = (a) ->
    inner1 = (b) ->
      inner2 = (c) ->
        inner3 = (d) ->
          inner4 = (e) ->
            succeed(fun(a)(b)(c)(d)(e))
          andThen(taskE)(inner4)
        andThen(taskD)(inner3)
      andThen(taskC)(inner2)
    andThen(taskB)(inner1)
  andThen(taskA)(callback)

andMap = (taskFunc) -> (taskValue) ->
  callback = (func) ->
    inner = (value) ->
      succeed(func(value))
    andThen(taskValue)(inner)
  andThen(taskFunc)(callback)

sequence = (tasks) ->
  if Array.isArray(tasks)
    tasks = list.fromArray(tasks)
  if tasks.ctor == '[]'
    succeed(fromArray([]))
  else
    wrapped = (x) -> (y) ->
      list.Cons(x, y)
    map2(wrapped)(tasks._0)(sequence(tasks._1))

onEffects = (router) -> (commands) -> (state) ->
  callback = (_x) ->
    {ctor: '_Tuple0'}
  map(callback)(sequence(list.map(spawnCmd(router)(commands))))

toMaybe = (task) ->
  wrapped = (_x) ->
    succeed(maybe.Nothing)
  onError(map(maybe.Just)(task))(wrapped)

command = platform.leaf('Task')
T = (x) ->
  ctor: 'T'
  _0: x

perform = (onFail) -> (onSuccess) -> (task) ->
  wrapped = (x) ->
    succeed(onFail(x))
  command(T(onError(map(onSuccess)(task))(wrapped)))

cmdMap = (tagger) -> (task) ->
  T(map(tagger)(task))

module.exports =
  onError: onError
  andThen: andThen
  spawnCmd: spawnCmd
  fail: fail
  mapError: mapError
  succeed: succeed
  map: map
  map2: map2
  map3: map3
  map4: map4
  map5: map5
  andMap: andMap
  sequence: sequence
  onEffects: onEffects
  toMaybe: toMaybe
  command: command
  perform: perform
  cmdMap: cmdMap
