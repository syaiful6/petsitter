isValidString = (param) ->
  typeof param == 'string' and param.length > 0

startsWith = (start, string) ->
  string[0] == start

isSelector = (param) ->
  isValidString(param) and (startsWith('.', param) or startsWith('#', param))

element = (h) -> (tagName, attrs, children) ->
  props = attrs.reduce (obj, attr) ->
    key = attr[0]
    val = attr[1]
    obj[key] = val
    obj
  , {}
  h(tagName, props, children)

node = (h) -> (tagName) -> (first, rest...) ->
  elem = element(h)
  if isSelector(first) then elem(tagName + first, rest...) else elem(tagName, first, rest...)

TAG_NAMES = [
  'a', 'abbr', 'address', 'area', 'article', 'aside', 'audio', 'b', 'base',
  'bdi', 'bdo', 'blockquote', 'body', 'br', 'button', 'canvas', 'caption',
  'cite', 'code', 'col', 'colgroup', 'dd', 'del', 'dfn', 'dir', 'div', 'dl',
  'dt', 'em', 'embed', 'fieldset', 'figcaption', 'figure', 'footer', 'form',
  'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'head', 'header', 'hgroup', 'hr', 'html',
  'i', 'iframe', 'img', 'input', 'ins', 'kbd', 'keygen', 'label', 'legend',
  'li', 'link', 'main', 'map', 'mark', 'menu', 'meta', 'nav', 'noscript',
  'object', 'ol', 'optgroup', 'option', 'p', 'param', 'pre', 'q', 'rp', 'rt',
  'ruby', 's', 'samp', 'script', 'section', 'select', 'small', 'source', 'span',
  'strong', 'style', 'sub', 'sup', 'table', 'tbody', 'td', 'textarea', 'tfoot',
  'th', 'thead', 'title', 'tr', 'u', 'ul', 'video'
]

module.exports = (h) ->
  createTag = node h
  exported =
    TAG_NAMES: TAG_NAMES
    isSelector: isSelector
    createTag: createTag

  for tag in TAG_NAMES
    exported[tag] = createTag tag

  exported
