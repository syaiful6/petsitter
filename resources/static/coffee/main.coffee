{beginnerProgram} = require './dom/app'
{none} = require './core/cmd/sub'
{startApp} = require './core/platform'
{onClick} = require './dom/events'
{Ok, Err} = require './core/result'
{div, button, text, span} = require './dom/helper'
navigation = require './navigation'

subscriptions = (model) ->
  none

fromUrl = (url) ->
  len = url.length
  return Err('could not convert empty string to integer') if len == 0
  s = url.slice(2)
  start = 0
  if url[0] == '-'
    if len == 1
      return Err("could not convert string '" + s + "' to an Int" )
    start = 1
  for i in [start...length]
    c = s[i]
    if c < '0' or '9' < c
      return Err("could not convert string '" + s + "' to an Int" )
  Ok(parseInt(s, 10))

toUrl = (count) ->
  '#/' + count.toString()

urlParser = navigation.makeParser (el) ->
  fromUrl el.hash

model = 0

Increment = ->
  ctor: 'Increment'

Decrement = ->
  ctor: 'Decrement'

update = (msg) -> (model) ->
  ctor = msg.ctor
  if ctor == 'Increment'
    newModel = model + 1
  else if ctor == 'Decrement'
    newModel = model - 1
  ctor: '_Tuple2'
  _0: newModel
  _1: navigation.newUrl toUrl(newModel)

view = (model) ->
  div(
    [],
    [ button([onClick(Decrement)], [text "-" ])
      , span([], [text model.toString()])
      , button([onClick(Increment)], [text "+"])
    ]
  )

urlUpdate = (result) -> (model) ->
  if result.ctor == 'Ok'
    ctor: '_Tuple2'
    _0: result._0
    _1: none
  else
    ctor: '_Tuple2'
    _0: model
    _1: navigation.modifyUrl toUrl(model)

init = (result) ->
  urlUpdate(result)(0)

main = navigation.program(urlParser)({subscriptions: subscriptions, model: model, view: view, update: update, init: init, urlUpdate: urlUpdate})

app = startApp(main)
node = document.getElementById('app')
app = app.main.embed(node)
