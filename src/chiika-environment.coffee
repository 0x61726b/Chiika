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
NotificationManager                       = require './notification-manager'

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
    @notificationManager = new NotificationManager()




      # @uiData.sort (a,b) =>
      #   if a.type.indexOf('card') == -1
      #     return 0
      #   else
      #     if a.cardProperties.order > b.cardProperties.order
      #       return -1
      #     else
      #       return 1
      #   return 0




    @ipc.onReconstructUI()
    @ipc.spectron()
    @refreshData()


  refreshData: ->
    ipcRenderer.on 'refresh-data', (event,args) =>
      @ipc.sendMessage 'get-ui-data'
      @ipc.sendMessage 'get-view-data'
      @ipc.sendMessage 'get-settings-data'

  preload: ->
    waitForUI = _when.defer()
    waitForViewData = _when.defer()
    waitForSettingsData = _when.defer()
    waitForPostInit = _when.defer()
    waitForViewByName = _when.defer()
    waitForUIDataByName = _when.defer()

    async = [ waitForUI.promise, waitForViewData.promise,waitForSettingsData.promise,waitForPostInit.promise,waitForViewByName.promise ]

    ipcRenderer.on 'get-view-data-by-name-response', (event,args) =>
      @logger.renderer("get-view-data-by-name-response - #{args.name}")
      name = args.name

      waitForViewByName.resolve()

      findView = _find @viewData, (o) -> o.name == name
      index    = _indexOf @viewData, findView
      if findView?
        if args.view?
          @viewData.splice(index,1,args.view)
          @logger.renderer("ViewData - Replacing #{name}")
          console.log args.view
        else
          @viewData.splice(index,1)
          @logger.renderer("ViewData - Removing #{name}")
      else
        @logger.renderer("Could not find view in renderer #{name}. Current views: ")
        console.log "WTF ?"
        console.log args.view
        @viewData.push args.view

      @cardManager.refreshCards()
      @emitter.emit 'view-refresh', { view: args.view }


    ##########################


    ipcRenderer.on 'get-ui-data-by-name-response', (event,args) =>
      @logger.renderer("get-ui-data-by-name-response - #{args.name}")
      name = args.name

      waitForUIDataByName.resolve()

      findUiItem = _find @uiData, (o) -> o.name == name
      index    = _indexOf @uiData, findUiItem
      if findUiItem?
        if args.item?
          @uiData.splice(index,1,args.item)
          @logger.renderer("UIDATA - Replacing #{name}")
          console.log args.item
        else
          @uiData.splice(index,1)
          @logger.renderer("UIDATA - Removing #{name}")
      else
        @uiData.push args.item

      @uiData.sort (a,b) =>
        if a.type.indexOf('card') == -1
          return 0
        else
          if b? && a?
            if b.cardProperties.order > a.cardProperties.order
              return -1
            else
              return 1
          else
            return 0
        return 0

      @cardManager.refreshCards()
      @emitter.emit 'ui-data-refresh', { item: args.item }



    ##########################

    @ipc.sendMessage 'get-ui-data'
    @ipc.refreshUIData (args) =>
      @uiData = args
      chiika.logger.renderer("UI data is present.")

      @uiData.sort (a,b) =>
        if a.type.indexOf('card') == -1
          return 0
        else
          if b? && a?
            if b.cardProperties.order > a.cardProperties.order
              return -1
            else
              return 1
          else
            return 0
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

      waitForViewData.resolve()

      @cardManager.refreshCards()

    @ipc.sendMessage 'get-settings-data'
    @ipc.getSettings (args) =>
      @appSettings = args

      waitForSettingsData.resolve()

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
        console.log "All promises have returned"
        setTimeout(main,args.delay)

  openShellUrl: (url) ->
    shell.openExternal(url)

  notification: (notf) ->
    window.yuiNotification(notf)

  getOption: (option) ->
    @appSettings[option]

  setOption: (option,value) ->
    @appSettings[option] = value
    @ipc.setOption(option,value)

  cardAction: (card,action,params,callback) ->
    @ipc.sendMessage 'card-action', { card:card, action:action, params: params }

    ipcRenderer.on "card-action-#{action}-response", (event,args) =>
      callback(args)
      @ipc.disposeListeners("card-action-#{action}-response")

  #
  #
  #
  scriptAction: (owner,action,params,callback) ->
    if !params?
      params = {}

    @ipc.sendMessage 'script-action', { owner: owner, action: action, params: params, return: callback }

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
