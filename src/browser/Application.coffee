
# electron = require 'electron'
# app = electron.app
# BrowserWindow = electron.BrowserWindow
app = require "app"
BrowserWindow = require 'browser-window'
crashReporter = require 'crash-reporter'

ApplicationWindow = require './ApplicationWindow'
client = require('electron-connect').client
# ---------------------------
#
# ---------------------------


module.exports =
class Application
  window: null

  constructor: (options) ->
    global.application = this

    # Report crashes to our server.
    require('crash-reporter').start()

    # Quit when all windows are closed.
    app.on 'window-all-closed', -> app.quit()
    app.on 'ready', => @openWindow()

  openWindow: ->
    htmlURL = "file://#{__dirname}/../renderer/index.html"
    @window = new ApplicationWindow htmlURL,
      width: 1200,
      height: 800

    client.create(@window)


application = new Application
