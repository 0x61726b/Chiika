
# electron = require 'electron'
# app = electron.app
# BrowserWindow = electron.BrowserWindow
app = require "app"
BrowserWindow = require 'browser-window'
crashReporter = require 'crash-reporter'

ApplicationWindow = require './ApplicationWindow'
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
      width: 1000,
      height: 800,
      minWidth:800,
      minHeight:600,
      title: 'Chiika - Development Mode',
      icon: __dirname + '/../../resources/icon.png'
    @window.openDevTools()


application = new Application
