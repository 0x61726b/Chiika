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
ipcHelpers = require '../ipcHelpers'
{BrowserWindow, ipcRenderer,remote} = require 'electron'

ChiikaDomManager = require './chiika-dom'

class ChiikaEnvironment
  constructor: (params={}) ->
    {@applicationDelegate, @window,@configDirPath} = params


    scribe = require 'scribe-js'
    express = require 'express'

    scribe = scribe()
    console = process.console

    @emitter = new Emitter
    @domManager = new ChiikaDomManager


    console.addLogger('rendererDebug','red')
    @logDebug("Renderer initializing...")

    ipcRenderer.on 'get-user-info-response', (event,arg) =>
      @user = arg
      @domManager.setUserInfo @user

    ipcRenderer.on 'window-reload', (event,arg) =>
      @logDebug("window-reload")
      @reset()


  reset: ->
    ipcRenderer.send('get-user-info')

  logDebug: (text) ->
    process.console.tag("chiika-renderer").rendererDebug(text)

module.exports = ChiikaEnvironment
