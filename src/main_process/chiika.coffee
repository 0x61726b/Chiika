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
  devMode: false
  runningTests: false


  #
  # Entry point of Chiika
  #
  constructor: () ->
    global.chiika       = this
    console.log         ("Using electron instance #{require.resolve('electron')}")
    @chiikaHome         = path.join(app.getPath('appData'),"chiika")
    console.log @chiikaHome
    if process.platform == "linux"
      console.log process.env.HOME
    else if process.platform == "darwin"
      console.log process.env.HOME + 'Library/Application Support'
    else
      console.log process.env.APPDATA

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
        @run()


  run: ->
    # appDelegate.run() method will open 3 windows when the app is ready
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
                    chiika.windowManager.createLoginWindow()


    # If there are no users but there are UI data
    # preload UI data first, this way scripts can instantly access UI data without waiting
    #
    if userCount == 0 && @uiManager.getUIItemsCount() > 0
      @uiManager.preloadUIItems()
                .then =>
                  chiika.logger.verbose("Preloading UI complete!")
                  @apiManager.compileUserScripts().then =>
                    @uiManager.checkUIData().then =>
                      @apiManager.postInit()
                    chiika.windowManager.createLoginWindow()

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
                        @apiManager.postInit()
                        chiika.windowManager.createMainWindow()
      else
        #This will probably fail if more than one script is being executed...
        #This means when all scripts are compiled,preload UI items
        @apiManager.compileUserScripts().then =>
          @uiManager.preloadUIItems()
                    .then =>
                      chiika.logger.verbose("Preloading UI complete!")
                      chiika.windowManager.createMainWindow()



  getAppHome: ->
    @chiikaHome
  getDbHome: ->
    path.join(@chiikaHome,"Data","Database")


app = new Application()
