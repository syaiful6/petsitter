{Just, Nothing} = require './maybe'

toMaybe = (result) ->
  if result.ctor == 'Ok'
    Just result._0
  else
    Nothing

withDefault = (def) -> (result) ->
  result._0 if result.ctor == 'Ok' else def

Err = (a) ->
  ctor: 'Err'
  _0: a

err = Err

Ok = (a) ->
  ctor: 'Ok'
  _0: a

ok = Ok

andThen = (result) -> (callback) ->
  if result.ctor == 'Ok'
    callback(result._0)
  else
    Err(result._0)

map = (fun) -> (result) ->
  Ok(fun(result._0)) if result.ctor == 'Ok' else Err(result._0)

formatError = (fun) -> (result) ->
  Ok(result._0) if result.ctor == 'Ok' else Err(fun(result._0))

fromMaybe = (err) -> (maybe) ->
  Ok(maybe._0) if maybe.ctor == 'Just' else Err(err)

module.exports =
  fromMaybe: fromMaybe
  formatError: formatError
  map: map
  andThen: andThen
  withDefault: withDefault
  toMaybe: toMaybe
  Ok: Ok
  ok: ok
  Err: Err
  err: err
