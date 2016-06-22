{tagged} = require '../core/tagged'
{compose, constant} = require '../core/lambda'

IO = tagged 'unsafePerform'

IO.of = compose IO, constant

IO::chain = (g) ->
  IO => g(@unsafePerform()).unsafePerform()

IO::map = (f) ->
  @chain (a) ->
    IO.of f(a)

IO::ap = (a) ->
  @chain (f) ->
    a.map f

module.exports = IO
