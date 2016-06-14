{pure} = require '../prelude/control'
{alternativeArray} = require './alternative'
{empty} = require './plus'

MonadPlus = (alternative, monad) ->
  {
    ctor: 'MonadPlus'
    alternative: alternative
    monad: monad
  }

monadPlusArray = MonadPlus ->
  alternativeArray
, ->
  preludeControl.monadArray

guard = (dictMonadPlus) ->
  (v) ->
    if v
      pure((dictMonadPlus.alternative())['applicative']())({})
    if not v
      empty((dictMonadPlus.alternative())['plus']())

module.exports =
  MonadPlus: MonadPlus
  monadPlusArray: monadPlusArray
  guard: guard
