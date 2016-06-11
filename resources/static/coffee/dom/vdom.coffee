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
  node: node
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
  allHandlers = domNode.__evhandlers__ or {}
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
    value = info.decoder(event)
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
          # rev = tagger.slice().reverse()
          i = tagger.length
          while i--
            message = tagger[i](message)
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
    if typeof value == 'undefined'
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
        if typeof aTaggers != 'object'
          aTaggers = [aTaggers, aSubNode.tagger]
        else
          aTaggers.push(aSubNode.tagger)
        aSubNode = aSubNode.node

      bSubNode = b.node
      while bSubNode.type == 'tagger'
        nesting = true
        if typeof bTaggers != 'object'
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
    when 'custom'
      if a.impl != b.impl
        patches.push(makePatch('p-redraw', index, b))
        return
      factsDiff = diffFacts(a.facts, b.facts)
      if typeof factsDiff != 'undefined'
        patches.push(makePatch('p-facts', index, factsDiff))
      patch = b.impl.diff(a,b)
      if patch
        patches.push(makePatch('p-custom', index, patch))
      return

pairwiseRefEqual = (as, bs) ->
  for i in [0...as.length]
    return false if as[i] != bs[i]
  true

diffFacts = (a, b, category) ->
  res = null
  for aKey of a
    if a in [ATTR_KEY, ATTR_NS_KEY, EVENT_KEY, STYLE_KEY]
      subDiff = diffFacts(a[aKey], b[aKey] or {}, aKey)
      if subDiff
        res = res or {}
        res[aKey] = subDiff
      continue
    unless aKey of b
      res = res or {}
      res[aKey] = if typeof category == 'undefined' then (if typeof a[aKey] == 'string' then '' else null) else if category == STYLE_KEY then '' else if category == EVENT_KEY or category == ATTR_KEY then undefined else
        namespace: a[aKey].namespace
        value: undefined
      continue
    aValue = a[aKey]
    bValue = b[aKey]
    if aValue == bValue and aKey != 'value' or category == EVENT_KEY and equalEvents(aValue, bValue)
      continue
    res = res or {}
    res[aKey] = bValue

  for bKey of b when not bKey of a
    res = diff or {}
    res[bKey] = b[bKey]

  res

diffChildren = (aParent, bParent, patches, rootIndex) ->
  aChildren = aParent.children
  bChildren = bParent.children
  aLen = aChildren.length
  bLen = bChildren.length

  if aLen > bLen
    patches.push makePatch('p-remove', rootIndex, aLen - bLen)
  else if aLen < bLen
    patches.push makePatch('p-insert', rootIndex, bChildren.slice(aLen))

  index = rootIndex
  minLen = if aLen < bLen then aLen else bLen
  i = 0
  while i < minLen
    index++
    aChild = aChildren[i]
    diffHelp aChild, bChildren[i], patches, index
    index += aChild.descendantsCount or 0
    i++
  return

addDomNodes = (domNode, vNode, patches, eventNode) ->
  addDomNodesHelp domNode, vNode, patches, 0, 0, vNode.descendantsCount, eventNode
  return

addDomNodesHelp = (domNode, vNode, patches, i, low, high, eventNode) ->
  patch = patches[i]
  index = patch.index
  while index == low
    patchType = patch.type
    if patchType == 'p-thunk'
      addDomNodes domNode, vNode.node, patch.data, eventNode
    else
      patch.domNode = domNode
      patch.eventNode = eventNode
    i++
    if !(patch = patches[i]) or (index = patch.index) > high
      return i
  switch vNode.type
    when 'tagger'
      subNode = vNode.node
      while subNode.type == 'tagger'
        subNode = subNode.node
      return addDomNodesHelp(domNode, subNode, patches, i, low + 1, high, domNode.__evroot__)
    when 'node'
      vChildren = vNode.children
      childNodes = domNode.childNodes
      j = 0
      while j < vChildren.length
        low++
        vChild = vChildren[j]
        nextLow = low + (vChild.descendantsCount or 0)
        if low <= index and index <= nextLow
          i = addDomNodesHelp(childNodes[j], vChild, patches, i, low, nextLow, eventNode)
          if !(patch = patches[i]) or (index = patch.index) > high
            return i
        low = nextLow
        j++
      return i
    when 'text', 'thunk'
      throw new Error('should never traverse `text` or `thunk` nodes like this')
  return

applyPatches = (rootDomNode, oldVirtualNode, patches, eventNode) ->
  if patches.length == 0
    return rootDomNode
  addDomNodes rootDomNode, oldVirtualNode, patches, eventNode
  applyPatchesHelp rootDomNode, patches

applyPatchesHelp = (rootDomNode, patches) ->
  i = 0
  while i < patches.length
    patch = patches[i]
    localDomNode = patch.domNode
    newNode = applyPatch(localDomNode, patch)
    if localDomNode == rootDomNode
      rootDomNode = newNode
    i++
  rootDomNode

applyPatch = (domNode, patch) ->
  switch patch.type
    when 'p-redraw'
      return redraw(domNode, patch.data, patch.eventNode)
    when 'p-facts'
      applyFacts domNode, patch.eventNode, patch.data
      return domNode
    when 'p-text'
      domNode.replaceData 0, domNode.length, patch.data
      return domNode
    when 'p-thunk'
      return applyPatchesHelp(domNode, patch.data)
    when 'p-tagger'
      domNode.__evroot__.tagger = patch.data
      return domNode
    when 'p-remove'
      i = patch.data
      while i--
        domNode.removeChild domNode.lastChild
      return domNode
    when 'p-insert'
      newNodes = patch.data
      j = 0
      while j < newNodes.length
        domNode.appendChild render(newNodes[j], patch.eventNode)
        j++
      return domNode
    when 'p-custom'
      impl = patch.data
      return impl.applyPatch(domNode, impl.data)
    else
      throw new Error('Ran into an unknown patch!')
  return

redraw = (domNode, vNode, eventNode) ->
  parentNode = domNode.parentNode
  newNode = render(vNode, eventNode)
  if typeof newNode.__evroot__ == 'undefined'
    newNode.__evroot__ = domNode.__evroot__
  if parentNode and newNode != domNode
    parentNode.replaceChild newNode, domNode
  newNode

programWithFlags = (details) ->
  {
    init: details.init
    update: details.update
    subscriptions: details.subscriptions
    view: details.view
    renderer: renderer
  }

module.exports =
  node: node
  text: text
  custom: custom
  map: functools.curry2 map
  programWithFlags: programWithFlags
  event: functools.curry3 event
  style: style
  property: functools.curry2 property
  attribute: functools.curry2 attribute
  attributeNS: functools.curry2 attributeNS
  lazy: functools.curry2 lazy
  lazy2: functools.curry3 lazy2
  lazy3: functools.curry4 lazy3
