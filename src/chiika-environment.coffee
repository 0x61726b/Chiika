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
Logger                = require './main_process/logger'

ChiikaIPC             = require './chiika-ipc'
ViewManager           = require './view-manager'
CardManager           = require './card-manager'

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
    @viewManager      = new ViewManager()
    @cardManager      = new CardManager()

    testCard =
      name: 'typeMiniCard'
      title: 'Type'
      content: 'TV'
      type: 'miniCard'

    seasonCard =
      name: 'seasonMiniCard'
      title: 'Season'
      content: 'Fall 2014'
      type: 'miniCard'

    episodeCard =
      name: 'episodeMiniCard'
      title: 'Episode'
      content: '6/24'
      type: 'miniCard'

    studioCard =
      name: 'studioMiniCard'
      title: 'Studio'
      content: 'Feel'
      type: 'miniCard'

    sourceCard =
      name: 'sourceMiniCard'
      title: 'Source'
      content: 'Manga'
      type: 'miniCard'

    @cardManager.addCard(testCard)
    @cardManager.addCard(seasonCard)
    @cardManager.addCard(episodeCard)
    @cardManager.addCard(studioCard)
    @cardManager.addCard(sourceCard)





    @ipc.onReconstructUI()

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

  onReinitializeUI: (loading,main) ->
    @emitter.on 'reinitialize-ui', (args) =>
      loading()

      @ipc.disposeListeners('get-ui-data-response')

      @preload().then =>
        setTimeout(main,args.delay)

  sendNotification: (title,body,icon) ->
    if !icon?
      icon = __dirname + "/../assets/images/chiika.png"
    notf = new Notification(title,{ body: body, icon: icon})

  reInitializeUI: (delay) ->
    console.log "Reinitiazing UI"

    if !delay?
      delay = 500
    @emitter.emit 'reinitialize-ui',{ delay: delay }

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
