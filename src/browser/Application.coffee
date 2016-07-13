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
{BrowserWindow, ipcMain,globalShortcut,Tray,Menu} = require 'electron'
app = require "app"
crashReporter = require 'crash-reporter'
electron = require 'electron'
localShortcut = require 'electron-localshortcut'

AppOptions = require './tools/options'

ApplicationWindow = require './ApplicationWindow'
appMenu = require './menu/appMenu'
Tools = require './tools'
Database = require './tools/src/database'

yargs = require 'yargs'
path = require 'path'

fs = require 'fs'
mkdirp = require 'mkdirp'
_ = require 'lodash'
_when = require 'when'

ipcHelpers = require '../ipcHelpers'
MediaDetect = require('./tools/src/media-detect-win32')

{Emitter,Disposable} = require 'event-kit'

keypress = require 'keypress'
menubar = require 'menubar'
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

    @mediaDetector = new MediaDetect()
    @mediaDetector.spawn()


    # Report crashes to our server.
    require('crash-reporter').start()

    @parseCommandLine()
    @setupChiikaConfig()

    @handleEvents()

    @mb = menubar( icon:'./resources/icon.png',tooltip:'hhueheuehu',index:"file://#{__dirname}/../renderer/Menubar.html" )
    trayCm = Menu.buildFromTemplate([
      { label:'Hue'},
      { label:'Hue'},
      { label:'Hue'},
      { label:'Hue'}
      ])
    @mb.on 'after-create-window', =>
      @mb.window.openDevTools()


      @emitter.on 'mp-found',(mp) =>
        @mb.window.webContents.send 'mp-found',mp

      @emitter.on 'mp-video-changed', (mp) =>
        @mb.window.webContents.send 'mp-video-changed',mp

      @emitter.on 'mp-closed', (mp) =>
        @mb.window.webContents.send 'mp-closed',mp

    @mb.on 'ready', =>
      @mb.tray.setContextMenu(trayCm);
    # Quit when all windows are closed.


  handleEvents: ->
    _self = this
    @emitter.on 'anime-db-ready', ->
      #Do something
    app.on 'window-all-closed', ->
      app.quit()

    app.on 'will-quit', () ->
      globalShortcut.unregisterAll()
    app.on 'ready', =>
      @registerShortcuts()
      @setupLogServer()


      @logInfo("Initializing...")

      dbReady = =>
        if @firstLaunch
         @openLoginWindow()
        else
         @openWindow()

         #Here, user exists and the user data is loaded. Do anything concerning user data here

         #Check if user image exists,otherwise make a request to download
         userImagePath = @tools.checkIfFileExists 'Data/Images/' + @loggedUser.userId + '.jpg'

         if !userImagePath
           @downloadUserImage @loggedUser.userId

      @tools = new Tools()
      @tools.init( =>
        getUserCb = (user) =>
          if _.isUndefined user
            @firstLaunch = true
            application.logInfo "User info doesn't exist,forcing login."
          @loggedUser = user

          searchAnimeCb = (r) ->
            console.log r.anime.entry
          #@tools.searchAnime @loggedUser,'bleach',searchAnimeCb
          dbReady()
        Database.getUser getUserCb
        )


      globalShortcut.register 'F10', () =>
         if @window.window.isDevToolsOpened()
           @window.window.closeDevTools()
         else
           @window.window.openDevTools()


    ipcMain.on 'request-current-video', (event) =>
      event.sender.send 'request-current-video-response',@mediaDetector.currentVideoFile

    ipcMain.on 'save-options', (event,options) =>
      AppOptions = options
      @saveOptions()
    ipcMain.on 'get-options', (event) ->
      event.sender.send 'get-options-response', AppOptions
    ipcMain.on 'get-user-info',(event) ->
      getUserCb = (user) ->
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
          Database.saveList 'animeList',list

          event.sender.send 'request-animelist-response',list

      @tools.getAnimelistOfUser @loggedUser.userName, reqAnimeListCb

    ipcMain.on 'db-request-anime', (event,user,args...) =>
      application.logDebug("IPC: db-request-anime")

      dbReqAnimeCb = (response) =>
        event.sender.send 'request-animedb-response',response
      Database.loadAnimeDb dbReqAnimeCb


    ipcMain.on 'db-request-animelist', (event,user,args...) =>
      application.logDebug("IPC: db-request-animelist")

      if !@tools.checkIfFileExists 'Data/animeList.nosql'
        application.logInfo "Anime file is requested but it doesn't exist.Fixing that..."
        reqAnimeListCb = (response) =>

          dbSaved = ->
            application.logInfo "Sending (Main -> Renderer) request-animelist-response"
            event.sender.send 'request-animelist-response',list

            dbReqAnimeCb = (animeDbResponse) =>
              event.sender.send 'request-animedb-response',animeDbResponse
            Database.loadAnimeDb dbReqAnimeCb

          #To-do implement error
          if response.success
            application.logInfo "db-request-animelist getAnimelistOfUser is successful with code " + response.statusCode
            list = response.list.myanimelist
            delete list.myinfo
            Database.saveList 'animeList',list,dbSaved

        @tools.getAnimelistOfUser @loggedUser.userName , reqAnimeListCb
      else
        dbReqAnimeListCb = (response) =>
          event.sender.send 'request-animelist-response',response

          #Temporary
          #Database.saveList 'animeList',response,->

        Database.loadAnimelist dbReqAnimeListCb

    ipcMain.on 'set-user-login', (event,data) =>
      application.logDebug("IPC: set-user-login")

      @tools.login data.user,data.pass, (response) =>
        application.logInfo("Login: " + response.success)
        if response.success
          Database.addUser { userName: data.user, password: data.pass,userId: response.user.id }
          @loggedUser = { userName: data.user, password: data.pass,userId: response.user.id }

          @LoginWindow.close()
          @LoginWindow = null

          @openWindow().then( =>
            @downloadUserImage response.user.id
            )


        else
          application.logInfo("Error: " + response.errorMessage)
          event.sender.send('set-user-login-response',response)


  downloadUserImage: (id) ->
    onFinished = =>
      @window.window.webContents.send('download-image')
      application.logInfo "User image download has finished."
    @tools.downloadUserImage id,onFinished

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
    console.addLogger('info','blue')

    port = eapp.get("port")

    eapp.listen port,->
      console.time().log('Server listening at port ' + port)
  logDebug:(text) ->
    process.console.tag("chiika-browser").time().debug(text)
  logInfo: (text) ->
    process.console.tag("chiika-browser").time().info(text)
  setupChiikaConfig: ->
    @chiikaHome = path.join(app.getPath('appData'),"chiika")
    @chiikaLog = path.join(app.getPath('appData'),"Logs")
    process.env.CHIIKA_HOME = @chiikaHome
    process.env.CHIIKA_LOG_HOME ?= @chiikaLog

    configFilePath = path.join(path.join(@chiikaHome, "Config"),"Chiika.json");

    mkdirp(path.join(@chiikaHome, "Config"), ->)
    mkdirp(path.join(@chiikaHome, "Data"), ->)
    mkdirp(path.join(@chiikaHome, "Data","Images"), ->)

    try
      configFile = fs.statSync configFilePath
    catch e
      configFile = undefined

    if _.isUndefined configFile
      fs.openSync configFilePath, 'w'

      AppOptions.Version = process.env.version

      fs.writeFileSync configFilePath,JSON.stringify(AppOptions),'utf-8'

      @firstLaunch = true
    else
      configFile = fs.readFileSync configFilePath, 'utf-8'
      @firstLaunch = false

      AppOptions = JSON.parse(configFile)

      packageVersion = process.env.version
      appVersion = AppOptions.Version

      if appVersion? && packageVersion != appVersion
        @firstLaunch = true
        AppOptions.Version = packageVersion
        @saveOptions()




  saveOptions: ->
    configFilePath = path.join(path.join(@chiikaHome, "Config"),"Chiika.json");
    fs.writeFileSync configFilePath,JSON.stringify(AppOptions),'utf-8'
  parseCommandLine: ->
    options = yargs(process.argv[1..]).wrap(100)
    args = options.argv
  registerShortcuts: ->
    #To-do
  getScreenRes: ->
    {width, height} = electron.screen.getPrimaryDisplay().workAreaSize
    return { width: width, height: height}

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
    deferred = _when.defer()
    isBorderless = true
    windowUrl = "file://#{__dirname}/../renderer/index.html#Home"
    screenRes = @getScreenRes()
    windowWidth = Math.round(screenRes.width * 0.66)
    windowHeight = Math.round(screenRes.height * 0.75)
    htmlURL = windowUrl
    @window = new ApplicationWindow htmlURL,
      width: windowWidth
      height: windowHeight
      title: 'Chiika - Development Mode'
      icon: "./resources/icon.png"
      frame:!isBorderless
    @window.openDevTools()

    @window.window.webContents.on 'did-finish-load', =>
      @window.window.webContents.send('window-reload')

      @window.enableReactDevTools()
      deferred.resolve()
    deferred.promise





application = new Application
