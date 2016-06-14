Semigroup = (append) ->
  ctor: 'Semigroup',
  append: append

append = (dictSemigroup) ->
  dictSemigroup.append

semigroupString = Semigroup((s) -> (s1) -> s + s1)
semigroupArray = Semigroup((a) -> (a1) -> a.concat(a1))

module.exports =
  Semigroup: Semigroup
  append: append
  semigroupArray: semigroupArray
  semigroupString: semigroupString
