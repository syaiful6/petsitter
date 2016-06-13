{Just, Nothing} = require './maybe'

toMaybe = (result) ->
  if result.ctor == 'Ok'
    Just result.value0
  else
    Nothing

withDefault = (def) -> (result) ->
  if result.ctor == 'Ok' then result.value0 else def

Err = (a) ->
  ctor: 'Err'
  value0: a

err = Err

Ok = (a) ->
  ctor: 'Ok'
  value0: a

ok = Ok

andThen = (result) -> (callback) ->
  if result.ctor == 'Ok'
    callback(result.value0)
  else
    Err(result.value0)

map = (fun) -> (result) ->
  if result.ctor == 'Ok' then Ok(fun(result.value0)) else Err(result.value0)

formatError = (fun) -> (result) ->
  if result.ctor == 'Ok' then Ok(result.value0) else Err(fun(result.value0))

fromMaybe = (err) -> (maybe) ->
  if maybe.ctor == 'Just' then Ok(maybe.value0) else Err(err)

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
