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
menubar = require './menubar'
# ---------------------------
#
# ---------------------------
process.on('uncaughtException',(err) -> console.log err)

module.exports =
class Application
  window: null,
  loginWindow: null,
  tools: null,
  mbReady: false
  constructor: (options) ->
    global.application = this
    @emitter = new Emitter

    @mediaDetector = new MediaDetect()
    @mediaDetector.spawn()

    app.commandLine.appendSwitch 'js-flags','expose_gc'




    # Report crashes to our server.
    require('crash-reporter').start()


    @parseCommandLine()
    @setupChiikaConfig()

    @handleEvents()

    Menubar = new menubar()


    @mb = Menubar.create( icon:'./resources/icon.png',
    tooltip:'hhueheuehu',
    index:"file://#{__dirname}/../renderer/Menubar.html",
    preloadWindow: true,
    width: 389,
    height: 190
     )
    trayCm = Menu.buildFromTemplate([
      { label:'Hue'},
      { label:'Hue'},
      { label:'Hue'},
      { label:'Hue'}
      ])
    @mb.on 'after-create-window', =>
      @mb.window.openDevTools()
      @mbReady = true

    @mb.on 'ready', =>
      @mb.tray.setContextMenu(trayCm);

      @mb.tray.on 'double-click',(event,bounds) =>
        @window.showWindow()

  handleEvents: ->
    _self = this
    app.on 'window-all-closed', ->
      app.quit()

    app.on 'will-quit', () ->
      globalShortcut.unregisterAll()
    app.on 'ready', =>
      @registerShortcuts()
      @setupLogServer()


      @logInfo("Initializing...")

      @checkRememberWindowProperties()

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


      # globalShortcut.register 'F10', () =>
      #    if @window.window.isDevToolsOpened()
      #      @window.window.closeDevTools()
      #    else
      #      @window.window.openDevTools()


    ipcMain.on 'request-calendar-data', (event,args) =>
      application.logDebug("IPC: request-calendar-data")
      Database.loadSenpaiData((data) ->
        event.sender.send 'request-calendar-data-response', { calendarData: data }
        )
    ipcMain.on 'request-anime-cover-image-download', (event,args) =>
      application.logDebug("IPC: request-anime-cover-image-download")

      @tools.downloadAnimeCover args.coverLink,args.animeId, (response) ->
        event.sender.send 'request-anime-cover-image-download-response', { animeId: args.animeId }


    ipcMain.on 'request-anime-details-small', (event,args) =>
      application.logDebug("IPC: request-anime-details-small")

      @requestAnimeDetailsSmall args.animeId, (completed) =>
        event.sender.send 'request-anime-details-small-response', completed
      # @tools.animeDetailsSmall args.animeId, (response) ->
      #   animeDetails = { series_animedb_id: args.animeId }
      #   _.assign animeDetails,response.animeDetails
      #   Database.updateAnimeEntrySmall animeDetails,->
      #
      #     dbAnimeCb = (data) ->
      #       event.sender.send 'request-anime-details-small-response', {newDb: data, updatedEntry: animeDetails}
      #     Database.loadAnimeDb dbAnimeCb

    ipcMain.on 'request-anime-details-mal-page', (event,args) =>
      application.logDebug("IPC: request-anime-details-mal-page")

      @requestAnimeDetailsMalPage args.animeId, (completed) =>
        event.sender.send 'request-anime-details-mal-page-response', completed
      # @tools.animeDetailsMalPage args.animeId, (response) ->
      #   animeDetails = { series_animedb_id: args.animeId }
      #   _.assign animeDetails, response.animeDetails
      #   Database.updateAnimeEntryMalPage animeDetails, (dbResponse) ->
      #     if dbResponse.updated
      #       dbAnimeCb = (data) ->
      #         event.sender.send 'request-anime-details-mal-page-response', {newDb: data, updatedEntry: animeDetails}
      #       Database.loadAnimeDb dbAnimeCb
        # animeDetails = { series_animedb_id: args.animeId }
        # _.assign animeDetails,response.animeDetails
        # Database.updateAnimeEntrySmall animeDetails,->
        #
        #   dbAnimeCb = (data) ->
        #     event.sender.send 'request-anime-details-small-response', {newDb: data, updatedEntry: animeDetails}
        #   Database.loadAnimeDb dbAnimeCb


    ipcMain.on 'save-options', (event,options) =>
      application.logDebug("IPC: save-options")
      @appOptions = options
      @saveOptions()
    ipcMain.on 'get-options', (event) =>
      application.logDebug("IPC: get-options")
      event.sender.send 'get-options-response', @appOptions
    ipcMain.on 'get-user-info',(event) =>
      application.logDebug("IPC: get-user-info")
      getUserCb = (user) ->
        event.sender.send 'get-user-info-response',user
      Database.getUser getUserCb

      if !@firstLaunch
        @window.window.webContents.send 'get-login-status-response'


    ipcMain.on 'call-window-method', (event,method,args...) =>
      application.logDebug("IPC: call-window-method")
      win = BrowserWindow.fromWebContents(event.sender)
      win[method](args...)



    #------------------------------------------------
    #
    #
    #
    #            SEARCHING ANIME
    #
    #
    #------------------------------------------------
    ipcMain.on 'request-search-anime', (event,args) =>
      application.logDebug("IPC: request-search-anime")

      @requestAnimeSearch args.searchTerms, (completed) =>
        event.sender.send 'request-search-anime-response',completed

      # reqSearchCb = (response) =>
      #   if response.success
      #     if response.anime.entry?
      #       event.sender.send 'request-search-response',{success: true,results: response.anime.entry }
      #       if _.isArray response.anime.entry
      #         application.logInfo "Search returned succesful with " + response.anime.entry.length + " entries "
      #       else
      #         application.logInfo "Search returned succesful with 1 entry"
      #
      #       #Search data has contributed to the Database
      #       #Let the renderer know the new data
      #       Database.updateAnimeDbFromSearchData response.anime.entry,->
      #         dbAnimeCb = (data) ->
      #           event.sender.send 'request-animedb-response',{ success: true, list : data }
      #         Database.loadAnimeDb dbAnimeCb
      #   else
      #     event.sender.send 'request-search-response', { success: false, response: response }
      #     @onError response
      #
      # @tools.searchAnime @loggedUser, args.searchTerms,reqSearchCb



    #------------------------------------------------
    #
    #
    #
    #
    #
    #
    #------------------------------------------------
    ipcMain.on 'request-animelist', (event,user,args...) =>
      application.logDebug("IPC: request-animelist")

      reqAnimeListCb = (response) =>
        #To-do implement error
        if response.success
          list = response.list.myanimelist
          delete list.myinfo
          Database.saveList 'animeList',list, ->

          event.sender.send 'request-animelist-response',{ success: true, list:list  }
        else
          @onRequestError response

          event.sender.send 'request-animelist-response',{ success: false, response: response }

      @tools.getAnimelistOfUser @loggedUser.userName, reqAnimeListCb

    ipcMain.on 'db-request-anime', (event,user,args...) =>
      application.logDebug("IPC: db-request-anime")

      dbReqAnimeCb = (response) =>
        event.sender.send 'request-animedb-response',{ success:true,list: response }
      Database.loadAnimeDb dbReqAnimeCb

    #-------------Note to self-------------
    #How initialization works for now
    #Case 1 - First time launch,no data
    #Login -> downloadUserImage
    #Renderer asks for db-request-animelist , db-request-anime (chiika-environment.coffee#ipcGetAnimelist)
    #At this point, database doesn't exist, so we call getAnimelistOfUser
    #Request returns the list and we save it into 2 different NoSQL databases
    #After request returns, we save it into db and wait for DB to call back here
    #Finally we query both DBs to retrieve the data and send it to Renderer
    #
    #
    #Case 2 - Data exists, launch
    #Renderer asks for db-request-animelist , db-request-anime (chiika-environment.coffee#ipcGetAnimelist)
    #At this point, database SHOULD exist, if not, there MIGHT be problems
    #if data exists,we just query the DB and return, easy.
    #If data doesn't exist and this call isn't from login, things gets hard
    #We check animeList database speficially to see if it exists, if it doesn't
    #We try to simulate the login process
    #It SHOULD work, hopefully.
    #Might introduce weird bugs in the future, I'm not confident about this.


    ipcMain.on 'db-request-animelist', (event,user,args...) =>
      application.logDebug("IPC: db-request-animelist")

      if !@tools.checkIfFileExists 'Data/animeList.nosql'
        application.logInfo "Anime file is requested but it doesn't exist.Fixing that..."
        reqAnimeListCb = (response) =>
          if !response.success
            @onRequestError response
            return

          dbSaved = ->
            application.logInfo "Sending (Main -> Renderer) request-animelist-response"
            event.sender.send 'request-animelist-response',{ success: true, list: list }

            dbReqAnimeCb = (animeDbResponse) =>
              event.sender.send 'request-animedb-response',{success: true,list: animeDbResponse }
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
          event.sender.send 'request-animelist-response',{ success:true,list: response }

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

            delayMainScreen = =>
              @window.window.webContents.send 'get-login-status-response'
              @firstLaunch = false
            setTimeout(delayMainScreen,3000)
            )


        else
          application.logInfo("Error: " + response.errorMessage)
          event.sender.send('set-user-login-response',response)
    ipcMain.on 'request-video-info', (event) =>
      application.logDebug("IPC: request-video-info")

      if @mediaDetector.currentPlayer?
        dbQueryResultCb = (result) =>
          application.logDebug "Sending (Browser->Renderer) mp-set-video-info"
          _.assign result, { parseInfo: @mediaDetector.currentVideoFile }
          event.sender.send 'mp-set-video-info', result

        if !Database.isReady 'animelistDb'
          @emitter.on 'animelist-ready', ->
            Database.searchAnimeListDbByTitle @mediaDetector.currentVideoFile.AnimeTitle,dbQueryResultCb
        else
          Database.searchAnimeListDbByTitle @mediaDetector.currentVideoFile.AnimeTitle,dbQueryResultCb

    ipcMain.on 'request-navigate-route', (event,route) =>
      @window.window.webContents.send 'request-navigate-route',route


    @emitter.on 'mp-found',(mp) =>
      if @mbReady
        @mb.window.webContents.send 'mp-found',mp

    @emitter.on 'mp-video-changed', (mp) =>
      if @mbReady
        @mb.window.webContents.send 'mp-video-changed',mp
        recognition = { tries: 0 }
      dbQueryResultCb = (result) =>
        _.assign result, { parseInfo: mp }
        recognition.tries++

        console.log "Try:"+ recognition.tries

        if recognition.tries >= 8
          return

        if result.list && result.db
          application.logDebug "Recognized video file! Its'on both list and db." + result.listEntry.series_title
          if result.listEntry
            @animePrePrequest result.listEntry,@mb.window.webContents,true,true, =>
              _.assign recognition,result
              @sendIPC @window.window.webContents, 'mp-set-video-info',recognition
              @sendIPC @mb.window.webContents, 'mp-set-video-info',recognition

        if !result.list || !result.db
          title = result.parseInfo.AnimeTitle
          application.logDebug "Title not recognized " + title + ". Try : " + recognition.tries + "."


          @requestAnimeSearch title, (completed) =>
            if completed.searchResults?
              #Search might have altered the database in a way that now we can now recognize the file.
              Database.searchAnimeListDbByTitle mp.AnimeTitle,dbQueryResultCb
            else
              recognition.tries++
              application.logDebug "Title not recognized " + title + ". Try : " + recognition.tries + "."
              _.assign recognition,result

              if recognition.suggestions?
                suggestion = recognition.suggestions[0]
                Database.searchAnimeListDbByTitle suggestion.entry.series_title, dbQueryResultCb
                #@sendIPC @window.window.webContents, 'mp-set-video-info',recognition




        # @mb.window.webContents.send 'mp-set-video-info', result
        # @window.window.webContents.send 'mp-set-video-info', result

        #Left off here
        #Thoughts: check if list && db , if false, do the pre request thingy.

      if !Database.isReady 'animelistDb'
        @emitter.on 'animelist-ready', ->
          Database.searchAnimeListDbByTitle mp.AnimeTitle,dbQueryResultCb
      else
        Database.searchAnimeListDbByTitle mp.AnimeTitle,dbQueryResultCb

    @emitter.on 'mp-closed', (mp) =>
      if @mbReady
        @mb.window.webContents.send 'mp-closed',mp


  animePrePrequest: (anime,receiver,sendToMainWindow,defer,defCallback) ->
    if defer
      deferredCalls = []
    if anime? && !anime.series_english?
      if defer
        _deferred1 = _when.defer()
        deferredCalls.push _deferred1.promise
      @requestAnimeSearch anime.series_title, (completed) =>
        if defer
          _deferred1.resolve()
          @sendIPC receiver, 'request-search-anime-response',completed

          if sendToMainWindow
            @sendIPC @window.window.webContents, 'request-search-anime-response',completed
        else
          @sendIPC receiver, 'request-search-anime-response',completed

          if sendToMainWindow
            @sendIPC @window.window.webContents, 'request-search-anime-response',completed

    if anime? && !anime.misc_genres?
      if defer
        _deferred2 = _when.defer()
        deferredCalls.push _deferred2.promise
      @requestAnimeDetailsSmall anime.series_animedb_id, (completed) =>
        if defer
          _deferred2.resolve()
          @sendIPC receiver, 'request-anime-details-small-response', completed
          if sendToMainWindow
            @sendIPC @window.window.webContents, 'request-anime-details-small-response',completed
        else
          sender.send 'request-anime-details-small-response', completed
          if sendToMainWindow
            @sendIPC @window.window.webContents, 'request-anime-details-small-response',completed

    if anime? && !anime.misc_source?
      if defer
        _deferred3 = _when.defer()
        deferredCalls.push _deferred3.promise
      @requestAnimeDetailsMalPage anime.series_animedb_id, (completed) =>
        if defer
          _deferred3.resolve()
          @sendIPC receiver, 'request-anime-details-mal-page-response', completed
          if sendToMainWindow
            @sendIPC @window.window.webContents, 'request-anime-details-mal-page-response',completed
        else
          @sendIPC receiver, 'request-anime-details-mal-page-response', completed
          if sendToMainWindow
            @sendIPC @window.window.webContents, 'request-anime-details-mal-page-response',completed

    if defer
      _when.all(deferredCalls)
            .then ( => defCallback()
            )

  requestAnimeDetailsMalPage: (animeId,callback) ->
    application.logDebug "RequestAnimeDetailsMalPage - " + animeId
    @tools.animeDetailsMalPage animeId, (response) ->
      animeDetails = { series_animedb_id: animeId }
      _.assign animeDetails, response.animeDetails
      Database.updateAnimeEntryMalPage animeDetails, (dbResponse) ->
        if dbResponse.updated
          dbAnimeCb = (data) ->
            callback { newDb: data, updatedEntry: animeDetails }
          Database.loadAnimeDb dbAnimeCb
  requestAnimeDetailsSmall: (animeId,callback) ->
    application.logDebug "RequestAnimeDetailsSmall - " + animeId
    @tools.animeDetailsSmall animeId, (response) ->
      animeDetails = { series_animedb_id: animeId }
      _.assign animeDetails,response.animeDetails
      Database.updateAnimeEntrySmall animeDetails,->
        dbAnimeCb = (data) ->
          callback {newDb: data, updatedEntry: animeDetails}
        Database.loadAnimeDb dbAnimeCb

  requestAnimeSearch: (searchTerms,callback) ->
    application.logDebug "RequestAnimeSearch - " + searchTerms
    reqSearchCb = (response) =>
      if response.success
        if response.anime.entry?
          if _.isArray response.anime.entry
            application.logInfo "Search returned succesful with " + response.anime.entry.length + " entries "
          else
            application.logInfo "Search returned succesful with 1 entry"

          #Search data has contributed to the Database
          #Let the renderer know the new data
          Database.updateAnimeDbFromSearchData response.anime.entry,->
            dbAnimeCb = (data) ->
              callback { success: true, list : data,searchResults: response.anime.entry }
            Database.loadAnimeDb dbAnimeCb
      else
        #event.sender.send 'request-search-response', { success: false, response: response }
        if response.statusCode == 204
          application.logInfo "Search returned empty for " + searchTerms
        callback response

    @tools.searchAnime @loggedUser, searchTerms,reqSearchCb
  onRequestError: (callback) ->
    console.log callback.errorMessage
  sendIPC: (receiver,message,args) ->
    application.logDebug ">IPC: " + message
    receiver.send message,args

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

      @appOptions = AppOptions

      @appOptions.Version = process.env.version

      fs.writeFileSync configFilePath,JSON.stringify(@appOptions),'utf-8'

      @firstLaunch = true
    else
      configFile = fs.readFileSync configFilePath, 'utf-8'
      @firstLaunch = false

      @appOptions = JSON.parse(configFile)

      packageVersion = process.env.version
      appVersion = @appOptions.Version

      if appVersion? && packageVersion != appVersion
        @firstLaunch = true
        @appOptions.Version = packageVersion
        @saveOptions()


  checkRememberWindowProperties: ->
    if @appOptions.RememberWindowSizeAndPosition
      if @appOptions.WindowProperties? && @appOptions.WindowProperties.size?
        @mainWindowSize = @appOptions.WindowProperties.size
      else
        @mainWindowSize = @calculateWindowSize()

        if !@appOptions.WindowProperties?
          @appOptions.WindowProperties = {}
        @appOptions.WindowProperties.size = @mainWindowSize
      if @appOptions.WindowProperties? && @appOptions.WindowProperties.position?
        @mainWindowPosition = @appOptions.WindowProperties.position
      else
        screenRes = @getScreenRes()
        @mainWindowPosition = { x: screenRes.width / 2 - @mainWindowSize.width/2, y: screenRes.height / 2 - @mainWindowSize.height/2  }
        if !@appOptions.WindowProperties?
          @appOptions.WindowProperties = {}
        @appOptions.WindowProperties.position = @mainWindowPosition

      @saveOptions()
    else
      @mainWindowSize = @calculateWindowSize()
      screenRes = @getScreenRes()
      @mainWindowPosition = { x: screenRes.width / 2 - @mainWindowSize.width/2, y: screenRes.height / 2 - @mainWindowSize.height/2  }

  saveOptions: ->
    configFilePath = path.join(path.join(@chiikaHome, "Config"),"Chiika.json");
    fs.writeFileSync configFilePath,JSON.stringify(@appOptions),'utf-8'
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
    #@LoginWindow.openDevTools()
  showMainWindow: ->
    @window.window.show()

  hideMainWindow: ->
    @window.window.minimize()
    @window.window.hide()
  calculateWindowSize: ->
    screenRes = @getScreenRes()
    windowWidth = Math.round(screenRes.width * 0.66)
    windowHeight = Math.round(screenRes.height * 0.75)
    return { width: windowWidth, height: windowHeight }

  openWindow: ->
    deferred = _when.defer()
    isBorderless = true
    windowUrl = "file://#{__dirname}/../renderer/index.html#Home"
    htmlURL = windowUrl
    @window = new ApplicationWindow htmlURL,
      width: @mainWindowSize.width
      height: @mainWindowSize.height
      title: 'Chiika - Development Mode'
      icon: "./resources/icon.png"
      frame:!isBorderless
      x: @mainWindowPosition.x
      y: @mainWindowPosition.y
    @window.openDevTools()

    @window.window.webContents.on 'did-finish-load', =>
      @window.window.webContents.send('window-reload')

      @window.enableReactDevTools()
      deferred.resolve()
    @window.window.on 'close', =>
      winPosX = @window.getPosition()[0]
      winPosY = @window.getPosition()[1]
      width = @window.getSize()[0]
      height = @window.getSize()[1]

      if @appOptions.RememberWindowSizeAndPosition
        application.appOptions.WindowProperties.size = { width: width, height: height }
        application.appOptions.WindowProperties.position = { x: winPosX, y: winPosY }
        @saveOptions()
    deferred.promise






application = new Application
