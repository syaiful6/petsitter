var Unit = (function() {
  function Unit(x) {
    return x;
  }

  return Unit;

})();

var LT = (function () {
  function LT() {
  }

  LT.value = new LT();

  return LT;

})();

var GT = (function () {
  function GT() {

  }

  GT.value = new GT();

  return GT;

})();

var EQ = (function () {
  function EQ() {

  }

  EQ.value = new EQ();

  return EQ;

})();

var Semigroupoid = (function() {
  function Semigroupoid(compose) {
    this.compose = compose;
  }

  return Semigroupoid;

})();

var Category = (function() {
  function Category(semigroupoid, id) {
    this["__super__.prelude.Semigroupoid"] = semigroupoid;
    this.id = id;
  }

  return Category;

})();

var Functor = (function() {
  function Functor(map) {
    this.map = map;
  }

  return Functor;

})();

var Apply = (function() {
  function Apply(functor, apply1) {
    this.apply = apply1;
    this['__super__.prelude.Functor'] = functor;
  }

  return Apply;

})();

var Applicative = (function() {
  function Applicative(apply, pure) {
    this.pure = pure;
    this['__super__.prelude.Apply'] = apply;
  }

  return Applicative;

})();

var Bind = (function() {
  function Bind(apply, bind1) {
    this.bind = bind1;
    this['__super__.prelude.Apply'] = apply;
  }

  return Bind;

})();

var Monad = (function() {
  function Monad(applicative, bind) {
    this['__super__.prelude.Applicative'] = applicative;
    this['__super__.prelude.Bind'] = bind;
  }

  return Monad;

})();

var Semigroup = (function() {
  function Semigroup(append) {
    this.append = append;
  }

  return Semigroup;

})();

var Semiring = (function() {
  function Semiring(add, mul, one, zero) {
    this.add = add;
    this.mul = mul;
    this.one = one;
    this.zero = zero;
  }

  return Semiring;

})();

var Ring = (function() {
  function Ring(semiring, sub) {
    this.sub = sub;
    this['__super__.prelude.Semiring'] = semiring;
  }

  return Ring;

})();

var ModuloSemiring = (function() {
  function ModuloSemiring(semiring, div, mod) {
    this.div = div;
    this.mod = mod;
    this['__super__.prelude.Semiring'] = semiring;
  }

  return ModuloSemiring;

})();

var DivisionRing = (function() {
  function DivisionRing(modulo, ring) {
    this['__super__.prelude.ModuloSemiring'] = modulo;
    this['__super__.prelude.Ring'] = ring;
  }

  return DivisionRing;

})();

var Num = (function() {
  function Num(division) {
    this['__super__.prelude.DivisionRing'] = division;
  }

  return Num;

})();

var Eq = (function() {
  function Eq(eq1) {
    this.eq = eq1;
  }

  return Eq;

})();

var Ord = (function() {
  function Ord(eq, compare) {
    this.compare = compare;
    this['__super__.prelude.Eq'] = eq;
  }

  return Ord;

})();

var Bounded = (function() {
  function Bounded(bottom, top) {
    this.bottom = bottom;
    this.top = top;
  }

  return Bounded;

})();

var BoundedOrd = (function() {
  function BoundedOrd(bounded, ord) {
    this['__super__.prelude.Bounded'] = bounded;
    this['__super__.prelude.Ord'] = ord;
  }

  return BoundedOrd;

})();

var BooleanAlgebra = (function() {
  function BooleanAlgebra(bounded, conj, disj, not) {
    this['__super__.prelude.Bounded'] = bounded;
    this.conj = conj;
    this.disj = disj;
    this.not = not;
  }

  return BooleanAlgebra;

})();

var Show = (function() {
  function Show(show) {
    this.show = show;
  }

  return Show;

})();

// utility
var arrayMap = function (fun) {
  return function (arr) {
    let len = arr.length;
    let results = new Array(len);
    for (var i = 0; i < len; i++) {
      results[i] = fun(arr[i]);
    }
    return results;
  };
}

var arrayBind = function (arr) {
  return function (f) {
    var result = [];
    for (var i = 0, l = arr.length; i < l; i++) {
      Array.prototype.push.apply(result, f(arr[i]));
    }
    return result;
  };
};

