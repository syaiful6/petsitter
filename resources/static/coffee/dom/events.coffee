onClick = (msg) ->
  ['onclick', (ev) ->
    handler = window.$eventNode
    handler(msg())
  ]

onInput = (msg) ->
  ['oninput', (ev) ->
    handler = window.$eventNode
    handler(msg(ev.target.value))
  ]

onChange = (msg) ->
  ['onchange', (ev) ->
    handler = window.$eventNode
    handler(msg(ev.target.value))
  ]

onKeyUp = (msg) ->
  ['onkeyup', (ev) ->
    handler = window.$eventNode
    handler(msg(ev.target.value))
  ]

module.exports =
  onClick: onClick
  onChange: onChange
  onInput: onInput
  onKeyUp: onKeyUp
