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

{autoUpdater}           = require 'electron'
{Emitter,Disposable}    = require 'event-kit'

_forEach                = require 'lodash/collection/forEach'
_assign                 = require 'lodash.assign'
_when                   = require 'when'
_find                   = require 'lodash/collection/find'
_indexOf                = require 'lodash/array/indexOf'
string                  = require 'string'

module.exports = class UpdateManager
  constructor: ->
    if process.platform == 'linux'
      return
    @feed = "https://chiika.herokuapp.com/update/#{process.platform}/#{chiika.chiikaVer}"
    autoUpdater.setFeedURL("#{@feed}")

    @handleEvents()


  checkForUpdates: ->
    if process.platform == 'linux'
      return
    chiika.logger.info("Checking for updates...")
    try
      autoUpdater.checkForUpdates()
    catch error
      console.log error

  installUpdates: ->
    if process.platform == 'linux'
      return

    chiika.logger.info("Quitting and updating...")
    autoUpdater.quitAndInstall()


  sendToUpdaterWindow: (message,params) ->
    if @updaterWindow?
      @updaterWindow.webContents.send message,{ message: message, params: params }

  check: ->
    if process.platform == 'linux'
      return
    closeUpdateWindow = =>
      if @updaterWindow
        @updaterWindow.close()
        @updaterWindow = null

    hideUpdateWindow = =>
      if @updaterWindow
        @updaterWindow.hide()

      setTimeout(closeUpdateWindow,10000)



    updateError = chiika.emitter.on 'update-error', =>
      hideUpdateWindow()
      @sendToUpdaterWindow 'update-error'
      chiika.emitter.emit 'updater-ready'
      updateError.dispose()

    updateAvailable = chiika.emitter.on 'update-available', =>
      @sendToUpdaterWindow 'update-available'
      updateAvailable.dispose()

    updateDownloaded = chiika.emitter.on 'update-downloaded', =>
      @sendToUpdaterWindow 'update-downloaded'
      updateDownloaded.dispose()
      @installUpdates()

    updateNotAvailable = chiika.emitter.on 'update-not-available', =>
      @sendToUpdaterWindow 'update-not-available'
      hideUpdateWindow()
      chiika.emitter.emit 'updater-ready'
      updateNotAvailable.dispose()
    updateWindowReady = =>
      @checkForUpdates()

    @updaterWindow = chiika.updaterWindow(updateWindowReady)

  handleEvents: ->
    autoUpdater.on 'update-available', () =>
      chiika.logger.info("New update available!")
      chiika.emitter.emit 'update-available'

    autoUpdater.on 'update-downloaded', () =>
      chiika.logger.info("New update is downloaded!")
      chiika.emitter.emit 'update-downloaded'

    autoUpdater.on 'error', (e) =>
      chiika.logger.info("Update error!")
      chiika.emitter.emit 'update-error',e

    autoUpdater.on 'checking-for-update', () =>
      chiika.logger.info("Checking for updates on #{@feed}!")
      chiika.emitter.emit 'checking-for-update'

    autoUpdater.on 'update-not-available', () =>
      chiika.logger.info("No new update is available.")
      chiika.emitter.emit 'update-not-available'
