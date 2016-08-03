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

  getUIData: ->
    @preloadPromises.push @sendReceiveIPC 'get-ui-data',{}, (event,defer,args) =>
      defer.resolve()
      console.log args


  getUsers: ->
    @preloadPromises.push @sendReceiveIPC 'get-user-data',{}, (event,defer,args) =>
      defer.resolve()
      console.log args


  refreshViewByName: (name) ->
    @sendReceiveIPC 'refresh-view-by-name',name, (event,args,defer) =>
      console.log "refresh-view-by-name hello"


  openLoginWindow: ->
    @sendMessage 'window-method','show','login'



  reconstructUI: () ->
    @sendMessage 'reconstruct-ui'


  sendMessage: (message,args...) ->
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
