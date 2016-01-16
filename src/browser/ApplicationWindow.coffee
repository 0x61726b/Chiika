BrowserWindow = require 'browser-window'

module.exports =
class ApplicationWindow
  window: null

  constructor: (path, options) ->
    @window = new BrowserWindow(options)
    @window.loadUrl(path)

  on: (args...) ->
    @window.on(args...)
