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
{BrowserWindow, ipcMain} = require 'electron'
app = require "app"
crashReporter = require 'crash-reporter'
electron = require 'electron'
localShortcut = require 'electron-localshortcut'

AppOptions = require './tools/options'

ApplicationWindow = require './ApplicationWindow'
appMenu = require './menu/appMenu'
Menu = require 'menu'
Tools = require './tools'
Database = require './tools/src/database'

yargs = require 'yargs'
path = require 'path'

fs = require 'fs'
mkdirp = require 'mkdirp'
_ = require 'lodash'

ipcHelpers = require '../ipcHelpers'

{Emitter,Disposable} = require 'event-kit'
# ---------------------------
#
# ---------------------------
process.on('uncaughtException',(err) -> console.log err)

module.exports =
class Application
  window: null,
  loginWindow: null,
  tools: null
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
    _self = this
    app.on 'window-all-closed', ->
       app.quit()
    app.on 'ready', =>
       if @firstLaunch
         @openLoginWindow()
       else
         @openWindow()



       @registerShortcuts()
       @setupLogServer()


       @logDebug("Initializing...")

       @tools = new Tools()
       @tools.init( -> )


    ipcMain.on 'get-options', (event) ->
      event.sender.send 'get-options-response', AppOptions
    ipcMain.on 'get-user-info',(event) ->
      getUserCb = (user) ->
        application.logDebug "Querying user database..."
        event.sender.send 'get-user-info-response',user
      Database.getUser getUserCb


    ipcMain.on 'call-window-method', (event,method,args...) =>
      win = BrowserWindow.fromWebContents(event.sender)
      win[method](args...)

    ipcMain.on 'request-animelist', (event,user,args...) =>
      application.logDebug("IPC: request-animelist")

      reqAnimeListCb = (response) =>
        #To-do implement error
        if response.success
          list = response.list.myanimelist
          delete list.myinfo
          Database.saveList 'anime',list

          event.sender.send 'request-animelist-response',list

      @tools.getAnimelistOfUser user.userName, reqAnimeListCb

    ipcMain.on 'db-request-animelist', (event,user,args...) =>
      application.logDebug("IPC: db-request-animelist")

      dbReqAnimeListCb = (response) =>
        event.sender.send 'request-animelist-response',response

      Database.loadAnimelist dbReqAnimeListCb

    ipcMain.on 'set-user-login', (event,data) =>
      application.logDebug("IPC: set-user-login")

      @tools.login data.user,data.pass, (response) =>
        application.logDebug("Login: " + response.success)
        if response.success
          application.logDebug("Loading...")
          Database.addUser { userName: data.user, password: data.pass }


          @LoginWindow.close()
          @LoginWindow = null

          @openWindow()


        else
          application.logDebug("Error: " + response.errorMessage)
          event.sender.send('set-user-login-response',response)


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
    @chiikaHome = path.join(app.getPath('appData'),"chiika")
    @chiikaLog = path.join(app.getPath('appData'),"Logs")
    process.env.CHIIKA_HOME = @chiikaHome
    process.env.CHIIKA_LOG_HOME ?= @chiikaLog

    configFilePath = path.join(path.join(@chiikaHome, "Config"),"Chiika.json");

    mkdirp(path.join(@chiikaHome, "Config"), ->)
    mkdirp(path.join(@chiikaHome, "Data"), ->)

    try
      configFile = fs.statSync configFilePath
    catch e
      configFile = undefined

    if _.isUndefined configFile
      fs.openSync configFilePath, 'w'

      fs.writeFileSync configFilePath,JSON.stringify(AppOptions),'utf-8'

      @firstLaunch = true
    else
      configFile = fs.readFileSync configFilePath, 'utf-8'
      @firstLaunch = false

      AppOptions = JSON.parse(configFile)



  parseCommandLine: ->
    options = yargs(process.argv[1..]).wrap(100)
    args = options.argv
  registerShortcuts: ->
    #To-do

  openLoginWindow: ->
    options = {
       frame:false,
       width:800,
       height:600,
       icon:'./resources/icon.png'
    }

    @LoginWindow = new BrowserWindow(options);
    @LoginWindow.loadURL("file://#{__dirname}/../renderer/MyAnimeListLogin.html")
    @LoginWindow.openDevTools()
  showMainWindow: ->
    @window.window.show()
    @window.window.restore()
  hideMainWindow: ->
    @window.window.minimize()
    @window.window.hide()

  openWindow: ->
    isBorderless = true
    windowUrl = "file://#{__dirname}/../renderer/index.html#Home"
    windowWidth = 1400
    windowHeight = 900
    htmlURL = windowUrl
    @window = new ApplicationWindow htmlURL,
      width: windowWidth
      height: windowHeight
      minWidth:900
      minHeight:600
      title: 'Chiika - Development Mode'
      icon: "./resources/icon.png"
      frame:!isBorderless
    @window.openDevTools()

    @window.window.webContents.on 'did-finish-load', =>
      @window.window.webContents.send('window-reload')





application = new Application
