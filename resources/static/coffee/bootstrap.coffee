# just a helper to get rid jQuery dependency caused by bootstrap plugin
transitionEndEventName = ->
  el = document.createElement('div')
  transitions =
    'transition':'transitionend',
    'OTransition':'otransitionend',
    'MozTransition':'transitionend',
    'WebkitTransition':'webkitTransitionEnd'
  for own key of transitions when el.style[key] != undefined
    return transitions[key]
  false

transitionend = transitionEndEventName()

getTargets = (event) ->
  targets = {}
  event = event or window.event
  targets.evTarget = event.currentTarget or event.srcElement
  dataTarget = targets.evTarget.getAttribute('data-target')
  targets.dataTarget = if dataTarget then document.querySelector(dataTarget) else false
  targets

getMaxHeight = (elements) ->
  prevHeight = element.style.height
  element.style.height = 'auto'
  maxHeight = getComputedStyle(element).height
  element.style.height = prevHeight
  element.offsetHeight
  maxHeight

addEventListener = (node, evType, fn) ->
  if node.addEventListener
    node.addEventListener(evType, fn, false)
    true
  else if node.attachEvent
    node.attachEvent("on" + evType, fn)
  else
    false

dispatchEvent = (element, eventType) ->
  if document.createEvent
    event = document.createEvent('HTMLEvents')
    event.initEvent(eventType, true, false)
    element.dispatchEvent(event)
  else
    element.fireEvent("on#{eventType}")

# Collapse action
collapseShow = (element, trigger) ->
  element.classList.remove('collapse')
  element.classList.add('collapsing')
  trigger.classList.remove('collapsed')
  trigger.setAttribute('aria-expanded', true)

  element.style.height = getMaxHeight(element)

  if transitionend
    addEventListener element, transitionend, ->
      collapseComplete(element)
  else
    collapseComplete(element)

collapseHide = (element, trigger) ->
  element.classList.remove('collapse')
  element.classList.remove('in')
  element.classList.add('collapsing')
  trigger.classList.add('collapsed')
  trigger.setAttribute('aria-expanded', false)

  element.style.height = getComputedStyle(element).height
  element.offsetHeight
  element.style.height = '0px'

collapseComplete = (element) ->
  element.classList.remove('collapsing')
  element.classList.add('collapse')
  element.setAttribute('aria-expanded', false)

  if element.style.height != '0px'
    element.classList.add('in')
    element.style.height = 'auto'

doCollapse = (event) ->
  event.preventDefault()
  targets = getTargets(event)
  dataTarget = targets.dataTarget

  if dataTarget.classList.contains('in')
    collapseHide(dataTarget, targets.evTarget)
  else
    collapseShow(dataTarget, targets.evTarget)
  return false

collapsibleList = document.querySelectorAll('[data-toggle=collapse]')
addEventListener(elem, 'click', doCollapse) for elem in collapsibleList

doDismiss = (event) ->
  event.preventDefault()
  targets = getTargets(event)
  target = targets.dataTarget

  unless target
    parent = targets.evTarget.parentNode
    if parent.classList.contains('alert')
      target = parent
    else if parent.parentNode.classList.contains('alert')
      target = parent.parentNode

  dispatchEvent(target, 'close.bs.alert')
  target.classList.remove('in')

  removeElement = ->
    try
      target.parentNode.removeChild(target)
      dispatchEvent(target, 'closed.bs.alert')
    catch e
      window.console.error('Unable to remove alert')

  if transitionend and target.classList.contains('fade')
    addEventListener target, transitionend, removeElement
  else
    removeElement()
  false

dismissList = document.querySelectorAll('[data-dismiss=alert]')
addEventListener(elem, 'click', doDismiss) for elem in dismissList

doDropdown = (event) ->
  event = event or window.event
  evTarget = event.currentTarget or event.srcElement
  evTarget.parentElement.classList.toggle('open')
  false

closeDropdown = (event) ->
  event = event or window.event
  evTarget = event.currentTarget or event.srcElement
  evTarget.parentElement.classList.remove('open')

  if event.relatedTarget and event.relatedTarget.getAttribute('data-toggle') != 'dropdown'
    event.relatedTarget.click()
  false

dropdownList = document.querySelectorAll('[data-toggle=dropdown]')
for elem in dropdownList
  elem.setAttribute('tabindex', '0')
  addEventListener(elem, 'click', doDropdown)
  addEventListener(elem, 'blur', closeDropdown)
