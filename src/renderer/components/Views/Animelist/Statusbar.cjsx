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
RouteManager = require './../../RouteManager'

AnimelistStatusbar = React.createClass
  getAnimeId: ->
    path = chiika.routeManager.activePath
    v = path.split("/")
    v[2]
  refresh: (e) ->
    activeRoute = chiika.routeManager.activeRoute

    if activeRoute == 8 #Details is active
      animeId = @getAnimeId()
      console.log "Refreshing.... AnimeId:" + animeId
      chiika.appDel.requestRefreshAnimeDetails(animeId)
    if activeRoute == 1 #Anime List is active
      if $(e.target).attr('disabled') != 'disabled'
        console.log "Syncing anime list..."
        Chiika.requestMyAnimelist()
        @disableButton(e.target)
   disableButton: (btn) ->
     $(btn).addClass('iconDisabled')
           .delay(2000)
           .queue( -> $(btn).removeClass('iconDisabled').dequeue() )

  render: () ->
    (<div id="animelistStatusbar">
    <div className="animelistStatusbar">
      <div className="animelistIcons">
        <div onClick={@refresh} id="syncAnimelistButton"><i className="fa fa-refresh"></i></div>
      </div>
    </div></div>);

module.exports = AnimelistStatusbar
