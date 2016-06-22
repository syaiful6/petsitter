{Tuple, snd, fst} = require './tuple'
{tagged} = require '../core/tagged'
{constant, compose} = require '../core/lambda'

State = tagged 'run'

State.of = (a) ->
  State (b) ->
    Tuple a, b

State.get = State (s) ->
  Tuple s, s

State::chain = (f) ->
  State (s) ->
    result = @run s
    f(fst(result)).run(snd(result))

State::map = (f) ->
  @chain (a) ->
    State.of f(a)

State::ap = (a) ->
  @chain (f) ->
    a.map f

State.modify = (f) ->
  State (s) ->
    Tuple null, f(s)

State.put = compose State.modify, constant

State::evalState = (s) ->
  fst @run(s)

State::exec = (s) ->
  snd @run(s)

State.StateT = (M) ->
  StateT = tagged 'run'

  StateT.lift = (m) ->
    StateT (b) ->
      m.map (c) ->
        Tuple c, b

  StateT.of = (a) ->
    StateT (b) ->
      M.of Tuple a, b

  StateT::chain = (f) ->
    StateT (s) ->
      result = @run s
      result.chain (t) ->
        f(fst(t)).run(snd(t))

  StateT::map = (f) ->
    @chain (a) ->
      StateT.of f(a)

  StateT.ap = (a) ->
    @chain (f) ->
      a.map f

  StateT.get = StateT (s) ->
    M.of Tuple(s, s)

  StateT.modify = (f) ->
    StateT (s) ->
      M.of Tuple(null, f(s))

  StateT.put = compose StateT.modify, constant

  StateT::evalState = (s) ->
    @run(s).map (t) ->
      fst t

  StateT::exec = (s) ->
    @run(s).map (t) ->
      snd t

  StateT

module.exports =
  State: State
  StateT: StateT
