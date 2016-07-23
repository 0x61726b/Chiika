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

React = require('react')
{Router,Route,BrowserHistory,Link} = require('react-router')
ReactDOM = require("react-dom")

{BrowserWindow, ipcRenderer,remote} = require 'electron'

AnimeDetailsHelper = require './anime-details-helper'

_ = require 'lodash'
fs = require 'fs'
path = require 'path'

#Views

Menubar = React.createClass
  currentVideoFile:null
  animeData: { listEntry: {}}
  componentWillMount: ->
    @animeHelper = new AnimeDetailsHelper
  componentDidMount: ->
    ipcRenderer.send 'request-video-info'
    ipcRenderer.on 'mp-set-video-info', (event,data) =>
      console.log "mp-set-video-info"
      @animeData = data
      console.log @animeData
      @forceUpdate()
      #@animeDetailsPreRequest data


    ipcRenderer.on 'request-anime-details-small-response', (event,arg) =>
      @onAnimeEntryUpdate {updatedEntry: arg.updatedEntry }

    ipcRenderer.on 'request-anime-details-mal-page-response', (event,arg) =>
      @onAnimeEntryUpdate {updatedEntry: arg.updatedEntry }

    ipcRenderer.on 'request-animedb-response', (event,arg) =>
      @forceUpdate()
    ipcRenderer.on 'request-anime-cover-image-download-response', (event,arg) =>
      console.log ('IPC: request-anime-cover-image-download-response')
      @forceUpdate()

  onAnimeEntryUpdate: (result) ->
    @animeData.listEntry = result.updatedEntry
    @forceUpdate()
  animeDetailsPreRequest: (anime) ->
    if anime.list && anime.db && !anime.listEntry.series_english?
      console.log "Search info not found, requesting update for " + anime.listEntry.series_animedb_id
      ipcRenderer.send('request-search-anime', {searchTerms: anime.listEntry.series_title })

    if anime.list && anime.db && !anime.listEntry.misc_genres?
      console.log "Basic info not found, requesting update for " + anime.listEntry.series_animedb_id
      ipcRenderer.send('request-anime-details-small', { animeId: anime.listEntry.series_animedb_id })

    if anime.list && anime.db && !anime.listEntry.misc_source
      console.log "Requesting extra update for ." + anime.listEntry.series_animedb_id
      ipcRenderer.send('request-anime-details-mal-page', { animeId: anime.listEntry.series_animedb_id })
  getAnimeCover: (animeData) ->
    console.log animeData
    if !animeData.list || !animeData.db
      return './../assets/images/avatar.jpg'

    anime = animeData.listEntry
    animeId = anime.series_animedb_id
    #This function will try to download the image if it doesn't exist locally
    coverPath = path.join(process.env.CHIIKA_HOME,'Data','Images',anime.series_animedb_id + '.jpg')
    coverExists = @checkIfFileExists coverPath



    if coverExists
      return coverPath

    console.log("Cover for " + animeId + " doesn't exist.Requesting download..")
    #It doesn't exist at this point, let's download it.
    if anime && !coverExists
      ipcRenderer.send 'request-anime-cover-image-download', { animeId: animeId,coverLink: anime.series_image }
      return './../assets/images/avatar.jpg'
    if findAnimeEntry && coverExists
      return coverPath
    else
      console.log("Image cover can't be retrieved. It doesn't exist in our database.")
  getCurrentEpisodeNumber: ->
    if @animeData.parseInfo?
      @animeData.parseInfo.EpisodeNumber
    else
      "??"
  checkIfFileExists: (fileName) ->
    try
      file = fs.statSync fileName
    catch e
      file = undefined
    if _.isUndefined file
      return false
    else
      return true
  onOpenMal: (e) ->
    @animeHelper.openAnimeOnMal(@animeData.listEntry)
  onGoDetails: (e) ->
    if @animeData.listEntry.series_animedb_id?
      ipcRenderer.send 'request-navigate-route','/Anime/' + @animeData.listEntry.series_animedb_id
      remote.BrowserWindow.hide()
  render: () ->
    (<div className="menubar-container" id="menubarMain">
  		<div className="menubar-content">
  			<div className="menubar-title">
  				<div id="menubar-nowPlaying">
  					<span><i className="fa fa-play fa-1x"></i></span>
  					<h3>Now Playing: {@getCurrentEpisodeNumber()}/{@animeHelper.getSeriesEpisodes(@animeData.listEntry)}</h3>
  				</div>
  				<div className="menubar-icon" id="threeDot"><i className="fa fa-ellipsis-v" id="menubar-shareIcon"></i></div>
  			</div>
  			<div className="menubar-infoContainer">
  				<div className="menubar-imageContainer">
  					<img src={ @getAnimeCover(@animeData)} style={{width: 109}} />
  				</div>
  				<div className="menubar-infoColumn">
  					<div className="menubar-animeTitle">
  						<h4>{ @animeHelper.getTitle(@animeData.listEntry) }</h4>
  					</div>
  					<div className="menubar-info">
  						<div className="menubar-info-text">
  							<span><p><b>type: </b>{ @animeHelper.getType(@animeData.listEntry)}</p></span>
  							<span><p><b>score: </b>{ @animeHelper.getScore(@animeData.listEntry)}</p></span>
  							<span><p><b>studıo: </b>{ @animeHelper.getStudioName(@animeData.listEntry)}</p></span>
  							<span><p><b>source: </b>{ @animeHelper.getSource(@animeData.listEntry)}</p></span>
  							<span><p><b>season: </b>{ @animeHelper.getSeason(@animeData.listEntry)}</p></span>
  						</div>
  						<div className="menubar-info-button">
  							<button className="menubar-button" onClick={@onOpenFolder}>
  								<p>Open Folder</p>
  							</button>
  							<button className="menubar-button" onClick={@onOpenMal}>
  								<p>open on mal</p>
  							</button>
  							<button className="menubar-button" onClick={@onGoDetails}>
  								<p>go to details</p>
  							</button>
  						</div>
  					</div>
  				</div>
  			</div>
  		</div>
  		<div className="context-div" id="contextDiv">
  			<ul>
  				<li>Twitter</li>
  				<li>IRC</li>
  				<li>Google+</li>
  			</ul>
  		</div></div>)

ReactDOM.render(React.createElement(Menubar), document.getElementById('app'))
