scheduler = require '../core/scheduler'
{curry, compose} = require '../core/lambda'
Either = require '../data/either'

internal = (node) -> (eventName, decoder, toTask) ->
  scheduler.nativeBinding (callback) ->
    performTask = (event) ->
      result = decoder(event)
      if Either.isRight result
        scheduler.rawSpawn(toTask(result.value0))
      return
    node.addEventListener(eventName, performTask)

    ->
      node.removeEventListener(eventName, performTask)

module.exports =
  onWindow: curry(internal(window))
  onDocument: curry(internal(document))
