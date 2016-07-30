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
{BrowserWindow, ipcRenderer,remote,shell} = require 'electron'


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


  refreshViewByName: (name) ->
    @sendReceiveIPC 'refresh-view-by-name',name, (event,args,defer) =>
      console.log "refresh-view-by-name hello"

  sendReceiveIPC: (message,params,callback) ->
    defer = _when.defer()
    ipcRenderer.send message,params
    ipcRenderer.on message + "-response", (event,args...) =>
      callback(event,args...,defer)
    defer.promise
