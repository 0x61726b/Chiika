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

{BrowserWindow,ipcMain,globalShortcut,Tray,Menu,app} = require 'electron'
_when = require 'when'

module.exports = class AppDelegate
  readyPromise: []
  run: ->
    @readyPromise.push @onReady()
    @windowsClosed()
    @willQuit()

  ready: (callback) ->
    _when.all(@readyPromise).then => callback()

  onReady: ->
    defer = _when.defer()
    shouldQuit = app.makeSingleInstance (commandLine, workingDirectory) =>
      console.log "second instance detected"
      if chiika.windowManager && chiika.windowManager.getWindowByName('main')
        mainWindow = chiika.windowManager.getWindowByName('main')

        if mainWindow? && mainWindow.isMinimized()
          mainWindow.restore()
        if mainWindow?
          mainWindow.focus()


    if shouldQuit
      app.quit()

    app.on 'ready', =>
      app.setAppUserModelId('com.arkenthera.chiika')
      chiika.settingsManager.initialize().then =>
        defer.resolve()
        chiika.logger.verbose("Electron app is ready")
    return defer.promise


  windowsClosed: ->
    app.on 'window-all-closed', ->
      chiika.logger.info("All windows are closed. Preparing exit...")
      app.quit()

  willQuit: ->
    app.on 'will-quit', () =>
      globalShortcut.unregisterAll()

      # chiika.apiManager.clearCache()
