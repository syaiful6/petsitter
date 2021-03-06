{Nil, Cons} = require '../data/list'
{Tuple0, Tuple2} = require '../utils/common'
{programWithFlags} = require '../dom/vdom'
{curry} = require './lambda'
Either = require '../data/either'

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

bootstrap = (name, main) ->
  app = {}
  app[name] = {}
  addPublicModule(app[name], name, {main: main})
  app

addPublicModule = (object, name, main) ->
  init = if main then makeEmbed(name, main) else mainIsUndefined(name)

  object['worker'] = (flags) ->
    init(undefined, flags, false)

  object['embed'] = (domNode, flags) ->
    init(domNode, flags, true)

  object['fullscreen'] = (flags) ->
    init(document.body, flags, true)
  return

mainIsUndefined = (name) -> (domNode) ->
  message = "Cant initialize module #{name} because it has no `main` value!\nWhat should I show on screen?"
  domNode.innerHTML = 'Something went wrong when starting your program';
  throw new Error(message);

makeEmbed = (moduleName, main) -> (rootDomNode, flags, withRenderer) ->
  try
    program = mainToProgram(moduleName, main)
    unless withRenderer
      program.renderer = dummyRenderer
    makeEmbedHelp(moduleName, program, rootDomNode, flags)
  catch e
    rootDomNode.innerHTML = e.message
    throw e

dummyRenderer = ->
  update: ->

mainToProgram = (moduleName, wrappedMain) ->
  main = wrappedMain.main
  if typeof main.init == 'undefined'
    emptyBag = batch(Nil)
    noChange = Tuple2 Tuple0, emptyBag
    return programWithFlags(
        init: -> noChange
        view: -> main
        update: curry.to(2, -> noChange)
        subscriptions: -> emptyBag
      )
  flags = wrappedMain.flags
  init = if flags then initWithFlags(moduleName, main.init, flags) else initWithoutFlags(moduleName, main.init)
  programWithFlags(
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
  realInit(result.value0)

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
    model = results.value0
    renderer = makeRenderer(rootDomNode, enqueue, view(model))
    cmds = results.value1
    subs = subscriptions(model)
    dispatchEffects(managers, cmds, subs)
    callback(succeed(model))

  onMessage = (msg, model) ->
    nativeBinding (callback) ->
      results = update(msg)(model)
      model = results.value0
      renderer.update(view(model))
      cmds = results.value1
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
  for key of effectManagers
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
    return onSelfMsg(router, msg.value0, state) if msg.ctor == 'self'

    fx = msg.value0
    if tag == 'cmd'
      onEffects(router, fx.cmds, state)
    else if tag == 'sub'
      onEffects(router, fx.subs, state)
    else if tag == 'fx'
      onEffects(router, fx.cmds, fx.subs, state)

  process = spawnLoop(info.init, onMessage)
  router.self = process
  process

sendToApp = (router, msg) ->
  nativeBinding (callback) ->
    router.main(msg)
    callback(succeed(Tuple0))

sendToSelf = (router, msg) ->
  schedulerSend(router.self, {
    ctor: 'self',
    value0: msg
  })

spawnLoop = (init, onMessage) ->
  mainLoop = (state) ->
    handleMsg = receive (msg) ->
      onMessage(msg, state)
    andThen(handleMsg, mainLoop)
  # set the task
  taskP = andThen(init, mainLoop)
  rawSpawn(taskP)

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
    rawSend managers[home], { ctor: 'fx', value0: fx }
  return

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
      gatherEffects(isCmd, list.value0, effectsDict, taggers)
      list = list.value1
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
  eff = if isCmd then effectManagers[home].cmdMap else effectManagers[home].subMap
  eff(applyTaggers, value)

insert = (isCmd, newEffect, effects) ->
  effects = effects or {
    cmds: Nil,
    subs: Nil
  }
  if isCmd
    effects.cmds = Cons(newEffect, effects.cmds)
  else
    effects.subs = Cons(newEffect, effects.subs)
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

outgoingPortMap = curry (tagger, value) ->
  value

setupOutgoingPort = (name) ->
  subs = []
  converter = effectManagers[name].converter

  init = succeed(null)
  onEffects = (outer, cmdList, state) ->
    while cmdList.ctor != '[]'
      value = converter(cmdList.value0)
      sub(value) for sub in subs
      cmdList = cmdList.value1
    init

  effectManagers[name].init = init
  effectManagers[name].onEffects = curry(onEffects)

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

incomingPortMap = curry (tagger, finalTagger) -> (value) ->
  tagger(finalTagger(value))

setupIncomingPort = (name, callback) ->
  subs = Nil
  converter = effectManagers[name].converter

  init = succeed(null)
  onEffects = (router, subList, state) ->
    subs = subList
    init

  effectManagers[name].init = init
  effectManagers[name].onEffects = curry(onEffects)

  send = (value) ->
    result = converter(value)
    if Either.isLeft result
      throw new Error('Unexpected value')
    value = result.value0
    temp = subs
    while temp.ctor != '[]'
      callback(temp.value0(value))
      temp = temp.value1
    return
  {send: send}

module.exports =
  sendToApp: curry(sendToApp)
  sendToSelf: curry(sendToSelf)
  mainToProgram: mainToProgram
  effectManagers: effectManagers
  outgoingPort: outgoingPort
  incomingPort: incomingPort
  addPublicModule: addPublicModule
  leaf: leaf
  batch: batch
  map: curry(map)
  bootstrap: curry(bootstrap)
