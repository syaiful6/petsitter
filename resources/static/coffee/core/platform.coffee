{Nil, Cons} = require './list'
{Tuple0, Tuple2} = require '../utils/common'
{program} = require '../dom/program'
{curry2, curry3, invoke2, invoke3, invoke4} = require '../utils/functools'

# hmm
{ send,
  rawSend,
  nativeBinding,
  succeed,
  andThen,
  receive,
  rawSpawn
} = require './scheduler'

schedulerSend = send

startApp = (main) ->
  app = {}
  app['main'] = main
  addPublicModule(app['main'], 'main', app)
  app

addPublicModule = (object, name, main) ->
  init = if main then makeEmbed(name, main) else mainIsUndefined(name)

  object['worker'] = (flags) ->
    init(undefined, flags, false)

  object['embed'] = (domNode, flags) ->
    init(domNode, flags, true)

  object['fullscreen'] = (flags) ->
    init(document.body, flags, true)

mainIsUndefined = (name) -> (domNode) ->
  message = "Cant initialize module #{name} because it has no `main` value!\nWhat should I show on screen?"
  domNode.innerHTML = 'Something went wrong when starting your program';
  throw new Error(message);

makeEmbed = (moduleName, main) -> (rootDomNode, flags, withRenderer) ->
  try
    program = mainToProgram(moduleName, main)
    if not withRenderer
      program.renderer = dummyRenderer
    makeEmbedHelp(moduleName, program, rootDomNode, flags)
  catch e
    rootDomNode.innerHTML = e.message
    throw e

dummyRenderer = ->
  update: ->

mainToProgram = (moduleName, wrappedMain) ->
  main = wrappedMain.main
  if typeof main == 'undefined'
    emptyBag = batch(Nil)
    noChange = Tuple2 Tuple0, emptyBag
    return program(
        init: -> noChange
        view: -> main
        update: curry2(-> noChange)
        subscriptions: -> emptyBag
      )
  flags = wrappedMain.flags
  init = if flags then initWithFlags(moduleName, main.init, flags) else initWithoutFlags(moduleName, main.init)
  program(
      init: init
      view: main.view
      update: main.update
      subscriptions: main.subscriptions
    )

initWithoutFlags = (moduleName, realInit) -> (flags) ->
  throw new Error('This module does not take arguments though!') if typeof flags != 'undefined'
  realInit()

initWithFlags = (moduleName, realInit, flagDecoder) -> (flags) ->
  results = flagDecoder(flags)
  realInit(result._0)

makeEmbedHelp = (moduleName, program, rootDomNode, flags) ->
  init = program.init
  update = program.update
  subscriptions = program.subscriptions
  view = program.view
  makeRenderer = program.renderer
  managers = {}
  renderer = null

  initApp = nativeBinding (callback) ->
    results = init(flags)
    model = results._0
    renderer = makeRenderer(rootDomNode, enqueue, view(model))
    cmds = results._1
    subs = subscriptions(model)
    dispatchEffects(managers, cmds, subs)
    callback(succeed(model))

  onMessage = (msg, model) ->
    nativeBinding (callback) ->
      results = invoke2(update, msg, model)
      model = results._0
      renderer.update(view(model))
      cmds = results._1
      subs = subscriptions(model)
      dispatchEffects(managers, cmds, subs)
      callback(succeed(model))

  mainProcess = spawnLoop(initApp, onMessage)

  enqueue = (msg) ->
    rawSend(mainProcess, msg)

  ports = setupEffects(managers, enqueue)

  if ports then {ports: ports} else {}

effectManagers = {}

setupEffects = (managers, callback) ->
  ports = null
  for key of managers
    manager = effectManagers[key]
    if managers.isForeign
      ports = ports or {}
      if manager.tag == 'cmd'
        ports[key] = setupOutgoingPort(key)
      else
        ports[key] = setupIncomingPort(key, callback)
    managers[key] = makeManager(manager, callback)
  ports

makeManager = (info, callback) ->
  router =
    main: callback
    self: undefined

  tag = info.tag
  onEffects = info.onEffects
  onSelfMsg = info.onSelfMsg

  onMessage = (msg, state) ->
    invoke3(onSelfMsg, router, msg._0, state) if msg.ctor == 'self'

    fx = msg._0
    if tag == 'cmd'
      invoke3(onEffects, router, fx.cmds, state)
    else if tag == 'sub'
      invoke3(onEffects, router, fx.subs, state)
    else if tag == 'fx'
      invoke4(onEffects, router, fx.cmds, fx.subs, state)

  process = spawnLoop(info.init, onMessage)
  router.self = process
  process

sendToApp = (router, msg) ->
  nativeBinding (callback) ->
    router.main(msg)
    callback(succeed(Tuple0))

