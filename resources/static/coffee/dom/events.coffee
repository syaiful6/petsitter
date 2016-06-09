{eventHook} = require './vdom'

onClick = (msg) ->
  event("click")(msg)(false)

onDoubleClick = (msg) ->
  event("dblclick")(msg)(false)

onInput = (msg) ->
  handler = (ev) ->
    msg(ev.target.value)
  event("input")(handler)(false)

onChange = (msg) ->
  handler = (ev) ->
    msg(ev.target.value)
  event("change")(handler)(false)

event = (type) -> (listener) -> (options) ->
  ["ev-#{type}", eventHook(listener, options)]

module.exports =
  onClick: onClick
  onChange: onChange
  onInput: onInput
  event: event
