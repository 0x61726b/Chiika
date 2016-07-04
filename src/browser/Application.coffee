#----------------------------------------------------------------------------
#Chiika
#Copyright (C) 2016 arkenthera
#This program is free software; you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation; either version 2 of the License, or
#(at your option) any later version.
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#Date: 23.1.2016
#authors: arkenthera
#Description:
#----------------------------------------------------------------------------
#
#
#--------------------
#
#--------------------
app = require "app"
BrowserWindow = require 'browser-window'
crashReporter = require 'crash-reporter'
electron = require 'electron'
ipc = electron.ipcMain
localShortcut = require 'electron-localshortcut'



ApplicationWindow = require './ApplicationWindow'
appMenu = require './menu/appMenu'
Menu = require 'menu'

yargs = require 'yargs'
path = require 'path'

fs = require 'fs'

{Emitter,Disposable} = require 'event-kit'
# ---------------------------
#
# ---------------------------
process.on('uncaughtException',(err) -> console.log err)

module.exports =
class Application
  window: null,
  loginWindow: null
  constructor: (options) ->
    global.application = this
    @emitter = new Emitter


    # Report crashes to our server.
    require('crash-reporter').start()

    @parseCommandLine()
    @setupChiikaConfig()

    @handleEvents()
    # Quit when all windows are closed.


  handleEvents: ->
    app.on 'window-all-closed', ->
       app.quit()
    app.on 'ready', =>
       @openWindow()
       @registerShortcuts()
       @setupLogServer()


       @logDebug("Initializing...")

  setupLogServer: ->
    scribe = require 'scribe-js'
    express = require 'express'

    scribe = scribe()
    console = process.console
    eapp = express()

    eapp.set('port',(process.env.PORT || 5000))
    eapp.get '/', (req,res) ->
      res.send 'hello,world'

    eapp.use '/logs',scribe.webPanel()

    console.addLogger('debug','red')

    port = eapp.get("port")

    eapp.listen port,->
      console.time().log('Server listening at port ' + port)
  logDebug:(text) ->
    process.console.tag("chiika-browser").time().debug(text)

  setupChiikaConfig: ->
    chiikaHome = path.join(app.getPath('appData'),"chiika")
    chiikaLog = path.join(app.getPath('appData'),"Logs")
    process.env.CHIIKA_HOME = chiikaHome
    process.env.CHIIKA_LOG_HOME ?= chiikaLog
  parseCommandLine: ->
    options = yargs(process.argv[1..]).wrap(100)
    args = options.argv
  registerShortcuts: ->
    #To-do

  openLoginWindow: ->
    options = {
       frame:false,
       width:600,
       height:600,
       icon:'./resources/icon.png'
    }
    LoginWindow = new BrowserWindow(options);
    console.log "file://#{__dirname}/../renderer/MyAnimeListLogin.html"
    LoginWindow.loadURL("file://#{__dirname}/../renderer/MyAnimeListLogin.html")
    LoginWindow.openDevTools()
  openWindow: ->
    isBorderless = true

    if process.env.Show_CA_Debug_Tools == 'yeah'
      isBorderless = false;
    htmlURL = "file://#{__dirname}/../renderer/index.html#Home"
    @window = new ApplicationWindow htmlURL,
      width: 1400
      height: 900
      minWidth:900
      minHeight:600
      title: 'Chiika - Development Mode'
      icon: "./resources/icon.png"
      frame:!isBorderless
    @window.openDevTools()

    if process.env.Show_CA_Debug_Tools == 'yeah'
      Menu.setApplicationMenu(appMenu)





application = new Application
