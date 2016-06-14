vdom = require './vdom'
either = require '../core/data/either'
functools = require '../utils/functools'

defaultOptions =
  stopPropagation: off
  preventDefault: off

event = (eventName, decoder) ->
  vdom.event(eventName)(defaultOptions)(decoder)

onClick = (msg) ->
  decoder = (e) ->
    either.Right(msg())
  event 'click', decoder

onDoubleClick = (msg) ->
  decoder = (e) ->
    either.Right(msg())
  event 'dbclick', decoder

onInput = (msg) ->
  decoder = (ev) ->
    either.Right(msg(ev.target.value))
  event 'input', decoder

onChange = (msg) ->
  decoder = (ev) ->
    either.Right(msg(ev.target.value))
  event 'change', decoder

module.exports =
  onClick: onClick
  onChange: onChange
  onInput: onInput
  event: functools.curry2 event
