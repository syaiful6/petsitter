scheduler = require '../core/scheduler'
{curry3} = require '../utils/functools'

internal = (node) -> (eventName, decoder, toTask) ->
  scheduler.nativeBinding (callback) ->
    performTask = (event) ->
      result = decoder(event)
      if result.ctor == 'Ok'
        scheduler.rawSpawn(toTask(result._0))
      return
    node.addEventListener(eventName, performTask)

    ->
      node.removeEventListener(eventName, performTask)

module.exports =
  onWindow: curry3(internal(window))
  onDocument: curry3(internal(document))
