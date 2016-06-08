{program} = require './dom/program'
{startApp} = require './core/platform'
{none} = require './core/cmd/cmd'
{Tuple2} = require './utils/common'
{onClick} = require './dom/events'
{div, button, span} = require './dom/helper'

init = ->
  Tuple2(model, none)

model = 0

Increment = ->
  ctor: 'Increment'

Decrement = ->
  ctor: 'Decrement'

update = (msg) -> (model) ->
  ctor = msg.ctor
  if ctor == 'Increment'
    Tuple2(model + 1, none)
  else if ctor == 'Decrement'
    Tuple2(model - 1, none)

test = (ev) ->
  console.log(ev)

view = (model) ->
  div(
    [],
    [
      button([onClick(Increment), ['className', "greeting"]], ["update #{model}"])
      , span([], [model])
    ]
  )

subscriptions = ->
  none

main = program
  init:init
  model: model
  view: view
  update: update
  subscriptions: subscriptions

app = startApp(main)
node = document.getElementById('app')
app = app.main.embed(node)
