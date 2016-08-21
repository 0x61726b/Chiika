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
{Emitter}                   = require 'event-kit'
{ipcRenderer}               = require 'electron'
_when                       = require 'when'

module.exports = class ChiikaIPC
  preloadPromises: []
  constructor: ->
    #
    # @preloadPromises.push @sendReceiveIPC 'get-ui-data', (event,args,defer) =>
    #   defer.resolve()
    #   console.log args
    #
    #
    # _when.all(@preloadPromises).then =>
    #   console.log "All done m8"


  preload: ->
    _when.all(@preloadPromises).then =>
      @sendMessage('ui-init-complete')

  refreshUIData: (callback) ->
    @receive 'get-ui-data-response',(event,args) =>
      callback(args)

  refreshViewData: (callback) ->
    @receive 'refresh-view-response',(event,args) =>
      callback(args)

  getViewData: (callback) ->
    @receive 'get-view-data-response', (event,args) =>
      callback(args)

  getSettings: (callback) ->
    @receive 'get-settings-data-response',(event,args) =>
      callback(args)

  setOption: (name,value) ->
    @sendMessage 'set-settings-option', { name: name, value: value }

  getUIData: ->
    @preloadPromises.push @sendReceiveIPC 'get-ui-data',{}, (event,defer,args) =>
      defer.resolve()
      console.log args


  getUsers: ->
    @preloadPromises.push @sendReceiveIPC 'get-user-data',{}, (event,defer,args) =>
      defer.resolve()
      console.log args


  getDetailsLayout: (id,viewName,owner,callback) ->
    @sendMessage 'details-layout-request', { id: id , viewName:viewName, owner: owner }


    disposable = @receive 'details-layout-request-response', (event,args) =>
      callback(args)

  spectron: ->
    @receive 'spectron-scrollgrid', (event,args) =>
      scrollAmount = args.params.scrollAmount
      $(".objbox").scrollTop(scrollAmount)
      console.log "spectron-scrollgrid"
      console.log scrollAmount


  #
  #
  #
  refreshViewByName: (view,service,params) ->
    if !params?
      params = {}
    @sendMessage 'refresh-view-by-name',{ viewName: view, service: service,params: params }

  #
  #
  #
  openLoginWindow: ->
    @sendMessage 'window-method',{ method: 'show', window:'login' }


  reconstructUI: () ->
    @sendMessage 'reconstruct-ui'



  detailsAction: (action,layout,params) ->
    if !params?
      params = {}
    @sendMessage 'details-action', { action:action, layout: layout, params: params }

  detailsActionResponse: (action,callback) ->
    @receive 'details-action-response', (event,args) =>
      if args.action == action
        callback(args)

  onReconstructUI: ->
    @receive 'reconstruct-ui-response', (event,args) =>
      @sendMessage 'get-ui-data'
      @sendMessage 'get-view-data'

  disposeListeners: (channel) ->
    ipcRenderer.removeAllListeners(channel)


  sendMessage: (message,args) ->
    chiika.logger.renderer("Sending #{message}")
    ipcRenderer.send message,args

  receive: (message,callback) ->
    ipcRenderer.on message, (event,args...) =>
      chiika.logger.info("[blue](RENDERER) Receiving #{message}")
      callback(event,args...)

  sendReceiveIPC: (message,params,callback) ->
    defer = _when.defer()
    chiika.logger.info("[red](RENDERER) Sending #{message}")
    ipcRenderer.send message,params
    ipcRenderer.on message + "-response", (event,args...) =>
      chiika.logger.info("[blue](RENDERER) Receiving #{message}-response")
      callback(event,defer,args...)
    defer.promise
