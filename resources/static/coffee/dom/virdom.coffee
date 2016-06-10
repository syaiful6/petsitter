functools = require '../utils/functools'

STYLE_KEY = 'STYLE'
EVENT_KEY = 'EVENT'
ATTR_KEY = 'ATTR'
ATTR_NS_KEY = 'ATTR_NS'

text = (string) ->
  type: 'text'
  text: string

node = (tag) ->
  functools.curry2 (factList, kidList) ->
    nodeHelp(tag, factList, kidList)

nodeHelp = (tag, factList, kidList) ->
  organized = organizeFacts(factList)
  namespace = organized.namespace
  facts = organized.facts

  children = []
  descendantsCount = 0
  for kid in kidList
    descendantsCount += (kid.descendantsCount || 0)
    children.push kid
  descendantsCount += children.length

  type: 'node'
  tag: tag
  facts: facts
  children: children
  namespace: namespace
  descendantsCount: descendantsCount

custom = (factList, model, impl) ->
  facts = organizeFacts(factList).facts

  type: 'custom'
  facts: facts
  model: model
  impl: impl

map = (tagger, node) ->
  type: 'tagger'
  tagger: tagger
  descendantsCount: 1 + (node.descendantsCount || 0)

thunk = (func, args, thunk) ->
  type: 'thunk'
  func: func
  args: args
  thunk: thunk
  node: null

lazy = (fun, a) ->
  thunk(fun, [a], ->
    fun(a)
  )

lazy2 = (fun, a, b) ->
  thunk(fun, [a,b], ->
    functools.invoke2 fun, a, b
  )

lazy3 = (fun, a, b, c) ->
  thunk(fun, [a, b, c], ->
    functools.invoke3 fun, a, b, c
  )

organizeFacts = (factList) ->
  namespace = null
  facts = {}
  for entry in factList
    key = entry.key
    if key in [ATTR_KEY, ATTR_NS_KEY, EVENT_KEY]
      subFacts = facts[key] or {}
      subFacts[entry.realKey] = entry.value
      facts[key] = subFacts
    else if key == STYLE_KEY
      styles = facts[key] or {}
      styleList = entry.value
      for style in styleList
        styles[style[0]] = style[1]
      facts[key] = styles
    else if key == 'namespace'
      namespace = entry.value
    else
      facts[key] = entry.value

  facts: facts
  namespace: namespace

style = (value) ->
  key: STYLE_KEY
  value: value

property = (key, value) ->
  key: key
  value: value

attribute = (key, value) ->
  key: ATTR_KEY
  realKey: key
  value: value

attributeNS = (namespace, key, value) ->
  key: ATTR_NS_KEY
  realKey: key
  value:
    namespace: namespace
    value: value

event = (name, options, decoder) ->
  key: EVENT_KEY
  realKey: name
  value:
    options: options
    decoder: decoder

equalEvents = (a, b) ->
  if a.options != b.options
    if a.stopPropagation != b.stopPropagation or a.preventDefault != b.preventDefault
      return false
  a.decoder == b.decoder

rAF = do ->
  return requestAnimationFrame if typeof requestAnimationFrame != 'undefined'
  (cb) -> setTimeout(cb, 1000 / 60)

renderer = (parent, tagger, initialVirtualNode) ->
  eventNode =
    tagger: tagger
    parent: null
  domNode = render(initialVirtualNode, eventNode)
  parent.appendChild(domNode)

  state = 'NO_REQUEST'
  currentVirtualNode = initialVirtualNode
  nextVirtualNode = initialVirtualNode

  register = (vNode) ->
    rAF(updateIfNeeded) if state == 'NO_REQUEST'
    state = 'PENDING_REQUEST'
    nextVirtualNode = vNode

  updateIfNeeded = ->
    if state == 'NO_REQUEST'
      throw new Error 'Unexpected draw callback'
    else if state == 'PENDING_REQUEST'
      rAF(updateIfNeeded)
      state = 'EXTRA_REQUEST'
      patches = diff(currentVirtualNode, nextVirtualNode)
      domNode = applyPatches(domNode, currentVirtualNode, patches, eventNode)
      currentVirtualNode = nextVirtualNode
    else if state == 'EXTRA_REQUEST'
      state = 'NO_REQUEST'

  update: register

render = (vNode, eventNode) ->
  switch vNode.type
    when 'thunk'
      unless vNode.node
        vNode.node = vNode.thunk()
      render(vNode.node, eventNode)
    when 'tagger'
      subNode = vNode.node
      tagger = vNode.tagger
      while subNode.type == 'tagger'
        if typeof tagger != 'object'
          tagger = [tagger, subNode.tagger]
        else
          tagger.push subNode.tagger
        subNode = subNode.node
      subEventRoot =
        tagger: tagger
        parent: eventNode
      domNode = render(subNode, subEventRoot)
      domNode.__evroot__ = subEventRoot
      domNode
    when 'text' then document.createTextNode(vNode.text)
    when 'node'
      if vNode.namespace
        domNode = document.createElementNS(vNode.namespace, vNode.tag)
      else
        domNode = document.createElement(vNode.tag)
      applyFacts(domNode, eventNode, vNode.facts)
      children = vNode.children
      domNode.appendChild(render(child, eventNode)) for child in children
      domNode
    when 'custom'
      domNode = vNode.impl.render(vNode.model)
      applyFacts(domNode, eventNode, vNode.facts)
      domNode

