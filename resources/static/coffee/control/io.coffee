{compose, constant} = require '../core/lambda'

module.exports =
  class IO

    constructor: (@unsafePerformIO) ->

    @of: (val) ->
      new IO constant(val)

    map: (fun) ->
      new IO compose(fun, @unsafePerformIO)

    chain: (fun) ->
      new IO =>
        fun(@unsafePerformIO()).unsafePerformIO

    fork: ->
      new IO =>
        setTimeout =>
          @unsafePerformIO()
        , 0