// string
var concatString = (s1) => (s2) => s1 + s2
var concatArray = (a1) => (a2) => a1.concat(a2)

var intAdd = (i1) => (i2) => i1 + i2 | 0
var intMul = (i1) => (i2) => i1 * i2 | 0

var numAdd = (i1) => (i2) => i1 + i2
var numMul = (i1) => (i2) => i1 * i2

var intDiv = (x) => (y) => x / y | 0
var intMod = (x) => (y) => x % y

var numDiv = (x) => (y) => x / y

var intSub = (x) => (y) => x - y  | 0
var numSub = (x) => (y) => x - y

var refEq = (x) => (y) => x === y
var refIneq = (x) => (y) => x !== y

var eqArrayImpl = function (f) {
  return function (xs) {
    return function (ys) {
      if (xs.length !== ys.length) return false;
      for (var i = 0; i < xs.length; i++) {
        if (!f(xs[i])(ys[i])) return false;
      }
      return true;
    };
  };
};

var ordArrayImpl = function (f) {
  return function (xs) {
    return function (ys) {
      var i = 0;
      var xlen = xs.length;
      var ylen = ys.length;
      while (i < xlen && i < ylen) {
        var x = xs[i];
        var y = ys[i];
        var o = f(x)(y);
        if (o !== 0) {
          return o;
        }
        i++;
      }
      if (xlen === ylen) {
        return 0;
      } else if (xlen > ylen) {
        return -1;
      } else {
        return 1;
      }
    };
  };
};

var unsafeCompareImpl = function (lt) {
  return function (eq) {
    return function (gt) {
      return function (x) {
        return function (y) {
          return x < y ? lt : x > y ? gt : eq;
        };
      };
    };
  };
};

var topInt = 2147483647;
var bottomInt = -2147483648;

var topChar = String.fromCharCode(65535);
var bottomChar = String.fromCharCode(0);

var boolOr = function (b1) {
  return function (b2) {
    return b1 || b2;
  };
};

var boolAnd = function (b1) {
  return function (b2) {
    return b1 && b2;
  };
};

var boolNot = function (b) {
  return !b;
};

var showIntImpl = function (n) {
  return n.toString();
};

var showNumberImpl = function (n) {
  /* jshint bitwise: false */
  return n === (n | 0) ? n + ".0" : n.toString();
};

var showCharImpl = function (c) { return c; };

var showStringImpl = function (s) { return s; };

var showArrayImpl = function (f) {
  return function (xs) {
    var ss = [];
    for (var i = 0, l = xs.length; i < l; i++) {
      ss[i] = f(xs[i]);
    }
    return "[" + ss.join(",") + "]";
  };
};

var unit = {};
var zero = (dict) => dict.zero
var unsafeCompare = unsafeCompareImpl(LT.value)(EQ.value)(GT.value);
var top = (dict) => dict.top
var sub = (dict) => dict.sub

var showUnit = new Show(() => "unit");

var showString = new Show(showStringImpl);

var showOrdering = new Show(function (v) {
    if (v instanceof LT) {
        return "LT";
    };
    if (v instanceof GT) {
        return "GT";
    };
    if (v instanceof EQ) {
        return "EQ";
    };
    throw new Error("Failed pattern match: " + [ v.constructor.name ]);
});

var showNumber = new Show(showNumberImpl);

var showInt = new Show(showIntImpl);

var showChar = new Show(showCharImpl);

var showBoolean = new Show(function (v) {
  if (v) {
      return "true";
  };
  if (!v) {
      return "false";
  };
  throw new Error("Failed pattern match: " + [ v.constructor.name ]);
});

var show = function (dict) {
  return dict.show;
};

var $dollar = (f) => (x) => f(x)

var $hash = (x) => (f) => f(x)

var showArray = function (dictShow) {
  return new Show(showArrayImpl(show(dictShow)));
};

var semiringUnit = new Semiring(function (v) {
  return function (v1) {
    return unit;
  };
}, function (v) {
  return function (v2) {
    return unit;
  };
}, unit, unit);

