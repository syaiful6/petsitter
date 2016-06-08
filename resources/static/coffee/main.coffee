{program} = require './dom/program'
{batch, addPublicModule} = require './core/platform'
{fromArray, Nil} = require './core/list'
{Tuple2} = require './utils/common'
{onClick} = require './dom/events'
h = require 'virtual-dom/h'
m = require './dom/helper'

{div, button, span} = m(h)

init = ->
  Tuple2(model, batch(Nil))

model = 0

Increment = ->
  ctor: 'Increment'

Decrement = ->
  ctor: 'Decrement'

update = (msg) -> (model) ->
  ctor = msg.ctor
  if ctor == 'Increment'
    Tuple2(model + 1, batch(Nil))
  else if ctor == 'Decrement'
    Tuple2(model - 1, batch(Nil))

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

main = {
  main: program {
    init:init,
    model: model,
    view: view,
    update: update,
    subscriptions: -> batch(Nil)
  }
}

app = {}
app['main'] = app['main'] or {}
addPublicModule(app['main'], 'main', main)
node = document.getElementById('app')
app = app.main.embed(node)
