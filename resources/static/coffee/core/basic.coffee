flip = (f) -> (b) -> (a) ->
  f(a)(b)

identity = (x) -> x

_const = (a) -> (b) -> a

module.exports =
  identity: identity
  flip: flip
  "const": _const
