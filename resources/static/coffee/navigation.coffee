scheduler = require './core/scheduler'
platform = require './core/platform'
{Right} = require './core/data/either'
{Just, Nothing} = require './core/data/maybe'
{map, fromArray} = require './core/data/list'
{sequence, andThen} = require './core/task'
{invoke3, invoke2} = require './utils/functools'
{Tuple0} = require './utils/common'
{onWindow} = require './dom/window'
app = require './dom/app'

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

  {
    href: location.href
    host: location.host
    hostname: location.hostname
    protocol: location.protocol
    origin: location.origin
    port: location.port
    pathname: location.pathname
    search: location.search
    hash: location.hash
    username: location.username
    password: location.password
  }

andThenHelp = (task1) -> (task2) ->
  wrap = (_v) ->
    task2
  andThen(task1)(wrap)

spawnPopState = (router) ->
  toTask = (_e) ->
    invoke2(platform.sendToSelf, router, getLocation())
  scheduler.spawn invoke3(onWindow, 'popstate', Right, toTask)

notify = (router) -> (subs) -> (location) ->
  callback = (val) ->
    invoke2(platform.sendToApp, router, val.value0(location))
  if Array.isArray(subs)
    subs = fromArray(subs)
  invoke2(andThenHelp, sequence(invoke2(map, callback, subs)), scheduler.succeed(Tuple0))

onSelfMsg = (router) -> (location) -> (state) ->
  job = invoke3(notify, router, state.subs, location)
  invoke2(andThenHelp, job, scheduler.succeed(state))

cmdHelp = (router) -> (subs) -> (cmd) ->
  switch cmd.ctor
    when 'Jump' then go cmd.value0
    when 'New' then invoke2 andThen, pushState(cmd.value0), invoke2(notify, router, subs)
    else invoke2 andThen, replaceState(cmd.value0), invoke2(notify, router, subs)

updateHelp = (func) -> (val) ->
  ctor: '_Tuple2'
  value0: val.value0
  value1: invoke2 platform.map, func, val.value1

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

init = scheduler.succeed invoke2(State, fromArray([]), Nothing)

onEffects = (router) -> (cmds) -> (subs) -> (val) ->
  proc = val.process
  stepState = do ->
    step = ctor: '_Tuple2', value0: subs, value1: proc
    if step.value0.ctor == '[]'
      if step.value1.ctor == 'Just'
        return invoke2 andThenHelp, scheduler.kill(step.value1.value0), scheduler.succeed(State(subs)(Nothing))
      else
        return scheduler.succeed State(subs)(proc)
    else
      if step.value1.ctor == 'Nothing'
        wrap = (pid) ->
          scheduler.succeed State(subs)(Just(pid))
        return invoke2 andThen, spawnPopState(router), wrap
      else
        return scheduler.succeed State(subs)(proc)
  job = invoke2 map, invoke2(cmdHelp, router, subs), cmds
  invoke2 andThenHelp, sequence(job), stepState

UserMsg = (a) ->
  ctor: 'UserMsg'
  value0: a

Change = (a) ->
  ctor: 'Change'
  value0: a

Parser = (a) ->
  ctor: 'Parser'
  value0: a

makeParser = Parser

Modify = (a) ->
  ctor: 'Modify'
  value0: a

modifyUrl = (url) ->
  command Modify(url)

NewUrl = (a) ->
  ctor: 'New'
  value0: a

newUrl = (url) ->
  command NewUrl(url)

Jump = (a) ->
  ctor: 'Jump'
  value0: a

back = (n) ->
  command Jump(0 - n)

forward = (n) ->
  command Jump(n)

cmdMap = (__) -> (myCmd) ->
  switch myCmd.ctor
    when 'Jump' then Jump myCmd.value0
    when 'New' then NewUrl myCmd.value0
    else Modify myCmd.value0

Monitor = (a) ->
  ctor: 'Monitor'
  value0: a

programWithFlags = (parser) -> (stuff) ->
  data = parser.value0
  location = getLocation()
  init = (flags) ->
    invoke2 updateHelp, UserMsg, invoke2(stuff.init, flags, data(location))
  view = (model) ->
    invoke2 app.map, UserMsg, stuff.view(model)
  subs = (model) ->
    platform.batch fromArray([
      subscription(Monitor(Change)),
      invoke2 platform.map, UserMsg, stuff.subscriptions(model)
    ])
  intent = (msg) -> (model) ->
    invoke2 updateHelp, UserMsg, do ->
      m = msg
      if m.ctor == 'Change'
        invoke2 stuff.urlUpdate, data(m.value0), model
      else
        invoke2 stuff.update, m.value0, model
  app.programWithFlags
    init: init
    view: view
    update: intent
    subscriptions: subs

program = (parser) -> (stuff) ->
  invoke2 programWithFlags, parser, do (stuff) ->
    newField =
      init: (__) -> stuff.init
    newRecord = {}
    for own key of stuff
      value = if key of newField then newField[key] else stuff[key]
      newRecord[key] = value
    newRecord

subMap = (func) -> (val) ->
  Monitor (el) -> func(val.value0(el))

unless 'Navigation' of platform.effectManagers
  platform.effectManagers['Navigation'] =
    pkg: 'app/navigation'
    init: init
    onEffects: onEffects
    onSelfMsg: onSelfMsg
    tag: 'fx'
    cmdMap: cmdMap
    subMap: subMap

module.exports =
  program: program
  programWithFlags: programWithFlags
  modifyUrl: modifyUrl
  newUrl: newUrl
  back: back
  forward: forward
  makeParser: makeParser
