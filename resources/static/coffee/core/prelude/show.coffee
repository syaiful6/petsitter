identity = require '../basic'

Show = (show) ->
  {
    ctor: 'Show'
    show: show
  }

show = (dictShow) ->
  dictShow.show

showString = Show identity
showChar = Show identity
showNumber = Show (v) ->
  if v == (v | 0) then n + ".0" else v.toString()

showBoolean = Show (v) ->
  if v then 'true' else 'false'

showArray = (dictShow) ->
  showArrayImp = (f) -> (xs) ->
    "[" + (f(item) for item in xs).join(",") + "]"
  Show show(dictShow)

module.exports =
  Show: Show
  show: show
  showString: showString
  showChar: showChar
  showNumber: showNumber
  showBoolean: showBoolean
  showArray: showArray
