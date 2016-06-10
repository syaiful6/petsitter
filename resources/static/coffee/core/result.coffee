{Just, Nothing} = require './maybe'

toMaybe = (result) ->
  if result.ctor == 'Ok'
    Just result._0
  else
    Nothing

withDefault = (def) -> (result) ->
  if result.ctor == 'Ok' then result._0 else def

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
  if result.ctor == 'Ok' then Ok(fun(result._0)) else Err(result._0)

formatError = (fun) -> (result) ->
  if result.ctor == 'Ok' then Ok(result._0) else Err(fun(result._0))

fromMaybe = (err) -> (maybe) ->
  if maybe.ctor == 'Just' then Ok(maybe._0) else Err(err)

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
