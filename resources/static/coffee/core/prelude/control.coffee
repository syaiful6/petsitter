# define control utility, all type class are just dictionary

# a Semigroupid similiar to Category, but does not require an id
#  element `id`, just composable morphisms.
# https://en.wikipedia.org/wiki/Semigroupoid
Unit = (x) ->
  x

Semigroupoid = (compose) ->
  ctor: 'Semigroupoid'
  # compose :: forall b c d. a c d -> a b c -> a b d
  compose: compose

Category = (semigroupid, id) ->
  ctor: 'Category'
  semigroupid: semigroupid
  id: id

Functor = (map) ->
  ctor: 'Functor'
  map: map

Apply = (functor, apply) ->
  ctor: 'Apply'
  functor: functor
  apply: apply

Applicative = (apply, pure) ->
  ctor: 'Applicative'
  apply: apply
  pure: pure

Bind = (apply, bind) ->
  ctor: 'Bind'
  apply: apply
  bind: bind

Monad = (applicative, bind) ->
  ctor: 'Monad'
  applicative: applicative
  bind: bind

# map :: forall f a b. (Functor f) => (a -> b) -> f a -> f b
map = (dictFunctor) ->
  dictFunctor.map

# compose :: forall b c d. a c d -> a b c -> a b d
compose = (dictSemigroupoid) ->
  dictSemigroupoid.compose

# bind :: forall a b. m a -> (a -> m b) -> m b
bind = (dictBind) ->
  dictBind.bind

# apply :: forall f a b. (Apply f) => f (a -> b) -> f a -> f b
apply = (dictApply) ->
  dictApply.apply

# pure :: forall a. a -> f a
pure = (dictApplicative) ->
  dictApplicative.pure

id = (dictCategory) ->
  dictCategory.id

liftM1 = (dictMonad) -> (f) -> (a) ->
  bind(dictMonad.bind())(a)((v) ->
    pure(dictMonad.applicative())(f(v))
  )

liftA1 = (dictApplicative) -> (f) -> (a) ->
  apply(dictApplicative.apply())(pure(dictApplicative)(f))(a)

ap = (dictMonad) -> (f) -> (a) ->
  bind(dictMonad.bind())(f)((v) ->
    bind(dictMonad.bind())(a)((v1) ->
      pure(dictMonad.applicative())(v(v1))
    )
  )

unit = {}

# an instance of Semigroup
semigroupoidFn = Semigroupoid (f) -> (g) -> (x) -> f g x

functorFn = Functor compose(semigroupoidFn)

categoryFn = Category ->
  semigroupoidFn
, (x) -> x

applyFn = do ->
  fntor = ->
    functorFn
  applier = (f) -> (g) -> (x) ->
    f(x)(g(x))
  Apply fntor, applier

bindFn = do (applyFn) ->
  applier = ->
    applyFn
  binder = (m) -> (f) -> (x) ->
    f(m(x))(x)
  Bind applier, binder

applicativeFn = do (applyFn) ->
  _const = (a) -> (b) -> a
  Applicative ->
    applyFn
  , _const

monadFn = Monad ->
  applicativeFn
, ->
  bindFn

monadArray = Monad ->
  applicativeArray
, ->
  bindArray

applyArray = Apply ->
  functorArray
, ap(monadArray)

bindArray = do ->
  binder = (arr) -> (f) ->
    (f(item) for item in arr)
  Bind ->
    applyArray
  , binder

functorArray = do ->
  arrayMap = (fun) -> (arr) ->
    (fun(item) for item in arr)
  Functor arrayMap

applicativeArray = Applicative ->
  applyArray
, (x) -> [x]

module.exports =
  Semigroupoid: Semigroupoid
  Category: Category
  Functor: Functor
  Apply: Apply
  Applicative: Applicative
  Bind: Bind
  Monad: Monad
  map: map
  compose: compose
  apply: apply
  id: id
  pure: pure
  bind: bind
  liftM1: liftM1
  liftA1: liftA1
  ap: ap
  semigroupoidFn: semigroupoidFn
  categoryFn: categoryFn
  functorFn: functorFn
  bindFn: bindFn
  applicativeFn: applicativeFn
  monadFn: monadFn
  monadArray: monadArray
  applyArray: applyArray
  applicativeArray: applicativeArray
  bindArray: bindArray
  functorArray: functorArray
  unit: unit
  Unit: Unit

