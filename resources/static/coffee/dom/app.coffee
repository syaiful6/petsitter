{extend} = require '../utils/object'
{none} = require '../core/cmd/cmd'
{Tuple} = require '../data/tuple'
{programWithFlags, map} = require './vdom'
{curry, constant} = require '../core/lambda'

beginnerProgram = (details) ->
  programWithFlags
    init: constant Tuple(details.model, none)
    update: curry (msg, model) ->
      Tuple details.update(msg, model), none
    view: details.view
    subscriptions: constant none

program = (app) ->
  prog = extend app, {
    init: constant(app.init)
  }
  programWithFlags prog

programWithFlags = programWithFlags

module.exports =
  program: program
  map: map
  programWithFlags: programWithFlags
  beginnerProgram: beginnerProgram
