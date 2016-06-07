diff = require 'virtual-dom/diff'
patch = require 'virtual-dom/patch'
createElement = require 'virtual-dom/create-element'

raf = if typeof requestAnimationFrame != 'undefined' then requestAnimationFrame else (cb) -> setTimeout(cb, 1000 / 60)

renderer = (root, tree) ->
  domNode = createElement tree
  root.appendChild domNode

  state = 'NO_REQUEST'
  currentVdom = tree
  nextVdom = tree

  register = (vnode) ->
    raf(updateIfNeeded) if state == 'NO_REQUEST'
    state = 'PENDING_REQUEST'
    nextVdom = vdom

  updateIfNeeded = ->
    if state == 'NO_REQUEST'
      throw new Error 'Unexpected draw callback'
    else if state == 'PENDING_REQUEST'
      raf(updateIfNeeded)
      state = 'EXTRA_REQUEST'
      patches = diff(currentVdom, nextVdom)
      domNode = patch(domNode, patches)
      currentVdom = nextVdom
    else if state == 'EXTRA_REQUEST'
      state = 'NO_REQUEST'

  update: register

program = (details) ->
  init: details.init
  view: details.view
  subscriptions: details.subscriptions
  view: details.view
  renderer: renderer

module.export =
  program: program
  renderer: renderer
