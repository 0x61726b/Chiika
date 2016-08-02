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
{Emitter} = require 'event-kit'
{BrowserWindow, ipcRenderer,remote} = require 'electron'


_                     = require 'lodash'
fs                    = require 'fs'
path                  = require 'path'

_when                 = require 'when'
Logger                = require './main_process/Logger'

ChiikaIPC             = require './chiika-ipc'

class ChiikaEnvironment
  emitter: null
  constructor: (params={}) ->
    {@applicationDelegate, @window,@chiikaHome} = params

    window.chiika = this

    # scribe = require 'scribe-js'
    # express = require 'express'
    #
    # scribe = scribe()
    # console = process.console

    @emitter          = new Emitter
    @logger           = remote.getGlobal('logger')

    @ipc              = new ChiikaIPC()



    # @ipc.getUsers()
    # @ipc.preload()

    #
    # @ipc.refreshUIData (args) =>
    #   @uiData = args
    #   console.log "Hello"



  preload: ->
    defer = _when.defer()

    async = [ defer.promise ]

    @ipc.sendMessage 'get-ui-data'
    @ipc.refreshUIData (args) =>
      @uiData = args
      chiika.logger.renderer("UI data is present.")

      infoStr = ''
      for uiData in @uiData
        infoStr += " #{uiData.displayName} ( #{uiData.displayType} )"

      chiika.logger.renderer("Current UI items are #{infoStr}")
      defer.resolve()

      console.log @uiData

    _when.all(async)

  reInitializeUI: (loading,main) ->
    @emitter.on 'reinitialize-ui', =>
      loading()

      @preload().then =>
        setTimeout(main,500)

  sendNotification: (title,body,icon) ->
    if !icon?
      icon = __dirname + "/../assets/images/chiika.png"
    notf = new Notification(title,{ body: body, icon: icon})


  getWorkingDirectory: ->
    process.cwd()


  getResourcesPath: ->
    process.resourcesPath


  getUserTimezone: ->
    moment = require 'moment-timezone'
    userTimezone = moment.tz(moment.tz.guess())
    utcOffset = moment.parseZone(userTimezone).utcOffset() * 60# In seconds
    return { timezone: userTimezone , offset: utcOffset }

module.exports = ChiikaEnvironment
