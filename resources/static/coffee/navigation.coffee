scheduler = require './core/scheduler'
platform = require './core/platform'
{Just, Nothing} = require './core/maybe'
{map, fromArray} = require './core/list'
{sequence, andThen} = require './core/task'
{ok} = require './core/result'
{invoke3, invoke2} = require './utils/functools'
{Tuple0} = require './utils/common'
{onWindow} = require './dom/window'

go = (n) ->
  scheduler.nativeBinding (callback) ->
    history.go(n) if n != 0
    callback(scheduler.succeed(Tuple0))

pushState = (url) ->
  scheduler.nativeBinding (callback) ->
    history.pushState({}, '', url)
    callback(scheduler.succeed(getLocation()))

replaceState = (url) ->
  scheduler.nativeBinding (callback) ->
    history.replaceState({}, '', url)
    callback(scheduler.succeed(getLocation()))

# need wrap this, so it dynamic
getLocation = ->
  document.location

andThenHelp = (task1) -> (task2) ->
  wrap = (_v) ->
    task2
  andThen(task1)(wrap)

spawnPopState = (router) ->
  toTask = (_e) ->
    invoke2(platform.sendToSelf, router, getLocation())
  spawn invoke3(onWindow, 'popstate', ok, toTask)

notify = (router) -> (subs) -> (location) ->
  callback = (val) ->
    invoke2(platform.sendToApp, router, val._0(location))
  if Array.isArray(sub)
    subs = fromArray(subs)
  invoke2(andThenHelp, sequence(invoke2(map, callback, subs)), scheduler.succeed(Tuple0))

onSelfMsg = (router) -> (location) -> (state) ->
  job = invoke3(notify, router, state.subs, location)
  invoke2(andThenHelp, job, scheduler.succeed(location))

cmdHelp = (router) -> (subs) -> (cmd) ->
  switch cmd.ctor
    when 'Jump' then go cmd._0
    when 'New' then invoke2 pushState(cmd._0), invoke2(notify, router, subs)
    else invoke2 replaceState(cmd._0), invoke2(notify, router, subs)

updateHelp = (func) -> (val) ->
  ctor: '_Tuple2'
  _0: val._0
  _1: invoke2 platform.map, val._1

subscription = platform.leaf("Navigation")
command = platform.leaf("Navigation")

Location = (a) -> (b) -> (c) -> (d) -> (e) -> (f) -> (g) -> (h) -> (i) -> (j) -> (k) ->
  href: a
  host: b
  hostname: c
  protocol: d
  origin: e
  port: f
  pathname: g
  search: h
  hash: i
  username: j
  password: k

State = (a) -> (b) ->
  subs: a
  process: b

init = platform.succeed invoke2(State, fromArray([]), Nothing)

onEffects = (router) -> (cmds) -> (subs) -> (val) ->
  proc = val.process
  stepState = do ->
    step = ctor: '_Tuple2', _0: subs, _1: proc
    if step._0.ctor == '[]' and step._1.ctor == 'Just'
      invoke2 andThenHelp, scheduler.kill(step._1._0), scheduler.succeed(State(subs)(Nothing))
    else if step._1.ctor == 'Nothing'
      wrap = (pid) ->
        scheduler.succeed State(subs)(Just(pid))
      invoke2 andThenHelp, spawnPopState(router), wrap
    else
      scheduler.succeed State(subs)(proc)
  job = invoke2 map, invoke2(cmdHelp, router, subs), cmds
  invoke2 andThenHelp, sequence(job), stepState

UserMsg = (a) ->
  ctor: 'UserMsg'
  _0: a

Change = (a) ->
  ctor: 'Change'
  _0: a

Parser = (a) ->
  ctor: 'Parser'
  _0: a

makeParser = Parser

Modify = (a) ->
  ctor: 'Modify'
  _0: a

modifyUrl = (url) ->
  command Modify(url)

NewUrl = (a) ->
  ctor: 'New'
  _0: a

newUrl = (url) ->
  command NewUrl(url)

Jump = (a) ->
  ctor: 'Jump'
  _0: a

back = (n) ->
  command Jump(0 - n)

forward = (n) ->
  command Jump(n)

cmdMap = (__, myCmd) ->
  switch myCmd.ctor
    when 'Jump' then Jump myCmd._0
    when 'New' then NewUrl myCmd._0
    else Modify myCmd._0

Monitor = (a) ->
  ctor 'Monitor'
  _0: a

programWithFlags = (parser) -> (stuff) ->
  data = parser._0
  location = getLocation()
  init = (flags) ->
    invoke2 updateHelp, UserMsg, invoke2(stuff.init, flags, data(location))
