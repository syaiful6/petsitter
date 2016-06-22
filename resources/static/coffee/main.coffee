app = require './app'
IO = require './data/io'

queryDOM = (selector) ->
  IO ->
    document.querySelector selector

mountApp = (dom) ->
  IO ->
    app.petsitter.embed dom
    dom

mount = (selector) ->
  queryDOM(selector).chain mountApp

# effect, mount the app on #app
mount('#app').unsafePerform()
