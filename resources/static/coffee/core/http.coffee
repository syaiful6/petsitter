scheduler = require './scheduler'
task = require './task'
{Just, Nothing} = require './maybe'
{fromArray} = require './list'
functools = require '../utils/functools'

send = (settings, request) ->
  scheduler.nativeBinding (callback) ->
    req = new XMLHttpRequest()
    if settings.onStart.ctor == 'Just'
      req.addEventListener 'loadStart', ->
        job = settings.onStart._0
        scheduler.rawSpawn job
        return
    if settings.onProgress.ctor == 'Just'
      req.addEventListener 'progress', (event) ->
        if event.lengthComputable
          progress = Just({loaded: event.loaded, total: event.total})
        else
          progress = Nothing
        job = settings.onProgress._0(progress)
        scheduler.rawSpawn job
        return

    req.addEventListener 'error', ->
      callback scheduler.fail({ ctor: 'RawNetworkError' })

    req.addEventListener 'timeout', ->
      callback scheduler.fail({ ctor: 'RawTimeout' })

    req.addEventListener 'load', ->
      callback scheduler.succeed(toResponse(req))

    req.open(request.verb, request.url, true)

    if request.headers
      headers = request.headers
      req.setRequestHeader(k, headers[k]) for own k of headers

    req.timeout = settings.timeout
    req.withCredentials = settings.withCredentials

    if settings.desiredResponseType.ctor == 'Just'
      req.overrideMimeType(settings.desiredResponseType._0)

    if request.body.ctor == "BodyFormData"
      req.send(request.body.formData)
    else
      req.send(request.body._0)

    ->
      req.abort()

send = functools.curry2(send)

toResponse = (req) ->
  tag = if req.responseType == 'Blob' then 'Blob' else 'Text'
  response = if tag == 'Blob' then req.response else req.responseText

  status: req.status
  statusText: req.statusText
  headers: parseHeaders(req.getAllResponseHeaders())
  url: req.responseURL
  value: { ctor: tag, _0: response}

parseHeaders = (rawHeader) ->
  headers = {}
  return headers unless rawHeader
  headerPairs = rawHeaders.split('\u000d\u000a').slice().reverse()
  for pair in headerPairs
    index = pair.indexOf('\u003a\u0020')
    if index > 0
      key = pair.substring(0, index)
      value = headerPair.substring(index + 2)
      if key of headers
        oldVal = headers[key]
        if oldValue.ctor
          headers[key] = Just(value + ', ' + oldValue._0)
          continue
      headers[key] = Just(value)
  headers

multipart = (dataList) ->
  if Array.isArray(dataList)
    dataList = fromArray(dataList)
  # construct the form data
  formData = new FormData()
  until dataList.ctor == '[]'
    data = dataList._0
    if data.ctor == 'StringData'
      formData.append(data._0, data._1)
    else
      fileName = if data._1.ctor == 'Nothing' then undefined else data._1._0
      formData.append(data._0, data._2, fileName)
    dataList = dataList._1
  ctor: 'BodyFormData'
  formData: formData

Request = (a, b, c, d) ->
  verb: a
  headers: b
  url: c
  body: d

Request = functools.curry4 Request

Settings = (a, b, c, d, e) ->
  timeout: a
  onStart: b
  onProgress: c
  desiredResponseType: d
  withCredentials: e

Settings = functools.curry5 Settings

defaultSettings =
  timeout: 0
  onStart: Nothing
  onProgress: Nothing
  desiredResponseType: Nothing
  withCredentials: false

Response = (a, b, c, d, e) ->
  status: a
  statusText: b
  headers: c
  url: d
  value: e

Response = functools.curry5 Response

BodyBlob = (a) ->
  ctor: 'BodyBlob'
  _0: a

BodyFormData =
  ctor: 'BodyFormData'

ArrayBuffer =
  ctor: 'ArrayBuffer'

BodyString = (a) ->
  ctor: 'BodyString'
  _0: a

Empty =
  ctor: 'Empty'

# alias
empty = Empty

FileData = functools.curry3 (a, b, c) ->
  ctor: 'FileData'
  _0: a
  _1: b
  _2: c

BlobData = functools.curry3 (a, b, c) ->
  ctor: 'BlobData'
  _0: a
  _1: b
  _2: c

StringData = functools.curry2 (a, b) ->
  ctor: 'StringData'
  _0: a
  _1: b

Text = (a) ->
  ctor: 'Text'
  _0: a

RawNetworkError =
  ctor: 'RawNetworkError'

RawTimeout =
  ctor: 'RawTimeout'

BadResponse = (a) -> (b) ->
  ctor: 'BadResponse'
  _0: a
  _1: b

UnexpectedPayload = (a) ->
  ctor: 'UnexpectedPayload'
  _0: a

NetworkError =
  ctor: 'NetworkError'

Timeout =
  ctor: 'Timeout'

handleResponse = (handle) -> (response) ->
  if 200 <= response.status < 300
    val = response.value
    if val.ctor == 'Text'
      handle(val._0)
    else
      scheduler.fail(UnexpectedPayload("Response body is a blob, expecting a string."))
  else
    scheduler.fail(functools.invoke2(BadResponse, response.status, response.statusText))

promoteError = (rawError) ->
  val = rawError
  if val.ctor == 'RawTimeout'
    Timeout
  else
    NetworkError

getRaw = (url) ->
  request =
    verb: 'GET'
    headers: {}
    url: url
    body: empty
  res = send(defaultSettings)(request)
  functools.invoke2(scheduler.andThen, task.mapError(promoteError)(res), handleResponse(task.succeed))

fromJson = (decoder) -> (response) ->
  decode = (str) ->
    decoded = JSON.parse(str)
    result = decoder(decoded)
    if result.ctor == 'Ok'
      task.succeed(result._0)
    else
      task.fail(result._0)
  functools.invoke2(scheduler.andThen, task.mapError(promoteError)(response), handleResponse(decode))

get = (decoder) -> (url) ->
  request =
    verb: 'GET'
    headers: {}
    url: url
    body: empty
  res = send(defaultSettings)(request)
  fromJson(decoder)(res)

post = (decoder) -> (url) -> (body) ->
  request =
    verb: 'POST'
    headers: {}
    url: url
    body: body
  res = send(defaultSettings)(request)
  fromJson(decoder)(res)
