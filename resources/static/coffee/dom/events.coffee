vdom = require './vdom'
{ok} = require '../core/result'
functools = require '../utils/functools'

defaultOptions =
  stopPropagation: off
  preventDefault: off

event = (eventName, decoder) ->
  vdom.event(eventName)(defaultOptions)(decoder)

onClick = (msg) ->
  decoder = (e) ->
    ok(msg())
  event 'click', decoder

onDoubleClick = (msg) ->
  decoder = (e) ->
    ok(msg())
  event 'dbclick', decoder

onInput = (msg) ->
  decoder = (ev) ->
    ok(msg(ev.target.value))
  event 'input', decoder

onChange = (msg) ->
  decoder = (ev) ->
    ok(msg(ev.target.value))
  event 'change', decoder

module.exports =
  onClick: onClick
  onChange: onChange
  onInput: onInput
  event: functools.curry2 event
