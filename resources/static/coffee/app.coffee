{none} = require './core/cmd/sub'
{bootstrap} = require './core/platform'
{onClick} = require './dom/events'
{div, button, text, span} = require './dom/helper'
{taggedSum} = require './core/tagged'
{curry, constant} = require './core/lambda'
tuple = require './data/tuple'
Either = require './data/either'
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
  return Either.Left('an empty string, cant convert it to a number') if s.length == 0
  number = Number(s)
  if not isNumber(number) or not isFinite(number)
    Either.Left('the url not a number')
  else
    Either.Right(number)

# toUrl :: Int -> String
toUrl = (count) ->
  '#/' + count.toString()

urlParser = navigation.makeParser (el) ->
  fromUrl el.hash

model = 0

Msg = taggedSum {
  Increment: [],
  Decrement: []
}

# update :: Msg -> Model -> (Model, Cmd)
update = curry (msg, model) ->
  if msg == Msg.Increment
    newModel = model + 1
  else
    newModel = model - 1
  tuple.Tuple newModel, navigation.newUrl toUrl(newModel)

view = (model) ->
  div(
    [],
    [ button([onClick(constant(Msg.Decrement))], [text "-" ])
      , span([], [text model.toString()])
      , button([onClick(constant(Msg.Increment))], [text "+"])
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
urlUpdate = curry (eith, model) ->
  Either.either urlUpdateOnError(model), urlUpdateOnSuccess, eith

# init :: Either a -> (Model, Cmd)
init = (eith) ->
  urlUpdate eith, 0

main = navigation.program urlParser, {
  subscriptions: subscriptions
  model: model
  view: view
  update: update
  init: init
  urlUpdate: urlUpdate
}

module.exports = bootstrap('petsitter', main)
