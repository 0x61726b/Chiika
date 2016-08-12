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
ViewManager                       = require './view-manager'
ChiikaPublicApi                   = require './chiika-public'
Utility                           = require './utility'
AppOptions                        = require './options'
AppDelegate                       = require './app-delegate'



process.on 'uncaughtException',(err) ->
  console.log err
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
      console.log path.join(process.env.HOME,'Library/Application Support')
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
    @viewManager        = new ViewManager()
    @uiManager          = new UIManager()
    @chiikaApi          = new ChiikaPublicApi( { logger: @logger, db: @dbManager, parser: @parser, ui: @uiManager, viewManager: @viewManager })
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
    #
    #
    #
    #
    userCount     = @dbManager.usersDb.users.length
    viewConfig    = @settingsManager.readConfigFile('view')
    viewCount     = 0
    if viewConfig?
      viewCount     = @settingsManager.readConfigFile('view').views.length



    chiika.logger.verbose("User count #{userCount}")
    chiika.logger.verbose("View count #{viewCount}")

    # If there are no users and view data
    # Compile scripts first
    # Because if there are no UI data, UI Manager will ask scripts to create UI data, so we need scripts compiled
    #
    if userCount == 0 && viewCount == 0
      @apiManager.preCompile().then =>
        @apiManager.postCompile()

        @viewManager.preload()
                  .then =>
                    chiika.logger.verbose("Preloading complete!")
                    chiika.windowManager.createLoginWindow()


    # If there are no users but there are view data
    # preload view data first, this way scripts can instantly access view data without waiting
    #
    if userCount == 0 && viewCount > 0
      @viewManager.preload().then =>
        chiika.logger.verbose("Preloading complete!")

        @apiManager.preCompile().then =>
          @apiManager.postCompile()
          chiika.windowManager.createLoginWindow()


    if userCount > 0
      # If there are no UI items
      # compile scripts first
      # if there are UI items,
      # preload them first so when script is ready, they can access them right of the bat
      # after preload and script compile, check if the views need update
      # if they do, call view-update event so script can respond

      @viewManager.preload().then =>
        chiika.logger.verbose("Preloading UI complete!")

        @apiManager.preCompile().then =>
          @apiManager.postCompile()
          chiika.windowManager.createMainWindow()




  getAppHome: ->
    @chiikaHome
  getDbHome: ->
    path.join(@chiikaHome,"data","database")


app = new Application()
