onClick = (msg) ->
  ['onclick', (ev) ->
    handler = window.$eventNode
    handler(msg())
  ]

module.exports =
  onClick: onClick
