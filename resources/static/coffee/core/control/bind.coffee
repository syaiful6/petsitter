preludeControl = require '../prelude/control'

$greater$eq$greater = (dictBind) ->
  (f) ->
    (g) ->
      (a) ->
        preludeControl.bind(dictBind)(f(a)) g

$eq$less$less = (dictBind) ->
  (f) ->
    (m) ->
      preludeControl.bind(dictBind)(m) f

$less$eq$less = (dictBind) ->
  (f) ->
    (g) ->
      (a) ->
        $eq$less$less(dictBind)(f) g(a)

join = (dictBind) ->
  (m) ->
    preludeControl.bind(dictBind)(m) preludeControl.id(preludeControl.categoryFn)

ifM = (dictBind) ->
  (cond) ->
    (t) ->
      (f) ->
        preludeControl.bind(dictBind)(cond) (cond$prime) ->
          if cond$prime
            return t
          if !cond$prime
            return f
          throw new Error('Unexpected value detected')
          return

module.exports =
  join: join
  ifM: ifM
  "<=<": $less$eq$less,
  ">=>": $greater$eq$greater,
  "=<<": $eq$less$less
