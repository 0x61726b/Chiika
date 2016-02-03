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
RouteManager = require './../../Search'

AnimelistStatusbar = React.createClass
  getAnimeId: ->
    path = RouteManager.activePath
    v = path.split("/")
    v[2]
  refresh: () ->
    activeRoute = RouteManager.activeRoute

    if activeRoute == 8 #Details is active
      animeId = @getAnimeId()
      console.log "Refreshing.... AnimeId:" + animeId
      Chiika.requestAnimeRefresh(animeId)
    if activeRoute == 1 #Anime List is active
      console.log "Syncing anime list..."
      Chiika.requestMyAnimelist()
  render: () ->
    (<div>This bar is active when its Anime List or Details
    <div className="animelistStatusbar">
      <div className="animelistIcons">
        <div onClick={@refresh}><i className="fa fa-refresh"></i></div>
      </div>
    </div></div>);

module.exports = AnimelistStatusbar
