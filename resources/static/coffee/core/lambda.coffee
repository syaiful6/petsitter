# ref to Array.prototype slice for easiest access
slice = Array::slice

# transform any array like object to array, used to transform
# arguments to array
#
# toArray :: ArrayLike a -> [a]
toArray = (a) ->
  slice.call a

# take the "tail" portion of array like object and transform it
# to array
#
# tail :: ArrayLike a -> [a]
tail = (a) ->
  slice.call a, 1

# take an array and arguments object, concatenate then to one array
#
# concatArgs :: [a] -> ArrayLike a -> [a]
concatArgs = (a, b) ->
  a.concat toArray(b)

# used internally to create function based argument and total artity
#
# createFn :: (a -> b) -> [a] -> number -> (a -> b)
createFn = (fn, args, totalArity) ->
  remainingArity = totalArity - args.length
  switch remainingArity
    when 0
      ->
        processInvocation fn, concatArgs(args, arguments), totalArity
    when 1
      (a) ->
        processInvocation fn, concatArgs(args, arguments), totalArity
    when 2
      (a, b) ->
        processInvocation fn, concatArgs(args, arguments), totalArity
    when 3
      (a, b, c) ->
        processInvocation fn, concatArgs(args, arguments), totalArity
    when 4
      (a, b, c, d) ->
        processInvocation fn, concatArgs(args, arguments), totalArity
    when 5
      (a, b, c, d, e) ->
        processInvocation fn, concatArgs(args, arguments), totalArity
    when 6
      (a, b, c, d, e, f) ->
        processInvocation fn, concatArgs(args, arguments), totalArity
    when 7
      (a, b, c, d, e, f, g) ->
        processInvocation fn, concatArgs(args, arguments), totalArity
    when 8
      (a, b, c, d, e, f, g, h) ->
        processInvocation fn, concatArgs(args, arguments), totalArity
    when 9
      (a, b, c, d, e, f, g, h, i) ->
        processInvocation fn, concatArgs(args, arguments), totalArity
    when 10
      (a, b, c, d, e, f, g, h, i, j) ->
        processInvocation fn, concatArgs(args, arguments), totalArity
    else
      createEvalFn fn, args, remainingArity

# used to create arguments list when create function using eval
#
# makeArgsList :: number -> string
makeArgList = (len) ->
  ("a#{i}" for i in [0...len]).join(',')

# create function using eval, this function only used when the curried function
# have arguments more then 10.
#
# createEvalFn :: (a -> b) -> [a] -> number -> (a -> b)
createEvalFn = (fn, args, arity) ->
  argList = makeArgList arity
  fnStr = 'false||' +
    'function(' + argList + '){ return processInvocation(fn, concatArgs(args, arguments)); }'
  eval(fnStr)

# trim the array
trimArrLength = (arr, len) ->
  if arr.length > len then arr.slice(0, len) else arr

# Process the invocation, if the arguments length match with the total arity
# then call fn, otherwise create new function to receive more argument needed.
processInvocation = (fn, argsArr, totalArity) ->
  args = trimArrLength argsArr, totalArity
  if args.length == totalArity then fn.apply(null, argsArr) else createFn(fn, argsArr, totalArity)

# public interface, curry the provided function
curry = (fn) ->
  createFn(fn, [], fn.length)

curry.to = curry (arity, fn) ->
  createFn(fn, [], arity)

curry.adaptTo = curry (num, fn) ->
  curry.to num, (context) ->
    args = tail(arguments).concat(context)
    fn.apply(this, args)

# -- Combinatoric

# Give back the argument to you
#
# identity :: a -> a
identity = (x) -> x

# Accept two arguments but return the first one
#
# constant:: x -> y -> x
constant = (x, y) -> x

# Flip the order of functions arguments
# flip :: (b -> a -> c) -> (a -> b -> c)
flip = (f, a, b) ->
  f(b)(a)

# apply a function to a single argument
# apply :: (f -> a) -> a -> f(a)
apply = (f, a) ->
  f(a)

# compose two functions
# compose :: (b -> c) -> (a -> b) -> (a -> c)
compose = (f, g, x) ->
  f(g(x))

spread = (f, xs) ->
  xs.reduce (g, c) ->
    g(c)
  , f

uncurry = (f) -> ->
  spread f, toArray(arguments)

upon = (f, g, a, b) ->
  f(g(a))(g(b))

module.exports =
  curry: curry,
  identity: curry(identity),
  constant: curry(constant),
  flip: curry(flip),
  apply: curry(apply),
  compose: curry(compose),
  spread: curry(spread),
  uncurry: uncurry,
  upon: curry(upon)
