{ guid, Tuple0 } = require '../utils/common'
{ curry2 } = require '../utils/functools'

MAX_STEPS = 10000

succeed = (val) ->
  ctor: '_Task_succeed'
  value: val

fail = (error) ->
  ctor: '_Task_fail'
  value: error

nativeBinding = (callback) ->
  ctor: '_Task_nativeBinding'
  callback: callback
  cancel: null

andThen = (task, callback) ->
  ctor: '_Task_andThen'
  task: task
  callback: callback

onError = (task, callback) ->
  ctor: '_Task_onError'
  callback: callback

receive = (callback) ->
  ctor: '_Task_receive'
  callback: callback

rawSpawn = (task) ->
  process =
    ctor: '_Process'
    id: guid()
    root: task
    stack: null
    mailbox: []

  enqueue process
  process

spawn = (task) ->
  nativeBinding (callback) ->
    process = rawSpawn task
    callback(succeed(process))

rawSend = (process, msg) ->
  process.mailbox.push(msg)
  enqueue process

send = (process, msg) ->
  nativeBinding (callback) ->
    rawSend(process, msg)
    callback(succeed(Tuple0))

kill = (process) ->
  nativeBinding (callback) ->
    root = process.root
    root.cancel() if root.ctor == '_Task_nativeBinding' && root.cancel
    process.root = null
    callback(succeed(Tuple0))

sleep = (time) ->
  nativeBinding (callback) ->
    id = setTimeout ->
      callback(succeed(Tuple0))
    , time

    -> clearTimeout(id)

step = (numSteps, process) ->
  while numSteps < MAX_STEPS
    ctor = process.root.ctor
    if ctor == '_Task_succeed'
      while process.stack and process.stack.ctor == '_Task_onError'
        process.stack = process.stack.rest
      break if process.stack == null
      process.root = process.stack.callback(process.root.value)
      process.stack = process.stack.rest
      ++numSteps
      continue
    if ctor == '_Task_fail'
      while process.stack and process.stack.ctor == '_Task_andThen'
        process.stack = process.stack.rest
      break if process.stack == null
      process.root = process.stack.callback(process.root.value)
      process.stack = process.stack.rest
      ++numSteps
      continue
    if ctor == '_Task_andThen'
      process.stack =
        ctor: '_Task_andThen'
        callback: process.root.callback
        rest: process.stack
      process.root = process.root.task
      ++numSteps
      continue
    if ctor == '_Task_onError'
      process.stack =
        ctor: '_Task_onError'
        callback: process.root.callback
        rest: process.stack
      process.root = process.root.task
      ++numSteps
      continue
    if ctor == '_Task_nativeBinding'
      process.root.cancel = process.root.callback (newRoot) ->
        process.root = newRoot
        enqueue process
      break
    if ctor == '_Task_receive'
      mailbox = process.mailbox
      break if mailbox.length == 0
      process.root = process.root.callback(mailbox.shift())
      ++numSteps
      continue
    throw new Error ctor

  return numSteps + 1 if numSteps < MAX_STEPS

  enqueue process
  numSteps

working = false
workQueue = []

enqueue = (process) ->
  workQueue.push process
  unless working
    setTimeout work, 0
    working = true

work = ->
  numSteps = 0
  process = null
  while numSteps < MAX_STEPS and (process = workQueue.shift())
    numSteps = step(numSteps, process)
  unless process
    working = false
    return
  setTimeout work, 0

module.exports =
  succeed: succeed
  fail: fail
  nativeBinding: nativeBinding
  andThen: curry2(andThen)
  onError: curry2(onError)
  receive: receive
  spawn: spawn
  kill: kill
  sleep: sleep
  send: curry2(send)
  rawSpawn: rawSpawn
  rawSend: rawSend
