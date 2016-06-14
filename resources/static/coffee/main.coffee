{beginnerProgram} = require './dom/app'
{none} = require './core/cmd/sub'
{startApp} = require './core/platform'
{onClick} = require './dom/events'
{Ok, Err} = require './core/data/result'
{div, button, text, span} = require './dom/helper'
{invoke2} = require './utils/functools'
navigation = require './navigation'

toString = Object::toString

subscriptions = (model) ->
  none

isNumber = (value) ->
  typeof value == 'number' or value and typeof value == 'object' and toString.call(value) == '[object Number]' or false

isFinite = (value) ->
  window.isFinite(value) and not window.isNaN(parseFloat(value))

fromUrl = (url) ->
  s = url.slice(2)
  number = new Number(s)
  if not isNumber(number) or not isFinite(number)
    Err('the url not a number')
  else
    Ok(number)

toUrl = (count) ->
  '#/' + count.toString()

urlParser = navigation.makeParser (el) ->
  fromUrl el.hash

model = 0

Increment = ->
  ctor: 'Increment'

Decrement = ->
  ctor: 'Decrement'

# update :: Msg -> Model -> (Model, Cmd)
update = (msg) -> (model) ->
  ctor = msg.ctor
  if ctor == 'Increment'
    newModel = model + 1
  else if ctor == 'Decrement'
    newModel = model - 1
  ctor: '_Tuple2'
  value0: newModel
  value1: navigation.newUrl toUrl(newModel)

view = (model) ->
  div(
    [],
    [ button([onClick(Decrement)], [text "-" ])
      , span([], [text model.toString()])
      , button([onClick(Increment)], [text "+"])
    ]
  )

# urlUpdate :: Result -> Model -> (Model, Cmd)
urlUpdate = (result) -> (model) ->
  if result.ctor == 'Ok'
    ctor: '_Tuple2'
    value0: result.value0
    value1: none
  else
    ctor: '_Tuple2'
    value0: model
    value1: navigation.modifyUrl toUrl(model)

init = (result) ->
  urlUpdate(result)(0)

main = invoke2 navigation.program, urlParser, {
  subscriptions: subscriptions
  model: model
  view: view
  update: update
  init: init
  urlUpdate: urlUpdate
}

app = startApp(main)
node = document.getElementById('app')
app = app.main.embed(node)
