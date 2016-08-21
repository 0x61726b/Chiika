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
{Emitter}                                 = require 'event-kit'
{ipcRenderer,remote,shell} = require 'electron'

_when                                     = require 'when'
Logger                                    = require './main_process/logger'
_find                                     = require 'lodash/collection/find'
_indexOf                                  = require 'lodash/array/indexOf'

ChiikaIPC                                 = require './chiika-ipc'
ViewManager                               = require './view-manager'
CardManager                               = require './card-manager'

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





    @ipc.onReconstructUI()
    @ipc.spectron()
    @refreshData()

    # @ipc.refreshViewData (args) =>
    #   view = _find @viewData, (o) -> o.name == args.view.name
    #   index = _indexOf @viewData, view
    #
    #   console.log args
    #
    #   if view?
    #     view.dataSource = args.view.dataSource
    #     @viewData.splice(index,1,args.view)
    #
    #   @cardManager.refreshCards()

  refreshData: ->
    ipcRenderer.on 'refresh-data', (event,args) =>
      @ipc.sendMessage 'get-ui-data'
      @ipc.sendMessage 'get-view-data'

  preload: ->
    waitForUI = _when.defer()
    waitForViewData = _when.defer()
    waitForSettingsData = _when.defer()
    waitForPostInit = _when.defer()

    async = [ waitForUI.promise, waitForViewData.promise,waitForSettingsData.promise,waitForPostInit.promise ]

    @ipc.sendMessage 'get-ui-data'
    @ipc.refreshUIData (args) =>
      @uiData = args
      chiika.logger.renderer("UI data is present.")

      @uiData.sort (a,b) =>
        if a.type.indexOf('card') == -1
          return 0
        else
          if a.order > b.order
            return -1
          else
            return 1
        return 0


      infoStr = ''
      for uiData in @uiData
        infoStr += " #{uiData.display} ( #{uiData.type} )"

      chiika.logger.renderer("Current UI items are #{infoStr}")
      waitForUI.resolve()

      console.log @uiData

    @ipc.sendMessage 'get-view-data'
    @ipc.getViewData (args) =>
      @viewData = args
      console.log @viewData

      waitForViewData.resolve()

      @cardManager.refreshCards()

    @ipc.sendMessage 'get-settings-data'
    @ipc.getSettings (args) =>
      @appSettings = args

      waitForSettingsData.resolve()

      console.log @appSettings

    @ipc.sendMessage 'post-init'
    ipcRenderer.on 'post-init-response', (event,args) =>
      console.log "All cool"

      waitForPostInit.resolve()
    _when.all(async)

  onReinitializeUI: (loading,main) ->
    @emitter.on 'reinitialize-ui', (args) =>
      loading()

      @ipc.disposeListeners('get-ui-data-response')

      @preload().then =>
        setTimeout(main,args.delay)

  openShellUrl: (url) ->
    shell.openExternal(url)

  getOption: (option) ->
    @appSettings[option]

  setOption: (option,value) ->
    @appSettings[option] = value
    @ipc.setOption(option,value)

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