applyFacts = (domNode, eventNode, facts) ->
  for key, value of facts
    switch key
      when STYLE_KEY then applyStyles domNode, value
      when EVENT_KEY then applyEvents domNode, eventNode, value
      when ATTR_KEY then applyAttrs domNode, value
      when ATTR_NS_KEY then applyAttrsNS domNode, value
      when 'value'
        if domNode[key] != value
          domNode[key] = value
      else
        domNode[key] = value
  return

applyStyles = (domNode, styles) ->
  domNodeStyle = domNode.style
  domNodeStyle[key] = styles[key] for key of styles

applyEvents = (domNode, eventNode, events) ->
  allHandlers = domNode.__evhandlers__
  for key, value of events
    handler = allHandlers[key]
    if typeof value == 'undefined'
      domNode.removeEventListener(key, handler)
      allHandlers[key] = undefined
    else if typeof handler == 'undefined'
      handler = makeEventHandler(eventNode, value)
      domNode.addEventListener(key, handler)
      allHandlers[key] = handler
    else
      handler.info = value
  domNode.__evhandlers__ = allHandlers

makeEventHandler = (eventNode, info) ->
  eventHandler = (event) ->
    info = eventHandler.info
    value = invoke2 info.decoder, event
    if value.ctor == 'Ok'
      options = info.options
      event.stopPropagation() if options.stopPropagation
      event.preventDefault() if options.preventDefault
      message = value._0
      currentEventNode = eventNode
      while currentEventNode
        tagger = currentEventNode.tagger
        if typeof tagger == 'function'
          message = tagger(message)
        else
          rev = tagger.slice().reverse()
          message = t(message) for t in rev
        currentEventNode = currentEventNode.parent
  eventHandler.info = info
  eventHandler

applyAttrs = (domNode, attrs) ->
  for key, value of attrs
    if typeof value == 'undefined'
      domNode.removeAttribute(key)
    else
      domNode.setAttribute(key, value)

applyAttrsNS = (domNode, nsAttrs) ->
  for key of nsAttrs
    pair = nsAttrs[key]
    namespace = pair.namespace
    value = pair.value
    if typeof value === 'undefined'
      domNode.removeAttributeNS(namespace, key)
    else
      domNode.setAttributeNS(namespace, key, value)

diff = (a, b) ->
  patches = []
  diffHelp(a, b, patches, 0)
  patches

makePatch = (type, index, data) ->
  index: index
  type: type
  data: data
  domNode: null
  eventNode: null

diffHelp = (a, b, patches, index) ->
  return if a == b

  aType = a.type
  bType = b.type

  if aType != bType
    patches.push(makePatch('p-redraw', index, b))
    return

  switch bType
    when 'thunk'
      aArgs = a.args
      bArgs = b.args
      i = aArgs.length
      same = a.func == b.func and i == bArgs.length
      while same and i--
        same = aArgs[i] == bArgs[i]
      if same
        b.node = a.node
        return
      b.node = b.thunk()
      subPatches = []
      diffHelp(a.node, b.node, subPatches, 0)
      patches.push(makePatch('p-thunk', index, subPatches)) if subPatches.length > 0
      return
    when 'tagger'
      aTaggers = a.tagger
      bTaggers = b.tagger
      nesting = false

      aSubNode = a.node
      while aSubNode.type == 'tagger'
        nesting = true
        if typeof b.tagger != 'object'
          bTaggers = [bTaggers, bSubNode.tagger]
        else
          bTaggers.push(bSubNode.tagger)
        bSubNode = bSubNode.node

      if nesting and aTaggers.length != bTaggers.length
        patches.push(makePatch('p-redraw', index, b))
        return

      ret = if nesting then not pairwiseRefEqual(aTaggers, bTaggers) else aTaggers != bTaggers
      if ret
        patches.push(makePatch('p-tagger', index, bTaggers))
      diffHelp(aSubNode, bSubNode, patches, index + 1)
      return
    when 'text'
      if a.text != b.text
        patches.push(makePatch('p-text', index, b.text))
      return
    when 'node'
      if a.tag != b.tag or a.namespace != b.namespace
        patches.push(makePatch('p-redraw', index, b))
        return
      factsDiff = diffFacts(a.facts, b.facts)
      if typeof factsDiff != 'undefined'
        patches.push(makePatch('p-facts', index, factsDiff))
      diffChildren(a, b, patches, index)
      return
