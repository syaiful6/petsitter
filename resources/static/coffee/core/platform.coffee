{Nil} = require './list'
{Tuple0, Tuple2} = require '../utils/common'
{program} = require '../dom/program'
{curry2} = require '../utils/functools'

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

initWithFlags = (moduleName, realInit, flagDecoder) ->

