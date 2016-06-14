Comonad = (extend, extract) ->
  {
    ctor: 'Comonad'
    extend: extend
    extract: extract
  }

extract = (dictComonad) ->
  dictComonad.extract

module.exports =
  Comonad: Comonad
  extract: extract
