{beginnerProgram} = require './dom/app'
{none} = require './core/cmd/sub'
{startApp} = require './core/platform'
{onClick} = require './dom/events'
{div, button, text, span} = require './dom/helper'
{invoke2, invoke3} = require './utils/functools'
tuple = require './core/data/tuple'
either = require './core/data/either'
navigation = require './navigation'

toString = Object::toString

subscriptions = (model) ->
  none

# isNumber :: any -> Boolean
isNumber = (value) ->
  typeof value == 'number' or value and typeof value == 'object' and toString.call(value) == '[object Number]' or false

# isFinite :: any -> Boolean
isFinite = (value) ->
  window.isFinite(value) and not window.isNaN(parseFloat(value))

# fromUrl :: String -> Either a
fromUrl = (url) ->
  s = url.slice(2)
  return either.Left('an empty string, cant convert it to a number') if s.length == 0
  number = Number(s)
  if not isNumber(number) or not isFinite(number)
    either.Left('the url not a number')
  else
    either.Right(number)

# toUrl :: Int -> String
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
  tuple.Tuple newModel, navigation.newUrl toUrl(newModel)

view = (model) ->
  div(
    [],
    [ button([onClick(Decrement)], [text "-" ])
      , span([], [text model.toString()])
      , button([onClick(Increment)], [text "+"])
    ]
  )

# urlUpdateOnError :: Model -> * -> (Model, Cmd)
urlUpdateOnError = (model) ->
  ->
    tuple.Tuple model, navigation.modifyUrl toUrl(model)

# urlUpdateOnSuccess :: Model -> Int -> (Model, Cmd)
urlUpdateOnSuccess = (v) ->
  tuple.Tuple v, none

# urlUpdate :: Either a -> Model -> (Model, Cmd)
urlUpdate = (eith) -> (model) ->
  invoke3 either.either, urlUpdateOnError(model), urlUpdateOnSuccess, eith

# init :: Either a -> (Model, Cmd)
init = (eith) ->
  invoke2 urlUpdate, eith, 0

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
