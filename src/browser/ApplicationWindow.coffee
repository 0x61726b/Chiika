BrowserWindow = require 'browser-window'

module.exports =
class ApplicationWindow
  window: null

  constructor: (path, options) ->
    @window = new BrowserWindow(options)
    @window.loadURL(path)

  on: (args...) ->
    @window.on(args...)
  openDevTools: () ->
    @window.openDevTools();
