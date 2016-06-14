control = require '../control'

returnE = (a) ->
  ->
    a

bindE = (a) -> (f) ->
  ->
    f(a())()

runPure = (f) ->
  f()

whileE = (f) -> (a) ->
  ->
    while (f())
      a()
    {}

forE = (lo) -> (hi) -> (f) ->
  ->
    for i in [lo...hi]
      f(i)()
    return

foreachE = (as) -> (f) ->
  ->
    for item in [0...as.length]
      f(as[i])()

monadEff = control.Monad ->
  applicativeEff
, ->
  bindEff

bindEff = control.Bind ->
  applyEff
, bindE

applyEff = control.Apply ->
  functorEff
, control.ap(monadEff)

applicativeEff = control.Applicative ->
  applyEff
, returnE

functorEff = control.Functor control.liftA1(applicativeEff)

module.exports =
  monadEff: monadEff
  bindEff: bindEff
  applyEff: applyEff
  applicativeEff: applicativeEff
  functorEff: functorEff
  runPure: runPure
  foreachE: foreachE
  forE: forE
  whileE: whileE
