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

path = require('path')
events = require('events')
fs = require('fs')

electron = require('electron')
app = electron.app
Tray = electron.Tray
BrowserWindow = electron.BrowserWindow

Positioner = require('electron-positioner')
_ = require 'lodash'


module.exports = class Menubar
  clickCount: 0,
  isPlayingVideo: false
  constructor: ->
    application.emitter.on 'mp-video-changed', =>
      @isPlayingVideo = true
    application.emitter.on 'mp-closed', =>
      @isPlayingVideo = false

  handleClick: (e,bounds) ->
    #Logic:
    #If a video is playing, single click opens menubar, double click opens main window
    #If video isn't playing, single click opens main window
    @clickCount++

    if @isPlayingVideo && @clickCount == 1
      @clicked(e,bounds)
    if @isPlayingVideo && @clickCount == 2
      application.showMainWindow()

    if !@isPlayingVideo && @clickCount == 1
      application.showMainWindow()

    clearClickCount = =>
      @clickCount = 0
    setTimeout( clearClickCount, 1000)

  clicked: (e, bounds) ->
    if (e.altKey || e.shiftKey || e.ctrlKey || e.metaKey)
      return @hideWindow()
    if (@menubar.window && @menubar.window.isVisible())
      return @hideWindow()
    cachedBounds = bounds || cachedBounds
    @showWindow(cachedBounds)
  create: (opts) ->
    if !opts?
      opts = {dir: app.getAppPath()}
    if typeof opts == 'string'
      opts = {dir: opts}
    if (!opts.dir)
      opts.dir = app.getAppPath()
    if (!(path.isAbsolute(opts.dir)))
      opts.dir = path.resolve(opts.dir)
    if (!opts.index)
      opts.index = 'file://' + path.join(opts.dir, 'index.html')
    if (!opts.windowPosition)
      if (process.platform == 'win32')
        opts.windowPosition = 'trayBottomCenter'
      else
         opts.windowPosition = 'trayCenter'
    if (typeof opts.showDockIcon == 'undefined')
      opts.showDockIcon = false

    opts.width = opts.width || 400
    opts.height = opts.height || 400
    opts.tooltip = opts.tooltip || ''

    @opts = opts

    app.on('ready', => @appReady() )

    @menubar = new events.EventEmitter()
    @menubar.app = app

    @menubar.setOption = (opt, val) ->
      @opts[opt] = val

    @menubar.getOption = (opt) ->
      @opts[opt]

    @menubar



  appReady: ->
    if (app.dock && !@opts.showDockIcon)
      app.dock.hide()

    iconPath = @opts.icon || path.join(@opts.dir, 'IconTemplate.png')

    if (!fs.existsSync(iconPath))
      iconPath = path.join(__dirname, 'example', 'IconTemplate.png')

    defaultClickEvent = 'click'

    @menubar.tray = @opts.tray || new Tray(iconPath)
    @menubar.tray.on(defaultClickEvent, (e,bounds) => @handleClick(e,bounds))
    #@menubar.tray.on('double-click', (e,bounds) => @clicked(e,bounds))
    @menubar.tray.setToolTip(@opts.tooltip)

    if @opts.preloadWindow
      @createWindow()

    @menubar.showWindow = @showWindow
    @menubar.hideWindow = @hideWindow
    @menubar.emit('ready')

  showWindow: (trayPos) ->
    if (!@menubar.window)
      @createWindow()

    @menubar.emit('show')

    if (trayPos && trayPos.x != 0)
      cachedBounds = trayPos
    else if (cachedBounds)
      trayPos = cachedBounds
    else if (@menubar.tray.getBounds)
      trayPos = @menubar.tray.getBounds()

    # Default the window to the right if `trayPos` bounds are undefined or null.
    noBoundsPosition = null
    if ((trayPos == undefined || trayPos.x == 0) && @opts.windowPosition.substring(0, 4) == 'tray')
      noBoundsPosition = (process.platform == 'win32') ? 'bottomRight' : 'topRight'

    position = @menubar.positioner.calculate(noBoundsPosition || @opts.windowPosition, trayPos)
    if (@opts.x != undefined)
      x = @opts.x
    else
      x = position.x

    if (@opts.y != undefined)
      y = @opts.y
    else
      y = position.y

    @menubar.window.setPosition(x, y)
    @menubar.window.show()
    @menubar.emit('after-show')
    return

  hideWindow: ->
    if (!@menubar.window)
      return
    @menubar.emit('hide')
    @menubar.window.hide()
    @menubar.emit('after-hide')

  windowClear: ->
    delete @menubar.window
    @menubar.emit('after-close')

  emitBlur: ->
    @menubar.emit('focus-lost')

  createWindow: () ->
    @menubar.emit('create-window')
    defaults = {
      show: false,
      frame: false
    }

    winOpts = _.assign defaults, @opts
    @menubar.window = new BrowserWindow(winOpts)

    @menubar.positioner = new Positioner(@menubar.window)

    @menubar.window.on 'blur', =>
      if @opts.alwaysOnTop
        @emitBlur()
      else
        @hideWindow()

    if (@opts.showOnAllWorkspaces != false)
      @menubar.window.setVisibleOnAllWorkspaces(true)

    @menubar.window.on('close', => @windowClear())
    @menubar.window.loadURL(@opts.index)
    @menubar.emit('after-create-window')
