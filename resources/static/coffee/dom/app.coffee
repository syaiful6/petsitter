{Tuple2, update} = require '../utils/common'
{none} = require '../core/cmd/cmd'
{programWithFlags, map} = require './vdom'

beginnerProgram = (details) ->
  programWithFlags
    init: (_x) -> Tuple2(details.model, none)
    update: (msg) -> (model) -> Tuple2(details.update(msg)(model), none)
    view: details.view
    subscriptions: (_x) -> none

program = (app) ->
  programWithFlags(update(app, {init: (_x) -> app.init}))

programWithFlags = programWithFlags

module.exports =
  program: program
  map: map
  programWithFlags: programWithFlags
  beginnerProgram: beginnerProgram