var semiringNumber = new Semiring(numAdd, numMul, 1.0, 0.0);

var semiringInt = new Semiring(intAdd, intMul, 1, 0);

var semigroupoidFn = new Semigroupoid(function (f) {
  return function (g) {
    return function (x) {
        return f(g(x));
    };
  };
});

var semigroupString = new Semigroup(concatString);

var semigroupOrdering = new Semigroup(function (v) {
  return function (v1) {
    if (v instanceof LT) {
      return LT.value;
    };
    if (v instanceof GT) {
      return GT.value;
    };
    if (v instanceof EQ) {
      return v1;
    };
    throw new Error(
      "Failed pattern match: " + [ v.constructor.name, v1.constructor.name ]
    );
  };
});
var semigroupUnit = new Semigroup(function (v) {
  return function (v1) {
    return unit;
  };
});
var semigroupArray = new Semigroup(concatArray);

var ringUnit = new Ring(function () {
  return semiringUnit;
}, function (v) {
  return function (v1) {
    return unit;
  };
});

var ringNumber = new Ring(function () {
  return semiringNumber;
}, numSub);

var ringInt = new Ring(function () {
  return semiringInt;
}, intSub);

var pure = (dict) => dict.pure

var one = (dict) => dict.one
var not = (dict) => dict.not
var negate = function (dictRing) {
  return function (a) {
    return sub(dictRing)(zero(dictRing["__super__.prelude.Semiring"]()))(a);
  }
};

var mul = (dict) => dict.mul

var moduloSemiringUnit = new ModuloSemiring(function () {
  return semiringUnit;
}, function (v) {
  return function (v1) {
    return unit;
  };
}, function (v) {
  return function (v1) {
    return unit;
  };
});

var moduloSemiringNumber = new ModuloSemiring(function () {
  return semiringNumber;
}, numDiv, function (v) {
  return function (v1) {
    return 0.0;
  };
});

var moduloSemiringInt = new ModuloSemiring(function () {
    return semiringInt;
}, intDiv, intMod);

var mod = (dict) => dict.mod
var map = (dict) => dict.map
var id = (dict) => dict.id

var $less$dollar$greater = function (dictFunctor) {
  return map(dictFunctor);
};

var $less$hash$greater = function (dictFunctor) {
  return function (fa) {
    return function (f) {
      return map(dictFunctor)(f)(fa);
    };
  };
};

var functorArray = new Functor(arrayMap);

var flip = (f) => (b) => (a) => f(a)(b)

var eqUnit = new Eq(function (v) {
  return function (v1) {
    return true;
  };
});

var ordUnit = new Ord(function () {
  return eqUnit;
}, function (v) {
  return function (v1) {
    return EQ.value;
  };
});

var eqString = new Eq(refEq);
var ordString = new Ord(function () {
    return eqString;
}, unsafeCompare);
var eqOrdering = new Eq(function (v) {
  return function (v1) {
    if (v instanceof LT && v1 instanceof LT) {
      return true;
    };
    if (v instanceof GT && v1 instanceof GT) {
      return true;
    };
    if (v instanceof EQ && v1 instanceof EQ) {
      return true;
    };
    return false;
  };
});

var ordOrdering = new Ord(function () {
  return eqOrdering;
}, function (v) {
  return function (v1) {
    if (v instanceof LT && v1 instanceof LT) {
      return EQ.value;
    };
    if (v instanceof EQ && v1 instanceof EQ) {
      return EQ.value;
    };
    if (v instanceof GT && v1 instanceof GT) {
      return EQ.value;
    };
    if (v instanceof LT) {
      return LT.value;
    };
    if (v instanceof EQ && v1 instanceof LT) {
      return GT.value;
    };
    if (v instanceof EQ && v1 instanceof GT) {
      return LT.value;
    };
    if (v instanceof GT) {
      return GT.value;
    };
    throw new Error("Failed pattern match: " + [ v.constructor.name, v1.constructor.name ]);
  };
});

var eqNumber = new Eq(refEq);

var ordNumber = new Ord(function () {
  return eqNumber;
}, unsafeCompare);

var eqInt = new Eq(refEq);

