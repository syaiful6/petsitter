{map, apply, id, categoryFn} = require '../prelude/control'
basic = require '../basic'

$less$times = (dictApply) ->
  (a) ->
    (b) ->
      apply(dictApply)(map(dictApply.functor())(basic['const'])(a)) b

$times$greater = (dictApply) ->
  (a) ->
    (b) ->
      apply(dictApply) map(dictApply.functor())(basic['const'](id(categoryFn)))(a)(b)

# lift2 :: forall a b c f. (Apply f) => (a -> b -> c) -> f a -> f b -> f c
lift2 = (dictApply) ->
  (f) ->
    (a) ->
      (b) ->
        apply(dictApply)(map(dictApply.functor())(f)(a)) b

# lift3 :: forall a b c d f. (Apply f) => (a -> b -> c -> d) -> f a -> f b -> f c -> f d
lift3 = (dictApply) ->
  (f) ->
    (a) ->
      (b) ->
        (c) ->
          apply(dictApply)(apply(dictApply)(map(dictApply.functor())(f)(a))(b)) c

# lift4 :: forall a b c d e f. (Apply f) => (a -> b -> c -> d -> e) -> f a -> f b -> f c -> f d -> f e
lift4 = (dictApply) ->
  (f) ->
    (a) ->
      (b) ->
        (c) ->
          (d) ->
            apply(dictApply)(apply(dictApply)(apply(dictApply)(map(dictApply.functor())(f)(a))(b))(c)) d

# lift5 :: forall a b c d e f g. (Apply f) => (a -> b -> c -> d -> e -> g) -> f a -> f b -> f c -> f d -> f e -> f g
lift5 = (dictApply) ->
  (f) ->
    (a) ->
      (b) ->
        (c) ->
          (d) ->
            (e) ->
              apply(dictApply)(apply(dictApply)(apply(dictApply)(apply(dictApply)(map(dictApply.functor())(f)(a))(b))(c))(d)) e

module.exports =
  lift2: lift2
  lift3: lift3
  lift4: lift4
  lift5: lift5
  "*>": $times$greater
  "<*": $less$times
