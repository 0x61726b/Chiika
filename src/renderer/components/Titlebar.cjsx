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
Titlebar = require 'arkenthera-titlebar'


remote = require 'remote'
BrowserWindow = remote.BrowserWindow;
app = remote.app;

class ChiikaTitlebar
  titlebar:null
  appendTitlebar: ->
    @titlebar = new Titlebar()
    @titlebar.appendTo(document.getElementById('titleBar'))

    @titlebar.on 'close', () ->
      remote.getCurrentWindow().close()
    @titlebar.on 'minimize', () ->
      remote.getCurrentWindow().minimize()
    @titlebar.on 'maximize', () ->
      remote.getCurrentWindow().maximize()



module.exports = ChiikaTitlebar