var ordInt = new Ord(function () {
  return eqInt;
}, unsafeCompare);

var eqChar = new Eq(refEq);

var ordChar = new Ord(function () {
  return eqChar;
}, unsafeCompare);

var eqBoolean = new Eq(refEq);

var ordBoolean = new Ord(function () {
  return eqBoolean;
}, unsafeCompare);

var eq = (dict) => dict.eq
var eqArray = (dict) => new Eq(eqArrayImpl(eq(dict)))

var divisionRingUnit = new DivisionRing(function () {
  return moduloSemiringUnit;
}, function () {
  return ringUnit;
});

var numUnit = new Num(function () {
  return divisionRingUnit;
});

var divisionRingNumber = new DivisionRing(function () {
  return moduloSemiringNumber;
}, function () {
  return ringNumber;
});

var numNumber = new Num(function () {
  return divisionRingNumber;
});

var div = (dict) => dict.div

var disj = (dict) => dict.disj

var _const = (a) => (v) => a
var _void = (dictFunctor) => (fa) => map(dictFunctor)(_const(unit))(fa)

var conj = (dict) => dict.conj

var compose = (dict) => dict.compose

var functorFn = new Functor(compose(semigroupoidFn));

var compare = (dict) => dict.compare

var $less$less$less = function (dictSemigroupoid) {
  return compose(dictSemigroupoid);
};
var $greater$greater$greater = function (dictSemigroupoid) {
  return flip(compose(dictSemigroupoid));
};

var ordArray = function (dictOrd) {
  return new Ord(function () {
    return eqArray(dictOrd["__super__.prelude.Eq"]());
  }, function (xs) {
    return function (ys) {
      return $dollar(compare(ordInt)(0))(ordArrayImpl(function (x) {
        return function (y) {
          var v = compare(dictOrd)(x)(y);
          if (v instanceof EQ) {
            return 0;
          };
          if (v instanceof LT) {
            return 1;
          };
          if (v instanceof GT) {
            return negate(ringInt)(1);
          };
          throw new Error("Failed pattern match: " + [ v.constructor.name ]);
        };
      })(xs)(ys));
    };
  });
};

var $less = function (dictOrd) {
  return function (a1) {
    return function (a2) {
      var v = compare(dictOrd)(a1)(a2);
      if (v instanceof LT) {
        return true;
      };
      return false;
    };
  };
};
var $less$eq = function (dictOrd) {
  return function (a1) {
    return function (a2) {
      var v = compare(dictOrd)(a1)(a2);
      if (v instanceof GT) {
        return false;
      };
      return true;
    };
  };
};

var $greater = function (dictOrd) {
  return function (a1) {
    return function (a2) {
      var v = compare(dictOrd)(a1)(a2);
      if (v instanceof GT) {
        return true;
      };
      return false;
    };
  };
};

var $greater$eq = function (dictOrd) {
  return function (a1) {
    return function (a2) {
      var v = compare(dictOrd)(a1)(a2);
      if (v instanceof LT) {
        return false;
      };
      return true;
    };
  };
};

var categoryFn = new Category(function () {
  return semigroupoidFn;
}, function (x) {
  return x;
});

var boundedUnit = new Bounded(unit, unit);

var boundedOrdering = new Bounded(LT.value, GT.value);

var boundedOrdUnit = new BoundedOrd(function () {
  return boundedUnit;
}, function () {
  return ordUnit;
});

var boundedOrdOrdering = new BoundedOrd(function () {
    return boundedOrdering;
}, function () {
    return ordOrdering;
});

var boundedInt = new Bounded(bottomInt, topInt);

var boundedOrdInt = new BoundedOrd(function () {
  return boundedInt;
}, function () {
  return ordInt;
});

var boundedChar = new Bounded(bottomChar, topChar);

var boundedOrdChar = new BoundedOrd(function () {
  return boundedChar;
}, function () {
  return ordChar;
});

var boundedBoolean = new Bounded(false, true);

var boundedOrdBoolean = new BoundedOrd(function () {
  return boundedBoolean;
}, function () {
  return ordBoolean;
});

var bottom = function (dict) {
  return dict.bottom;
};

