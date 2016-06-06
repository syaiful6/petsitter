var { guid } = require('../basic');

const MAX_STEP = 10000;

// Tasks
function succeed(value)  {
  return {
    ctor: '_Task_succeed',
    value
  };
}

function fail(error) {
  return {
    ctor: '_Task_error',
    value: error
  };
}

function receive(callback) {
  return {
    ctor: '_Task_receive',
    callback
  };
}

function nativeBinding(callback) {
  return {
    ctor: '_Task_nativeBinding',
    callback,
    cancel: null
  };
}

function andThen(task, callback) {
  return {
    ctor: '_Task_andThen',
    task,
    callback
  };
}

function onError(task, callback) {
  return {
    ctor: '_Task_onError',
    task,
    callback
  };
}

// process
function rawSpan(task) {
  var process = {
    ctor: '_Process',
    id: guid(),
    root: task,
    stack: null,
    mailbox: []
  };

  enqueue(process);

  return process;
}

function spawn(task) {
  return nativeBinding(function(callback) {
    var process = rawSpawn(task);
    callback(succeed(process));
  });
}

function rawSend(process, msg) {
  process.mailbox.push(msg);
  enqueue(process);
}

function send(process, msg)
{
  return nativeBinding(function(callback) {
    rawSend(process, msg);
    callback(succeed(_elm_lang$core$Native_Utils.Tuple0));
  });
}

function kill(process)
{
  return nativeBinding(function(callback) {
    var root = process.root;
    if (root.ctor === '_Task_nativeBinding' && root.cancel)
    {
      root.cancel();
    }

    process.root = null;

    callback(succeed(_elm_lang$core$Native_Utils.Tuple0));
  });
}

function sleep(time)
{
  return nativeBinding(function(callback) {
    var id = setTimeout(function() {
      callback(succeed(_elm_lang$core$Native_Utils.Tuple0));
    }, time);

    return function() { clearTimeout(id); };
  });
}


// STEP PROCESSES

function step(numSteps, process) {
  while (numSteps < MAX_STEPS) {
    var ctor = process.root.ctor;

    if (ctor === '_Task_succeed') {
      while (process.stack && process.stack.ctor === '_Task_onError') {
        process.stack = process.stack.rest;
      }
      if (process.stack === null) {
        break;
      }
      process.root = process.stack.callback(process.root.value);
      process.stack = process.stack.rest;
      ++numSteps;
      continue;
    }

    if (ctor === '_Task_fail') {
      while (process.stack && process.stack.ctor === '_Task_andThen') {
        process.stack = process.stack.rest;
      }
      if (process.stack === null) {
        break;
      }
      process.root = process.stack.callback(process.root.value);
      process.stack = process.stack.rest;
      ++numSteps;
      continue;
    }

    if (ctor === '_Task_andThen') {
      process.stack = {
        ctor: '_Task_andThen',
        callback: process.root.callback,
        rest: process.stack
      };
      process.root = process.root.task;
      ++numSteps;
      continue;
    }

    if (ctor === '_Task_onError') {
      process.stack = {
        ctor: '_Task_onError',
        callback: process.root.callback,
        rest: process.stack
      };
      process.root = process.root.task;
      ++numSteps;
      continue;
    }

    if (ctor === '_Task_nativeBinding') {
      process.root.cancel = process.root.callback(function(newRoot) {
        process.root = newRoot;
        enqueue(process);
      });

      break;
    }

    if (ctor === '_Task_receive') {
      var mailbox = process.mailbox;
      if (mailbox.length === 0) {
        break;
      }

      process.root = process.root.callback(mailbox.shift());
      ++numSteps;
      continue;
    }

    throw new Error(ctor);
  }

  if (numSteps < MAX_STEPS) {
    return numSteps + 1;
  }
  enqueue(process);

  return numSteps;
}


// WORK QUEUE

var working = false;
var workQueue = [];

function enqueue(process) {
  workQueue.push(process);

  if (!working) {
    setTimeout(work, 0);
    working = true;
  }
}

function work() {
  var numSteps = 0;
  var process;
  while (numSteps < MAX_STEPS && (process = workQueue.shift())) {
    numSteps = step(numSteps, process);
  }
  if (!process) {
    working = false;
    return;
  }
  setTimeout(work, 0);
}
