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
#
#
#--------------------
#
#--------------------
app = require "app"
BrowserWindow = require 'browser-window'
crashReporter = require 'crash-reporter'

ApplicationWindow = require './ApplicationWindow'
appMenu = require './menu/appMenu'
Menu = require 'menu'


# ---------------------------
#
# ---------------------------
process.on('uncaughtException',(err) -> console.log err)

module.exports =
class Application
  window: null

  constructor: (options) ->
    global.application = this
    global.Chiika = { Request:null}
    # Report crashes to our server.
    require('crash-reporter').start()



    # Quit when all windows are closed.
    app.on 'window-all-closed', -> app.quit()
    app.on 'ready', => @openWindow()

  openWindow: ->
    isBorderless = true

    if process.env.Show_CA_Debug_Tools == 'yeah'
      isBorderless = false;
    htmlURL = "file://#{__dirname}/../renderer/index.html"
    @window = new ApplicationWindow htmlURL,
      width: 1600
      height: 900
      minWidth:800
      minHeight:600
      title: 'Chiika - Development Mode'
      icon: "./resources/icon.png"
      frame:!isBorderless
    @window.openDevTools()

    if process.env.Show_CA_Debug_Tools == 'yeah'
      Menu.setApplicationMenu(appMenu)





application = new Application
