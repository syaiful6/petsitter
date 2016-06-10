{beginnerProgram} = require './dom/app'
{none} = require './core/cmd/sub'
{startApp} = require './core/platform'
{onClick} = require './dom/events'
{div, button, text, span} = require './dom/helper'
navigation = require './navigation'

subscriptions = (model) ->
  none

fromUrl = (url) ->
  parseInt url.slice(2)

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
    _1: navigation.modifyUrl model

init = (result) ->
  urlUpdate(result)(0)

main = navigation.program(urlParser)({subscriptions: subscriptions, model: model, view: view, update: update, init: init})

app = startApp(main)
node = document.getElementById('app')
app = app.main.embed(node)
