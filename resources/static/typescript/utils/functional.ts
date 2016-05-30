const slice = Array.prototype.slice;

function toArray(a: any[]): any[] {
  return slice.call(a);
}

function tail(a: any[]): any[] {
  return slice.call(a, 1);
}

function createFn(fn: Function, args: any[], totalArity: number): Function {
  return function (...params: any[]) {
    return processInvocation(fn, concatArgs(args, params), totalArity);
  };
}

function concatArgs(args1: any[], args2: any[]): any[] {
  return args1.concat(toArray(args2));
}

function createEvalFn(fn: Function, args: any[], arity: number): Function {
  var argList = makeArgList(arity);

  //-- hack for IE's faulty eval parsing -- http://stackoverflow.com/a/6807726
  var fnStr = 'false||' +
      'function(' + argList + '){ return processInvocation(fn, concatArgs(args, arguments)); }';
  return eval(fnStr);
}

var makeArgList: (len: number) => string = function(len) {
  var a = [];
  for (var i = 0; i < len; i += 1) a.push('a' + i.toString());
  return a.join(',');
};

function trimArrLength(arr: any[], length: number): any[] {
  if (arr.length > length) return arr.slice(0, length);
  else return arr;
};

function processInvocation(fn: Function, argsArr: any[], totalArity: number) {
  argsArr = trimArrLength(argsArr, totalArity);

  if (argsArr.length === totalArity) {
    return fn.apply(null, argsArr);
  }
  return createFn(fn, argsArr, totalArity);
};

function curry(fn: Function) {
  return createFn(fn, [], fn.length);
};

const to = curry(function(arity, fn) {
  return createFn(fn, [], arity);
});


const adaptTo = curry(function(num, fn) {
  return to(num, function(context) {
    let args = tail(slice.call(arguments, 0)).concat(context);
    return fn.apply(this, args);
  });
});

const adapt = function(fn) {
  return adaptTo(fn.length, fn);
};

export = {
  curry,
  to,
  adaptTo,
  adapt
}
