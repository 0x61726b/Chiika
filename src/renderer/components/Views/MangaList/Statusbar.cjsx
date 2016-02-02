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
#Date: 2.2.2016
#authors: arkenthera
#Description:
#----------------------------------------------------------------------------
React = require 'react'
electron = require 'electron'
Chiika = require './../../../ChiikaNode'
electron = require 'electron'
ipcRenderer = electron.ipcRenderer

MangaStatusbar = React.createClass
  render: () ->
    (<div><div onClick={@refresh}><i className="fa fa-refresh"></i>Manga Statusbar here</div></div>);

module.exports = MangaStatusbar
