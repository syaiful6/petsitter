{beginnerProgram} = require './dom/app'
{startApp} = require './core/platform'
{onClick} = require './dom/events'
{div, button, span} = require './dom/helper'

model = 0

Increment = ->
  ctor: 'Increment'

Decrement = ->
  ctor: 'Decrement'

update = (msg) -> (model) ->
  ctor = msg.ctor
  if ctor == 'Increment'
    model + 1
  else if ctor == 'Decrement'
    model - 1

view = (model) ->
  div(
    [],
    [ button([onClick(Decrement)], ["-"])
      , span([], [model])
      , button([onClick(Increment)], ["+"])
    ]
  )

main = beginnerProgram
  model: model
  view: view
  update: update

app = startApp(main)
node = document.getElementById('app')
app = app.main.embed(node)