var boundedFn = function (dictBounded) {
  return new Bounded(function (v) {
    return bottom(dictBounded);
  }, function (v) {
    return top(dictBounded);
  });
};

var booleanAlgebraUnit = new BooleanAlgebra(function () {
  return boundedUnit;
}, function (v) {
  return function (v1) {
    return unit;
  };
}, function (v) {
  return function (v1) {
    return unit;
  };
}, function (v) {
  return unit;
});

var booleanAlgebraFn = function (dictBooleanAlgebra) {
  return new BooleanAlgebra(function () {
    return boundedFn(dictBooleanAlgebra["__super__.prelude.Bounded"]());
  }, function (fx) {
    return function (fy) {
      return function (a) {
        return conj(dictBooleanAlgebra)(fx(a))(fy(a));
      };
    };
  }, function (fx) {
    return function (fy) {
      return function (a) {
        return disj(dictBooleanAlgebra)(fx(a))(fy(a));
      };
    };
  }, function (fx) {
    return function (a) {
      return not(dictBooleanAlgebra)(fx(a));
    };
  });
};

var booleanAlgebraBoolean = new BooleanAlgebra(function () {
  return boundedBoolean;
}, boolAnd, boolOr, boolNot);

var $div$eq = function (dictEq) {
  return function (x) {
    return function (y) {
      return not(booleanAlgebraBoolean)(eq(dictEq)(x)(y));
    };
  };
};

var bind = (dict) => dict.bind

var liftM1 = function (dictMonad) {
  return function (f) {
    return function (a) {
      return bind(dictMonad["__super__.prelude.Bind"]())(a)(function (v) {
        return pure(dictMonad["__super__.prelude.Applicative"]())(f(v));
      });
    };
  };
};

var asTypeOf = function (x) {
  return function (v) {
    return x;
  };
};

var applyFn = new Apply(function () {
  return functorFn;
}, function (f) {
  return function (g) {
    return function (x) {
      return f(x)(g(x));
    };
  };
});

var bindFn = new Bind(function () {
  return applyFn;
}, function (m) {
  return function (f) {
    return function (x) {
      return f(m(x))(x);
    };
  };
});

var apply = (dict) => dict.apply

var liftA1 = function (dictApplicative) {
  return function (f) {
    return function (a) {
      return apply(dictApplicative["__super__.prelude.Apply"]())(pure(dictApplicative)(f))(a);
    };
  };
};

var applicativeFn = new Applicative(function () {
  return applyFn;
}, _const);

var monadFn = new Monad(function () {
  return applicativeFn;
}, function () {
  return bindFn;
});

var append = (dict) => dict.append

var semigroupFn = function (dictSemigroup) {
  return new Semigroup(function (f) {
    return function (g) {
      return function (x) {
        return append(dictSemigroup)(f(x))(g(x));
      };
    };
  });
};

var ap = function (dictMonad) {
  return function (f) {
    return function (a) {
      return bind(dictMonad["__super__.prelude.Bind"]())(f)(function (v) {
        return bind(dictMonad["__super__.prelude.Bind"]())(a)(function (v1) {
          return pure(dictMonad["__super__.prelude.Applicative"]())(v(v1));
        });
      });
    };
  };
};

var monadArray = new Monad(function () {
  return applicativeArray;
}, function () {
  return bindArray;
});

var bindArray = new Bind(function () {
  return applyArray;
}, arrayBind);

var applyArray = new Apply(function () {
  return functorArray;
}, ap(monadArray));

var applicativeArray = new Applicative(function () {
  return applyArray;
}, function (x) {
  return [ x ];
});

var add = (dict) => dict.add

