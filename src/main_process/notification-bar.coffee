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

electron                            = require 'electron'
{BrowserWindow,ipcMain,Tray,Menu}   = require 'electron'
path = require 'path'

_forEach                = require 'lodash.foreach'
_assign                 = require 'lodash.assign'
_when                   = require 'when'
string                  = require 'string'

module.exports = class NotificationBar
  notfWindow: null
  enableNotfBar: false
  clickCount: 0

  hide: ->
    chiika.logger.info("Hide notification bar")
    @notfWindow.hide()

  show: ->
    chiika.logger.info("Show notification bar")
    @notfWindow.show()


  #
  #
  #
  close: ->
    if @notfWindow?
      @enableNotfBar = false

      @notfWindow.close()
      @notfWindow = null

      chiika.logger.info("Closing notification bar")

  #
  #
  #
  createTray: ->
    @tray = new Tray(path.join(__dirname,'..','assets/icon.png'))

    contextMenu = Menu.buildFromTemplate([
      { label: 'Quit Chiika', type: 'normal', role: 'quit'}
      ])
    @tray.setContextMenu(contextMenu)

    @tray.on 'click', =>
      if @enableNotfBar
        @show()
      else
        chiika.windowManager.getWindowByName('main').show()

    @tray.on 'double-click', =>
      if @enableNotfBar
        chiika.windowManager.getWindowByName('main').show()

    chiika.logger.info("Created tray")

  #
  #
  #
  create: ->
    if process.platform != "win32" && process.platform != "darwin"
      return
    @createTray()

  #
  #
  #
  sendMessage: (message,args) =>
    @notfWindow.webContents.send message,args


  #
  #
  #
  doCreate: (callback,size) ->
    # Recognized
    # 400 200
    width = 400
    height = size


    notificationWindow = new BrowserWindow {
      width: width,
      height: height,
      title: 'notification',
      x:0,
      y:0,
      frame: false,
      show:false,
      resizable: false,
      movable: false,
      alwaysOnTop: true,
      transparent: !chiika.settingsManager.getOption('NoTransparentWindows')
    }
    @notfWindow = notificationWindow
    @notfWindow.setSkipTaskbar(true)

    @notfWindow.loadURL("file://#{__dirname}/../static/notification.html")

    @enableNotfBar = true

    display = electron.screen.getPrimaryDisplay().workAreaSize

    position = {}
    defaultPosition = { x: display.width - width, y: (display.height - height) }
    position = defaultPosition

    if process.platform != 'linux'
      trayBounds = @tray.getBounds()


      position.x = defaultPosition.x - trayBounds.width
      position.y = trayBounds.y - height

    console.log position
    @notfWindow.setPosition(position.x,position.y)
    @notfWindow.on 'ready-to-show', =>
      @notfWindow.setPosition(position.x,position.y)
      @notfWindow.show()

      callback?()

    @notfWindow.on 'close', (event) =>
      if @enableNotfBar
        event.preventDefault()

      # hideAfterSomeTime = =>
      #   @hide()
      # setTimeout(hideAfterSomeTime,5000)

    @notfWindow.on 'closed', ->
      @notfWindow = null
      @enableNotfBar = false
