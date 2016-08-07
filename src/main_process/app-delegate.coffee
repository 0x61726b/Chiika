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

  onAppReady: ->
    defer = _when.defer()
    chiika.settingsManager.initialize().then =>
      defer.resolve()
      chiika.logger.verbose("Electron app is ready")

      loginWindow = chiika.windowManager.createWindowAndOpen(false,false,{
        name: 'login',
        width: 1600,
        height: 900,
        title: 'Huehueheuehueheu',
        icon: "resources/icon.png",
        url: "file://#{__dirname}/../static/LoginWindow.html",
        show: false,
        loadImmediately: true
        })


      mainWindow = chiika.windowManager.createWindowAndOpen(true,false,{
        name: 'main',
        width: 1400,
        height: 900,
        title: 'HUehueheuhue',
        icon: "resources/icon.png",
        url: "file://#{__dirname}/../static/index.html#Home"
        show: false,
        loadImmediately: false
        })

      loadingWindow = chiika.windowManager.createWindowAndOpen(false,true,{
        name: 'loading',
        width: 600,
        height: 400,
        title: 'Chiika',
        icon: "resources/icon.png",
        url: "file://#{__dirname}/../static/LoadingWindow.html",
        show: true,
        loadImmediately: true
        })

      chiika.windowManager.openDevTools(mainWindow)
      chiika.windowManager.openDevTools(loginWindow)

      chiika.settingsManager.applySettings()


  onReady: ->
    defer = _when.defer()
    app.on 'ready', =>
      chiika.settingsManager.initialize().then =>
        defer.resolve()
        chiika.logger.verbose("Electron app is ready")

        loginWindow = chiika.windowManager.createWindowAndOpen(false,false,{
          name: 'login',
          width: 1600,
          height: 900,
          title: 'Huehueheuehueheu',
          icon: "resources/icon.png",
          url: "file://#{__dirname}/../static/LoginWindow.html",
          show: false,
          loadImmediately: true
          })


        mainWindow = chiika.windowManager.createWindowAndOpen(true,false,{
          name: 'main',
          width: 1400,
          height: 900,
          title: 'HUehueheuhue',
          icon: "resources/icon.png",
          url: "file://#{__dirname}/../static/index.html#Home"
          show: false,
          loadImmediately: false
          })

        loadingWindow = chiika.windowManager.createWindowAndOpen(false,true,{
          name: 'loading',
          width: 600,
          height: 400,
          title: 'Chiika',
          icon: "resources/icon.png",
          url: "file://#{__dirname}/../static/LoadingWindow.html",
          show: true,
          loadImmediately: true
          })

        chiika.windowManager.openDevTools(mainWindow)
        chiika.windowManager.openDevTools(loginWindow)

        chiika.settingsManager.applySettings()
    return defer.promise


  windowsClosed: ->
    app.on 'window-all-closed', ->
      chiika.logger.info("All windows are closed. Preparing exit...")
      app.quit()

  willQuit: ->
    app.on 'will-quit', () =>
      globalShortcut.unregisterAll()

      chiika.apiManager.clearCache()
