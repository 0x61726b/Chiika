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
#Date: 25.1.2016
#authors: arkenthera
#Description:
#----------------------------------------------------------------------------
path = require 'path'
fs = require 'fs'
{BrowserWindow, ipcRenderer,remote} = require 'electron'
{Disposable} = require 'event-kit'

_ = require 'lodash'

class ApplicationDelegate
  reloadWindow: ->
    ipcRenderer.send("call-window-method", "reload")
  saveOptions: (options) ->
    ipcRenderer.send 'save-options',options
  openWindowDevTools: ->
    new Promise (resolve) ->
      process.nextTick ->
        if remote.getCurrentWindow().isDevToolsOpened()
          resolve()
        else
          remote.getCurrentWindow().once("devtools-opened", -> resolve())
          ipcRenderer.send("call-window-method", "openDevTools")

  closeWindowDevTools: ->
    new Promise (resolve) ->
      process.nextTick ->
        unless remote.getCurrentWindow().isDevToolsOpened()
          resolve()
        else
          remote.getCurrentWindow().once("devtools-closed", -> resolve())
          ipcRenderer.send("call-window-method", "closeDevTools")

  toggleWindowDevTools: ->
    new Promise (resolve) =>
      process.nextTick =>
        if remote.getCurrentWindow().isDevToolsOpened()
          @closeWindowDevTools().then(resolve)
        else
          @openWindowDevTools().then(resolve)

module.exports = ApplicationDelegate
