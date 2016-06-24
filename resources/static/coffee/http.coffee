Maybe = require './data/maybe'
Either = require './data/either'
scheduler = require './core/scheduler'
task = require './core/task'
{tagged, taggedSum} = require './core/tagged'
{curry, compose} = require './core/lambda'
{fromArray} = require './core/data/list'

# construct a query string.
# url "http://github.com", [['name', 'syaiful']] -> http://github.com?name=syaiful
# url :: String -> [String, String] -> String
url = curry (base, args) ->
  return base if args.length == 0
  base + '?' + (args.map(queryPair)).join('&')

queryPair = (item) ->
  [key, value] = item
  encodeURIComponent(key) + '=' + encodeURIComponent(value)

Request = curry (a, b, c, d) ->
  {
    verb: a
    headers: b
    url: c
    body: d
  }

Body = taggedSum {
  BodyString: ['value0']
  BodyBlob: ['value0']
  Empty: []
  ArrayBuffer: []
  BodyFormData: ['formData']
}

# empty :: Body
empty = Body.Empty

# bodyString :: String -> Body
bodyString = Body.BodyString

Data = taggedSum {
  StringData: ['value0', 'value1']
  BlobData: ['value0', 'value1', 'value2']
  FileData: ['value0', 'value1', 'value2']
}

# multipart : List Data -> Body
multipart = (dataList) ->
  if Array.isArray(dataList)
    dataList = fromArray(dataList)
  # construct the form data
  formData = new FormData()
  until dataList.ctor == '[]'
    data = dataList.value0
    if data instanceof StringData
      formData.append data.value0, data.value1
    else
      fileName = if Maybe.isNothing(data.value1) then undefined else data.value1.value0
      formData.append(data.value0, data.value2, fileName)
    dataList = dataList.value1
  Body.BodyFormData formData

# stringData :: String -> String -> Data
stringData = curry.to 2, Data.StringData

# blobData :: String -> Maybe String -> Blob -> Data
blobData = curry.to 3, Data.BlobData

Settings = curry (a, b, c, d, e) ->
  {
    timeout: a
    onStart: b
    onProgress: c
    desiredResponseType: d
    withCredentials: e
  }

defaultSettings =
  timeout: 0
  onStart: Nothing
  onProgress: Nothing
  desiredResponseType: Maybe.Nothing()
  withCredentials: false

Response = curry (a, b, c, d, e) ->
  {
    status: a
    statusText: b
    headers: c
    url: d
    value: e
  }

Value = taggedSum {
  Text: ['value0'],
  Blob: ['value0']
}

RawError = taggedSum {
  RawTimeout: []
  RawNetworkError: []
}

HttpError = taggedSum {
  Timeout: []
  NetworkError: []
  UnexpectedPayload: ['value0']
  BadResponse: ['value0']
}

# send :: Settings -> Request -> Task RawError Response
send = curry (settings, request) ->
  scheduler.nativeBinding (callback) ->
    req = new XMLHttpRequest()
    if Maybe.isJust(settings.onStart)
      req.addEventListener 'loadStart', ->
        job = settings.onStart.value0
        scheduler.rawSpawn job
        return
    if Maybe.isJust(settings.onProgress)
      req.addEventListener 'progress', (event) ->
        if event.lengthComputable
          progress = Maybe.Just({loaded: event.loaded, total: event.total})
        else
          progress = Maybe.Nothing()
        job = settings.onProgress.value0(progress)
        scheduler.rawSpawn job
        return

    req.addEventListener 'error', ->
      callback scheduler.fail(RawError.RawNetworkError)

    req.addEventListener 'timeout', ->
      callback scheduler.fail(RawError.RawTimeout)

    req.addEventListener 'load', ->
      callback scheduler.succeed(toResponse(req))

    req.open(request.verb, request.url, true)

    if request.headers
      headers = request.headers
      req.setRequestHeader(k, headers[k]) for own k of headers

    req.timeout = settings.timeout
    req.withCredentials = settings.withCredentials

    if Maybe.isJust(settings.desiredResponseType)
      req.overrideMimeType(settings.desiredResponseType.value0)

    if request.body instanceof Body.BodyFormData
      req.send(request.body.formData)
    else
      req.send(request.body.value0)

    ->
      req.abort()

toResponse = (req) ->
  tag = if req.responseType == 'Blob' then 'Blob' else 'Text'
  val = if tag == 'Blob' then Value.Blob(req.response) else Value.Text(req.responseText)
  headers = parseHeaders(req.getAllResponseHeaders())
  Response req.status, req.statusText, headers, req.responseURL, val

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
          headers[key] = Just(value + ', ' + oldValue.value0)
          continue
      headers[key] = Just(value)
  headers

handleResponse = curry (handle, response) ->
  if 200 <= response.status < 300
    val = response.value
    if val instanceof Value.Text
      handle val.value0
    else
      scheduler.fail HttpError.UnexpectedPayload("Response body is a blob, expecting a string.")
  else
    scheduler.fail HttpError.BadResponse(response.status, response.statusText)

promoteError = (rawError) ->
  if rawError == RawError.RawTimeout then HttpError.Timeout else HttpError.NetworkError

getRaw = (url) ->
  request =
    verb: 'GET'
    headers: {}
    url: url
    body: empty
  res = send defaultSettings, request
  scheduler.andThen task.mapError(promoteError, res), handleResponse(task.succeed)

fromJson = curry (decoder, response) ->
  decode = compose Either.either(task.fail, task.succeed), compose(decoder, JSON.parse)
  scheduler.andThen task.mapError(promoteError, response), handleResponse(decode)

get = curry (decoder, url) ->
  request =
    verb: 'GET'
    headers: {}
    url: url
    body: empty
  fromJson decoder, send(defaultSettings, request)

post = curry (decoder, url, body) ->
  request =
    verb: 'POST'
    headers: {}
    url: url
    body: body
  fromJson decoder, send(defaultSettings, request)

module.exports =
  url: url
  queryPair: queryPair
  get: get
  post: post
  getRaw: getRaw
  fromJson: fromJson
  send: send
  multipart: multipart
  Request: Request
  Response: Response
  Body: Body
  empty: empty
  bodyString: bodyString
  Settings: Settings
  defaultSettings: defaultSettings
  Value: Value
  HttpError: HttpError
  RawError: RawError