var preludeModule = {
  LT: LT,
  GT: GT,
  EQ: EQ,
  Show: Show,
  BooleanAlgebra: BooleanAlgebra,
  BoundedOrd: BoundedOrd,
  Bounded: Bounded,
  Ord: Ord,
  Eq: Eq,
  DivisionRing: DivisionRing,
  Num: Num,
  Ring: Ring,
  ModuloSemiring: ModuloSemiring,
  Semiring: Semiring,
  Semigroup: Semigroup,
  Monad: Monad,
  Bind: Bind,
  Applicative: Applicative,
  Apply: Apply,
  Functor: Functor,
  Category: Category,
  Semigroupoid: Semigroupoid,
  show: show,
  "||": disj,
  "&&": conj,
  not: not,
  disj: disj,
  conj: conj,
  bottom: bottom,
  top: top,
  unsafeCompare: unsafeCompare,
  ">=": $greater$eq,
  "<=": $less$eq,
  ">": $greater,
  "<": $less,
  compare: compare,
  "/=": $div$eq,
  "==": eq,
  eq: eq,
  "-": sub,
  negate: negate,
  sub: sub,
  "/": div,
  mod: mod,
  div: div,
  "*": mul,
  "+": add,
  one: one,
  mul: mul,
  zero: zero,
  add: add,
  "++": append,
  "<>": append,
  append: append,
  ap: ap,
  liftM1: liftM1,
  "return": pure,
  ">>=": bind,
  bind: bind,
  liftA1: liftA1,
  pure: pure,
  "<*>": apply,
  apply: apply,
  "void": _void,
  "<#>": $less$hash$greater,
  "<$>": $less$dollar$greater,
  map: map,
  id: id,
  ">>>": $greater$greater$greater,
  "<<<": $less$less$less,
  compose: compose,
  otherwise: true,
  asTypeOf: asTypeOf,
  "const": _const,
  flip: flip,
  "#": $hash,
  "$": $dollar,
  unit: unit,
  semigroupoidFn: semigroupoidFn,
  categoryFn: categoryFn,
  functorFn: functorFn,
  functorArray: functorArray,
  applyFn: applyFn,
  applyArray: applyArray,
  applicativeFn: applicativeFn,
  applicativeArray: applicativeArray,
  bindFn: bindFn,
  bindArray: bindArray,
  monadFn: monadFn,
  monadArray: monadArray,
  semigroupString: semigroupString,
  semigroupUnit: semigroupUnit,
  semigroupFn: semigroupFn,
  semigroupOrdering: semigroupOrdering,
  semigroupArray: semigroupArray,
  semiringInt: semiringInt,
  semiringNumber: semiringNumber,
  semiringUnit: semiringUnit,
  ringInt: ringInt,
  ringNumber: ringNumber,
  ringUnit: ringUnit,
  moduloSemiringInt: moduloSemiringInt,
  moduloSemiringNumber: moduloSemiringNumber,
  moduloSemiringUnit: moduloSemiringUnit,
  divisionRingNumber: divisionRingNumber,
  divisionRingUnit: divisionRingUnit,
  numNumber: numNumber,
  numUnit: numUnit,
  eqBoolean: eqBoolean,
  eqInt: eqInt,
  eqNumber: eqNumber,
  eqChar: eqChar,
  eqString: eqString,
  eqUnit: eqUnit,
  eqArray: eqArray,
  eqOrdering: eqOrdering,
  ordBoolean: ordBoolean,
  ordInt: ordInt,
  ordNumber: ordNumber,
  ordString: ordString,
  ordChar: ordChar,
  ordUnit: ordUnit,
  ordArray: ordArray,
  ordOrdering: ordOrdering,
  boundedBoolean: boundedBoolean,
  boundedUnit: boundedUnit,
  boundedOrdering: boundedOrdering,
  boundedInt: boundedInt,
  boundedChar: boundedChar,
  boundedFn: boundedFn,
  boundedOrdBoolean: boundedOrdBoolean,
  boundedOrdUnit: boundedOrdUnit,
  boundedOrdOrdering: boundedOrdOrdering,
  boundedOrdInt: boundedOrdInt,
  boundedOrdChar: boundedOrdChar,
  booleanAlgebraBoolean: booleanAlgebraBoolean,
  booleanAlgebraUnit: booleanAlgebraUnit,
  booleanAlgebraFn: booleanAlgebraFn,
  showBoolean: showBoolean,
  showInt: showInt,
  showNumber: showNumber,
  showChar: showChar,
  showString: showString,
  showUnit: showUnit,
  showArray: showArray,
  showOrdering: showOrdering
};
