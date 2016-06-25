Maybe = require './data/maybe'
Either = require './data/either'
{Tuple} = require './data/tuple'
{map, fromArray} = require './data/list'
scheduler = require './core/scheduler'
platform = require './core/platform'
{tagged, taggedSum} = require './core/tagged'
{curry} = require './core/lambda'
{sequence, andThen} = require './core/task'
{Tuple0} = require './utils/common'
{onWindow} = require './dom/window'
{extend} = require './utils/object'
app = require './dom/app'

# effects command
subscription = platform.leaf("Navigation")
command = platform.leaf("Navigation")

# -- program

# type MyMsg msg = Change Location | UserMsg msg
MyMsg = taggedSum {
  Change: ['value0']
  UserMsg: ['value0']
}

programWithFlags = curry (parser, stuff) ->
  data = parser.value0
  location = getLocation()
  init = (flags) ->
    updateHelp MyMsg.UserMsg, stuff.init(flags, data(location))
  view = (model) ->
    app.map MyMsg.UserMsg, stuff.view(model)
  subs = (model) ->
    platform.batch fromArray([
      subscription MySub.Monitor(MyMsg.Change),
      platform.map MyMsg.UserMsg, stuff.subscriptions(model)
    ])
  intent = curry (msg, model) ->
    updateHelp MyMsg.UserMsg, do ->
      if msg instanceof MyMsg.Change
        stuff.urlUpdate data(msg.value0), model
      else
        stuff.update msg.value0, model
  app.programWithFlags
    init: init
    view: view
    update: intent
    subscriptions: subs

program = curry (parser, stuff) ->
  newField =
    init: curry (flags, either) -> stuff.init(either)
  programWithFlags parser, extend(stuff, newField)

updateHelp = curry (func, val) ->
  Tuple val.value0, platform.map(func, val.value1)


#
MyCmd = taggedSum {
  Jump: ['value0']
  NewUrl: ['value0']
  Modify: ['value0']
}

# back :: Int -> Cmd msg
back = (n) ->
  command MyCmd.Jump(0 - 1)

# forward :: Int -> Cmd msg
forward = (n) ->
  command MyCmd.Jump(n)

# -- Change the history

# newUrl :: String -> Cmd msg
newUrl = (url) ->
  command MyCmd.NewUrl(url)

# modifyUrl :: String -> Cmd msg
modifyUrl = (url) ->
  command MyCmd.Modify(url)

cmdMap = curry (_, myCmd) ->
  myCmd.cata {
    Jump: (v) ->
      MyCmd.Jump v
    NewUrl: (v) ->
      MyCmd.NewUrl v
    Modify: (v) ->
      MyCmd.Modify v
  }

Parser = tagged('value0')
makeParser = Parser

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

MySub = taggedSum {
  Monitor: ['value0']
}

subMap = curry (func, val) ->
  MySub.Monitor (el) -> func(val.value0(el))

# utility function to run tasks
andThenHelp = curry (task1, task2) ->
  wrap = (_v) ->
    task2
  andThen(task1, wrap)

State = curry (a, b) ->
  subs: a
  process: b

init = scheduler.succeed State(fromArray([]), Maybe.Nothing())

onSelfMsg = curry (router, location, state) ->
  andThenHelp notify(router, state.subs, location), scheduler.succeed(state)

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

cmdHelp = curry (router, subs, cmd) ->
  if cmd instanceof MyCmd.Jump
    go(cmd.value0)
  else if cmd instanceof MyCmd.NewUrl
    andThen pushState(cmd.value0), notify(router, subs)
  else
    andThen replaceState(cmd.value0), notify(router, subs)

notify = curry (router, subs, location) ->
  callback = (val) ->
    platform.sendToApp router, val.value0(location)
  if Array.isArray(subs)
    subs = fromArray(subs)
  andThenHelp sequence(map(callback, subs)), scheduler.succeed(Tuple0)

spawnPopState = (router) ->
  toTask = (_e) ->
    platform.sendToSelf router, getLocation()
  scheduler.spawn onWindow('popstate', Either.Right, toTask)

# Task binding

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

getLocation = ->
  location = document.location
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
