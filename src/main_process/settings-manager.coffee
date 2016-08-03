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

DefaultOptions      = require './options'
mkdirp              = require 'mkdirp'
_                   = require 'lodash'
_when               = require 'when'
path                = require 'path'

module.exports = class SettingsManager
  appOptions: null
  firstLaunch: false

  #
  #
  #
  constructor: ->
    #Initialize settings related stuff
    process.env.CHIIKA_HOME = chiika.getAppHome()

  initialize: ->
    defer = _when.defer()

    @createFolders().then =>
      # defaultScriptDir = path.join(process.cwd(),"src","scripts")
      # chiika.utility.copyDirectoryToDestination(defaultScriptDir,path.join(chiika.getAppHome(),"Scripts"))
    #Copy default scripts


      @configFilePath = path.join("Config","Chiika.json")
      configExists = chiika.utility.fileExistsSmart @configFilePath

      #Check if config file exists
      #It does
      if configExists
        configFile = chiika.utility.readFileSmart(@configFilePath)
        @appOptions = JSON.parse(configFile)
      else #It doesnt
        #Open the file for writing
        cf = chiika.utility.openFileWSmart @configFilePath

        #Write the default options
        chiika.utility.writeFileSmart @configFilePath, JSON.stringify(DefaultOptions)

        chiika.utility.closeFileSync(cf)

        #Assign it to a local variable
        @appOptions = DefaultOptions

        @firstLaunch = true

      defer.resolve()
      chiika.logger.info "[cyan](Settings-Manager) Settings initialized"


    defer.promise


  applySettings: ->
    #Remember window properties
    if @getOption('RememberWindowSizeAndPosition') == true
      chiika.windowManager.rememberWindowProperties()


  save: ->
    cf = chiika.utility.openFileWSmart @configFilePath
    chiika.utility.writeFileSmart @configFilePath, JSON.stringify(@appOptions)
    chiika.utility.closeFileSync(cf)

    chiika.logger.info("Saving settings...")


  #
  # Creates necessary folders for the application at the app home. %appdata%/chiika on Windows, /user/ .. etc on linux.
  #
  createFolders: ->
    chiikaHome = chiika.getAppHome()
    folders = [
      "Config",
      "Data",
      "Scripts",
      "Cache",
      "Cache/Scripts",
      "Data/Images"
    ]
    promises = []

    _.forEach folders, (v,k) ->
      promises.push chiika.utility.createFolderSmart(v)
    promises.push chiika.utility.createFolder(chiika.getDbHome())
    _when.all(promises)



  #
  #
  #
  getOption: (name) ->
    if @appOptions[name]?
      chiika.logger.warn("The requested option #{@appOptions[name]} is not defined!")
      return undefined
    else
      @appOptions[name]

  #
  #
  #
  setOption: (name,value) ->
    if !_.isUndefined name && !_.isUndefined value
      @appOptions[name] = value
    else
      chiika.logger.warn("You have supplied incorrect paramters.")

    @save()


  #
  #
  #
  setWindowProperties: (windowOptions) ->
    @setOption('WindowProperties',windowOptions)
