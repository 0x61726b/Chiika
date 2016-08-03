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
{BrowserWindow, ipcMain,globalShortcut,Tray,Menu,app} = require 'electron'


yargs                             = require 'yargs'
path                              = require 'path'

fs                                = require 'fs'
mkdirp                            = require 'mkdirp'
_                                 = require 'lodash'
_when                             = require 'when'
{Emitter,Disposable}              = require 'event-kit'
string                            = require 'string'

# ---------------------------
#
# ---------------------------


#ipcHelpers = require '../ipcHelpers'
#MediaDetect = require('./tools/src/media-detect-win32')


ApplicationWindow                 = require './app-window'
menubar                           = require './menubar'
Logger                            = require './logger'

APIManager                        = require './api-manager'
DbManager                         = require './database-manager'
RequestManager                    = require './request-manager'
SettingsManager                   = require './settings-manager'
WindowManager                     = require './window-manager'
IpcManager                        = require './ipc-manager'
Parser                            = require './parser'
UIManager                         = require './ui-manager'
ChiikaPublicApi                   = require './chiika-public'
Utility                           = require './utility'
AppOptions                        = require './options'
AppDelegate                       = require './app-delegate'


process.on 'uncaughtException',(err) ->
  # Show a somewhat easily readable text error
  if err && err.stack?
    error = err.stack.split("\n")
    for i in [0...5]
      line = error[i]
      line = string(line).trimLeft().s

      if i > 0
        fileLine = line.substring(line.lastIndexOf('\\') + 1, line.length - 1)
        errorFunction = line.substring(3,line.indexOf('('))
        chiika.logger.error errorFunction + " - " + fileLine
      else
        chiika.logger.error line
  else
    chiika.logger.error("Hmm....")
    chiika.logger.error(err)

module.exports =
class Application
  window: null,
  loginWindow: null,


  #
  # Entry point of Chiika
  #
  constructor: () ->
    global.chiika       = this
    @chiikaHome         = path.join(app.getPath('appData'),"chiika")

    @logger             = new Logger("verbose").logger
    global.logger       = @logger #Share with renderer

    @emitter            = new Emitter
    @utility            = new Utility()
    @settingsManager    = new SettingsManager()
    @apiManager         = new APIManager()
    @dbManager          = new DbManager()
    @requestManager     = new RequestManager()
    @parser             = new Parser()
    @uiManager          = new UIManager()
    @chiikaApi          = new ChiikaPublicApi( { logger: @logger, db: @dbManager, parser: @parser, ui: @uiManager })
    @windowManager      = new WindowManager()
    @appDelegate        = new AppDelegate()
    @ipcManager         = new IpcManager()

    @ipcManager.handleEvents()

    app.commandLine.appendSwitch('--disable-2d-canvas-image-chromium');
    app.commandLine.appendSwitch('--disable-accelerated-2d-canvas');
    app.commandLine.appendSwitch('--disable-gpu');

    @appDelegate.run()

    @appDelegate.ready =>
      @dbManager.onLoad =>
        # run() method will open 3 windows when the app is ready
        # loading,main,login (main,login not visible)
        # If there are no users, close loading,show login
        # If there are users, close loading, show main window
        userCount = @dbManager.usersDb.users.length
        chiika.logger.verbose("User count #{userCount}")

        # If there are no users and UI data
        # Compile scripts first
        # Because if there are no UI data, UI Manager will ask scripts to create UI data, so we need scripts compiled
        #
        if userCount == 0 && @uiManager.getUIItemsCount() == 0
          @apiManager.compileUserScripts().then =>
            @uiManager.preloadUIItems()
                      .then =>
                        chiika.logger.verbose("Preloading UI complete!")
                        @windowManager.getWindowByName('login').show()
                        @windowManager.getWindowByName('loading').hide()

        # If there are no users but there are UI data
        # preload UI data first, this way scripts can instantly access UI data without waiting
        #
        if userCount == 0 && @uiManager.getUIItemsCount() > 0
          @uiManager.preloadUIItems()
                    .then =>
                      chiika.logger.verbose("Preloading UI complete!")
                      @apiManager.compileUserScripts().then =>
                        @uiManager.checkUIData()
                        @windowManager.getWindowByName('login').show()
                        @windowManager.getWindowByName('loading').hide()

        if userCount > 0
          # If there are no UI items
          # compile scripts first
          # if there are UI items,
          # preload them first so when script is ready, they can access them right of the bat
          # after preload and script compile, check if the views need update
          # if they do, call view-update event so script can respond
          if @uiManager.getUIItemsCount() > 0
            @uiManager.preloadUIItems()
                      .then =>
                        chiika.logger.verbose("Preloading UI complete!")
                        @apiManager.compileUserScripts().then =>
                          @uiManager.checkUIData().then =>
                            @windowManager.closeLoadingWindow()
                            @windowManager.showMainWindow(true)
          else
            #This will probably fail if more than one script is being executed...
            #This means when all scripts are compiled,preload UI items
            @apiManager.compileUserScripts().then =>
              @uiManager.preloadUIItems()
                        .then =>
                          chiika.logger.verbose("Preloading UI complete!")
                          @windowManager.closeLoadingWindow()
                          @windowManager.showMainWindow(true)


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
  getAppHome: ->
    @chiikaHome
  getDbHome: ->
    path.join(@chiikaHome,"Data","Database")
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

  # openLoginWindow: ->
  #   options = {
  #      frame:false,
  #      width:800,
  #      height:600,
  #      icon:'./resources/icon.png'
  #   }
  #
  #
  #   @LoginWindow = new BrowserWindow(options);
  #   @LoginWindow.loadURL("file://#{__dirname}/../renderer/MyAnimeListLogin.html")
  #   #@LoginWindow.openDevTools()





application = new Application
