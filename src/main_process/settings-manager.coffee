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
_forEach            = require 'lodash.foreach'
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

    if process.env.DEV_MODE? && process.env.DEV_MODE == 'true'
      chiika.devMode = true

    if process.env.RUNNING_TESTS? && process.env.RUNNING_TESTS == 'true'
      chiika.runningTests = true

    chiika.logger.info("Dev Mode: #{chiika.devMode}")
    chiika.logger.info("Running Tests: #{chiika.runningTests}")

  initialize: ->
    defer = _when.defer()

    @createFolders().then =>
      # defaultScriptDir = path.join(process.cwd(),"src","scripts")
      # chiika.utility.copyDirectoryToDestination(defaultScriptDir,path.join(chiika.getAppHome(),"Scripts"))
    #Copy default scripts


      @configFilePath = path.join("config","Chiika.json")
      configExists = chiika.utility.fileExistsSmart @configFilePath

      #Check if config file exists
      #It does
      if configExists
        configFile = chiika.utility.readFileSmart(@configFilePath)
        @appOptions = JSON.parse(configFile)
      else #It doesnt
        #Open the file for writing
        cf = chiika.utility.openFileWSmart @configFilePath

        if process.platform == "win32"
          DefaultOptions.DisableAnimeRecognition = true

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

  save: ->
    cf = chiika.utility.openFileWSmart @configFilePath
    chiika.utility.writeFileSmart @configFilePath, JSON.stringify(@appOptions)
    chiika.utility.closeFileSync(cf)

    chiika.logger.info("Saving settings...")

  saveConfigFile: (file,config) ->
    filePath = path.join("config",file + '.json')

    #Open the file for writing
    cf = chiika.utility.openFileWSmart filePath

    #Write the default options
    chiika.utility.writeFileSmart filePath, JSON.stringify(config)

    chiika.utility.closeFileSync(cf)

  readConfigFile: (file) ->
    filePath = path.join("config",file + '.json')
    configExists = chiika.utility.fileExistsSmart filePath

    if !configExists
      return null
    else
      configFile = chiika.utility.readFileSmart(filePath)
      JSON.parse(configFile)


  #
  # Creates necessary folders for the application at the app home. %appdata%/chiika on Windows, /user/ .. etc on linux.
  #
  createFolders: ->
    chiikaHome = chiika.getAppHome()
    folders = [
      "config",
      "data",
      "scripts",
      "cache",
      "cache/scripts",
      "data/images"
    ]
    promises = []

    _forEach folders, (v,k) ->
      promises.push chiika.utility.createFolderSmart(v)
    promises.push chiika.utility.createFolder(chiika.getDbHome())
    _when.all(promises)

  #
  #
  #
  getOption: (name) ->
    if !@appOptions[name]?
      chiika.logger.warn("The requested option #{name} is not defined!")
      return undefined
    else
      @appOptions[name]

  #
  #
  #
  setOption: (name,value) ->
    if name? && value?
      @appOptions[name] = value

      chiika.logger.info("Set #{name} to #{value}")

      chiika.emitter.emit 'set-option', name
    else
      chiika.logger.warn("You have supplied incorrect paramters.")

    @save()


  #
  #
  #
  setWindowProperties: (windowOptions) ->
    @setOption('WindowProperties',windowOptions)
