scheduler = require './scheduler'
platform = require './platform'
{curry} = require './lambda'
Maybe = require '../data/maybe'
list = require '../data/list'

onError = scheduler.onError
andThen = scheduler.andThen

spawnCmd = curry (router, val) ->
  scheduler.spawn andThen(val.value0, platform.sendToApp(router))

fail = scheduler.fail

mapError = curry (fun, task) ->
  callback = (err) ->
    fail(fun(err))
  onError(task, callback)

succeed = scheduler.succeed

map = curry (fun, task) ->
  callback = (a) ->
    succeed(fun(a))
  andThen(task, callback)

map2 = curry (fun, taskA, taskB) ->
  callback = (a) ->
    inner = (b) ->
      succeed fun(a, b)
    andThen(taskB, inner)
  andThen(taskA, callback)

map3 = curry (fun, taskA, taskB, taskC) ->
  callback = (a) ->
    inner1 = (b) ->
      inner2 = (c) ->
        succeed fun(a, b, c)
      andThen(taskC, inner2)
    andThen(taskB, inner1)
  andThen(taskA, callback)

map4 = curry (fun, taskA, taskB, taskC, taskD) ->
  callback = (a) ->
    inner1 = (b) ->
      inner2 = (c) ->
        inner3 = (d) ->
          succeed fun(a, b, c, d)
        andThen(taskD, inner3)
      andThen(taskC, inner2)
    andThen(taskB, inner1)
  andThen(taskA, callback)

map5 = curry (fun, taskA, taskB, taskC, taskD, taskE) ->
  callback = (a) ->
    inner1 = (b) ->
      inner2 = (c) ->
        inner3 = (d) ->
          inner4 = (e) ->
            succeed fun(a, b, c, d, e)
          andThen(taskE, inner4)
        andThen(taskD, inner3)
      andThen(taskC, inner2)
    andThen(taskB, inner1)
  andThen(taskA, callback)

andMap = curry (taskFunc, taskValue) ->
  callback = (func) ->
    inner = (value) ->
      succeed func(value)
    andThen(taskValue, inner)
  andThen(taskFunc, callback)

sequence = (tasks) ->
  if Array.isArray(tasks)
    tasks = list.fromArray(tasks)
  if tasks.ctor == '[]'
    succeed(list.fromArray([]))
  else
    wrapped = curry (x, y) ->
      list.cons(x, y)
    map2 wrapped, tasks.value0, sequence(tasks.value1)

onEffects = curry (router, commands, state) ->
  callback = (_x) ->
    {ctor: '_Tuple0'}
  map callback, sequence(list.map(spawnCmd(router), commands))

toMaybe = (task) ->
  wrapped = (_x) ->
    succeed Maybe.Nothing()
  onError map(Maybe.Just, task), wrapped

command = platform.leaf('Task')

onSelfMsg = curry.to 3, ->
  succeed({ctor: '_Tuple0'})

T = (x) ->
  ctor: 'T'
  value0: x

perform = curry (onFail, onSuccess, task) ->
  wrapped = (x) ->
    succeed onFail(x)
  command T(onError(map(onSuccess, task), wrapped))

cmdMap = curry (tagger, task) ->
  T map(tagger, task.value0)

unless 'Task' of platform.effectManagers
  platform.effectManagers['Task'] =
    pkg: 'app/task'
    init: succeed({ctor: '_Tuple0'})
    onEffects: onEffects
    onSelfMsg: onSelfMsg
    tag: 'cmd'
    cmdMap: cmdMap

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
