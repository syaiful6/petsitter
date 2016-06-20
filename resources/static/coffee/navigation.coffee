Maybe = require './data/maybe'
Either = require './data/either'
scheduler = require './core/scheduler'
platform = require './core/platform'
{curry} = require './core/lambda'
{map, fromArray} = require './data/list'
{sequence, andThen} = require './core/task'
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

andThenHelp = curry (task1, task2) ->
  wrap = (_v) ->
    task2
  andThen(task1, wrap)

spawnPopState = (router) ->
  toTask = (_e) ->
    platform.sendToSelf router, getLocation()
  scheduler.spawn onWindow('popstate', Either.Right, toTask)

notify = curry (router, subs, location) ->
  callback = (val) ->
    platform.sendToApp router, val.value0(location)
  if Array.isArray(subs)
    subs = fromArray(subs)
  andThenHelp sequence(map(callback, subs)), scheduler.succeed(Tuple0)

onSelfMsg = curry (router, location, state) ->
  andThenHelp notify(router, state.subs, location), scheduler.succeed(state)

cmdHelp = curry (router, subs, cmd) ->
  switch cmd.ctor
    when 'Jump' then go cmd.value0
    when 'New' then andThen pushState(cmd.value0), notify(router, subs)
    else andThen replaceState(cmd.value0), notify(router, subs)

updateHelp = curry (func, val) ->
  ctor: '_Tuple2'
  value0: val.value0
  value1: platform.map func, val.value1

subscription = platform.leaf("Navigation")
command = platform.leaf("Navigation")

Location = curry (a, b, c, d, e, f, g, h, i, j, k) ->
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

State = curry (a, b) ->
  subs: a
  process: b

init = scheduler.succeed State(fromArray([]), Maybe.Nothing())

onEffects = curry (router, cmds, subs, val) ->
  proc = val.process
  stepState = do ->
    step = ctor: '_Tuple2', value0: subs, value1: proc
    if step.value0.ctor == '[]'
      if Maybe.isJust(step.value1)
        nextState = State subs, Maybe.Nothing()
        return andThenHelp scheduler.kill(step.value1.value0), scheduler.succeed(nextState)
      else
        return scheduler.succeed State(subs, proc)
    else
      if Maybe.isNothing(step.value1)
        wrap = (pid) ->
          scheduler.succeed State subs, Maybe.Just(pid)
        return andThen spawnPopState(router), wrap
      else
        return scheduler.succeed State(subs, proc)
  job = map cmdHelp(router, subs), cmds
  andThenHelp sequence(job), stepState

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

cmdMap = curry (_, myCmd) ->
  switch myCmd.ctor
    when 'Jump' then Jump myCmd.value0
    when 'New' then NewUrl myCmd.value0
    else Modify myCmd.value0

Monitor = (a) ->
  ctor: 'Monitor'
  value0: a

programWithFlags = curry (parser, stuff) ->
  data = parser.value0
  location = getLocation()
  init = (flags) ->
    updateHelp UserMsg, stuff.init(flags, data(location))
  view = (model) ->
    app.map UserMsg, stuff.view(model)
  subs = (model) ->
    platform.batch fromArray([
      subscription(Monitor(Change)),
      platform.map UserMsg, stuff.subscriptions(model)
    ])
  intent = curry (msg, model) ->
    updateHelp UserMsg, do ->
      m = msg
      if m.ctor == 'Change'
        stuff.urlUpdate data(m.value0), model
      else
        stuff.update m.value0, model
  app.programWithFlags
    init: init
    view: view
    update: intent
    subscriptions: subs

program = curry (parser, stuff) ->
  programWithFlags parser, do (stuff) ->
    newField =
      init: curry (flags, either) -> stuff.init(either)
    newRecord = {}
    for own key of stuff
      value = if key of newField then newField[key] else stuff[key]
      newRecord[key] = value
    newRecord

subMap = curry (func, val) ->
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
