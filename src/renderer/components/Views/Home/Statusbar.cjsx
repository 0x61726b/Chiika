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

HomeStatusbar = React.createClass
  currentTheme:"Default"
  nextTheme:0
  changeStyle: () ->
    styles = [ 'Green','Default','Orange','Yellow']

    newTheme = styles[@nextTheme]

    console.log newTheme
    $('link[href="../styles/Main'+@currentTheme+'.css"]').attr('href','../styles/Main'+newTheme+'.css')
    @currentTheme = newTheme
    @nextTheme = @nextTheme + 1

    if @nextTheme >= 3
      @nextTheme = 0

  render: () ->
    (<div>
      <div onClick={@changeStyle}><i className="fa fa-refresh"></i>Change theme</div>
    </div>);

module.exports = HomeStatusbar
