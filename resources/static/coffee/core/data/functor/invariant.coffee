basic = require '../../basic'
{map, functorFn, functorArray} = require '../../prelude/control'
{invoke3, invoke2} = require '../../../utils/functools'

Invariant = (imap) ->
  {
    ctor: 'Invariant',
    # imap :: forall a b. (a -> b) -> (b -> a) -> f a -> f b
    imap: imap
  }

# imapF :: forall f a b. (Functor f) => (a -> b) -> (b -> a) -> f a -> f b
imapF = (dictFunctor) ->
  invoke2 map(functorFn), basic['const'], map(dictFunctor)

invariantArray = Invariant(imapF(functorArray))
invariantFn = Invariant(imapF(functorFn))

imap = (dictInvariant) ->
  dictInvariant.imap

module.export =
  Invariant: Invariant
  invariantFn: invariantFn
  invariantArray: invariantArray
  imap: imap
  imapF: imapF