sendToSelf = (router, msg) ->
  invoke2 schedulerSend, router.self, {
    ctor: 'self',
    _0: msg
  }

spawnLoop = (init, onMessage) ->
  mainLoop = (state) ->
    handleMsg = receive (msg) ->
      onMessage(msg, state)
    invoke2(andThen, handleMsg, mainLoop)
  # set the task
  task = invoke2(andThen, init, mainLoop)
  rawSpawn(task)

# bags
leaf = (home) -> (value) ->
  type: 'leaf'
  home: home
  value: value

batch = (list) ->
  type: 'node'
  branches: list

map = (tagger, bag) ->
  type: 'map'
  tagger: tagger
  tree: bag

dispatchEffects = (managers, cmdBag, subBag) ->
  effectsDict = {}
  gatherEffects(true, cmdBag, effectsDict, null)
  gatherEffects(false, subBag, effectsDict, null)

  for home of managers
    if home of effectsDict
      fx = effectsDict[home]
    else
      fx =
        cmds: Nil
        subs: Nil
    rawSend managers[home], { ctor: 'fx', _0: fx }

gatherEffects = (isCmd, bag, effectsDict, taggers) ->
  type = bag.type
  if type == 'leaf'
    home = bag.home
    effect = toEffect(isCmd, home, taggers, bag.value)
    effectsDict[home] = insert(isCmd, effect, effectsDict[home])
    return
  if type == 'node'
    list = bag.branches
    while list.ctor != '[]'
      gatherEffects(isCmd, list._0, effectsDict, taggers)
      list = list._1
    return
  if type == 'map'
    gatherEffects(isCmd, bag.tree, effectsDict, {
      tagger: bag.tagger,
      rest: taggers
    })
    return

toEffect = (isCmd, home, taggers, value) ->
  applyTaggers = (x) ->
    temp = taggers
    while temp
      x = temp.tagger(x)
      temp = temp.rest
    x
  map = if isCmd then effectManagers[home].cmdMap else effectManagers[home].subMap
  invoke2(map, applyTaggers, value)

insert = (isCmd, newEffect, effects) ->
  effects = effects or {
    cmds: Nil,
    subs: Nil
  }
  if isCmd
    effects.cmds = Cons(newEffect, effects.cmds)
  else
    effects.subs = Cons(newEffect, effects.cmds)
  effects

checkPortName = (name) ->
  if name of effectManagers
    throw new Error("There can only be one port named #{name}")

outgoingPort = (name, converter) ->
  checkPortName(name)
  effectManagers =
    tag: 'cmd'
    cmdMap: outgoingPortMap
    converter: converter
    isForeign: true
  leaf(effectManagers)

outgoingPortMap = curry2 (tagger, value) ->
  value

setupOutgoingPort = (name) ->
  subs = []
  converter = effectManagers[name].converter

  init = succeed(null)
  onEffects = (outer, cmdList, state) ->
    while cmdList.ctor != '[]'
      value = converter(cmdList._0)
      sub(value) for sub in subs
      cmdList = cmdList._1
    init

  effectManagers[name].init = init
  effectManagers[name].onEffects = curry3(onEffects)

  subscribe = (callback) ->
    subs.push(callback)

  unsubscribe = (callback) ->
    index = subs.indexOf(callback)
    subs.splice(index, 1) if index >= 0

  {subscribe: subscribe, unsubscribe: unsubscribe}

incomingPort = (name, converter) ->
  checkPortName(name)
  effectManagers[name] =
    tag: 'sub'
    subMap: incomingPortMap
    converter: converter
    isForeign: true
  leaf(name)

incomingPortMap = curry2 (tagger, finalTagger) -> (value) ->
  tagger(finalTagger(value))

setupIncomingPort = (name, callback) ->
  subs = Nil
  converter = effectManagers[name].converter

  init = succeed(null)
  onEffects = (router, subList, state) ->
    subs = subList
    init

  effectManagers[name].init = init
  effectManagers[name].onEffects = curry3(onEffects)

  send = (value) ->
    result = converter(value)
    if result.ctor == 'Err'
      throw new Error('Unexpected value')
    value = result._0
    temp = subs
    while temp.ctor != '[]'
      callback(temp._0(value))
      temp = temp._1
  {send: send}

module.exports =
  sendToApp: curry2(sendToApp)
  sendToSelf: curry2(sendToSelf)
  mainToProgram: mainToProgram
  effectManagers: effectManagers
  outgoingPort: outgoingPort
  incomingPort: incomingPort
  addPublicModule: addPublicModule
  leaf: leaf
  batch: batch
  map: curry2(map)
  startApp: startApp
