curry2 = (fun) ->
  wrapper = (a) -> (b) ->
    fun a, b
  wrapper.func = fun
  wrapper.arity = 2
  wrapper

curry3 = (fun) ->
  wrapper = (a) -> (b) -> (c) ->
    fun a, b, c
  wrapper.func = fun
  wrapper.arity = 3
  wrapper

curry4 = (fun) ->
  wrapper = (a) -> (b) -> (c) -> (d) ->
    fun a, b, c, d
  wrapper.func = fun
  wrapper.arity = 4
  wrapper

curry5 = (fun) ->
  wrapper = (a) -> (b) -> (c) -> (d) -> (e) ->
    func a, b, c, d, e
  wrapper.func = fun
  wrapper.arity = 5
  wrapper

curry6 = (fun) ->
  wrapper = (a) -> (b) -> (c) -> (d) -> (e) -> (f) ->
    fun a, b, c, d, e, f
  wrapper.func = fun
  wrapper.arity = 6
  wrapper

curry7 = (fun) ->
  wrapper = (a) -> (b) -> (c) -> (d) -> (e) -> (f) -> (g) ->
    fun a, b, c, d, e, f, g
  wrapper.func = fun
  wrapper.arity = 7
  wrapper

curry8 = (fun) ->
  wrapper = (a) -> (b) -> (c) -> (d) -> (e) -> (f) -> (g) -> (h) ->
    fun a, b, c, d, e, f, g, h
  wrapper.func = fun
  wrapper.arity = 8
  wrapper

curry9 = (fun) ->
  wrapper = (a) -> (b) -> (c) -> (d) -> (e) -> (f) -> (g) -> (h) -> (i) ->
    fun a, b, c, d, e, f, g, h, i
  wrapper.func = fun
  wrapper = 9
  wrapper

invoke2 = (fun, a, b) ->
  if fun.arity == 2 then fun.func(a, b) else fun(a)(b)

invoke3 = (fun, a, b, c) ->
  if fun.arity == 3 then fun.func(a, b, c) else fun(a)(b)(c)

invoke4 = (fun, a, b, c, d) ->
  if fun.arity == 4 then fun.func(a, b, c, d) else fun(a)(b)(c)(d)

invoke5 = (fun, a, b, c, d, e) ->
  if fun.arity == 5 then fun.func(a, b, c, d, e) else fun(a)(b)(c)(d)(e)

invoke6 = (fun, a, b, c, d, e, f) ->
  if fun.arity == 6 then fun.func(a, b, c, d, e, f) else fun(a)(b)(c)(d)(e)(f)

invoke7 = (fun, a, b, c, d, e, f, g) ->
  if fun.arity == 7 then fun.func(a, b, c, d, e, f, g) else fun(a)(b)(c)(d)(e)(f)(g)

invoke8 = (fun, a, b, c, d, e, f, g, h) ->
  if fun.arity == 8 then fun.func(a, b, c, d, e, f, g, h) else fun(a)(b)(c)(d)(e)(f)(g)(h)

invoke9 = (fun, a, b, c, d, e, f, g, h, i) ->
  if fun.arity == 9 then fun.func(a, b, c, d, e, f, g, h) else fun(a)(b)(c)(d)(e)(f)(g)(h)(i)

module.exports =
  curry2: curry2
  curry3: curry3
  curry4: curry4
  curry5: curry5
  curry6: curry6
  curry7: curry7
  curry8: curry8
  curry9: curry9
  invoke2: invoke2
  invoke3: invoke3
  invoke4: invoke4
  invoke5: invoke5
  invoke6: invoke6
  invoke7: invoke7
  invoke8: invoke8
  invoke9: invoke9
