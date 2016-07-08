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
{Emitter} = require 'event-kit'
ipcHelpers = require '../ipcHelpers'
{BrowserWindow, ipcRenderer,remote} = require 'electron'

ChiikaDomManager = require './chiika-dom'
GridManager = require './grid-manager'

_ = require 'lodash'

_when = require 'when'

class ChiikaEnvironment
  ipcListeners: [],
  isWaiting: true
  constructor: (params={}) ->
    {@applicationDelegate, @window,@configDirPath} = params


    scribe = require 'scribe-js'
    express = require 'express'

    scribe = scribe()
    console = process.console

    @emitter          = new Emitter
    @domManager       = new ChiikaDomManager
    @gridManager      = new GridManager


    console.addLogger('rendererDebug','red')
    @logDebug("Renderer initializing...")


    ipcRenderer.on 'window-reload', (event,arg) =>
      @logDebug("window-reload")

    #When the window is reloaded using Ctrl+R (which will never happen in prod environment),
    #renderer side of the application will request user data and app data such as user info,lists,app options
    #when reloading occurs,if the current route is one of the lists (anime,manga list), tables will be ready even before the data arrives at renderer process
    #In another words, if you refresh the app while looking at anime list,
    #when refreshing finishes anime list will be empty because data isn't arrived when the React's mount function called (didComponentMount)
    #To workaround this we first have to wait for the data to arrive at renderer process, then tell React to fill the table
    @ipcWaitforDeferredCalls().then( =>
      @isWaiting = false
      _.forEach @ipcListeners, (v,k) =>
        v.ipcCall()
    )

  ipcWaitforDeferredCalls: ->
    Dfs = []

    Dfs.push @ipcGetUserInfo()
    Dfs.push @ipcGetAnimelist()
    Dfs.push @ipcGetOptions()

    _when.all Dfs

  ipcGetUserInfo: ->
    deferred = _when.defer()
    ipcRenderer.send('get-user-info')

    ipcRenderer.on 'get-user-info-response', (event,arg) =>
      @user = arg
      @domManager.setUserInfo @user
      deferred.resolve()
    deferred.promise

  ipcGetAnimelist: ->
    deferred = _when.defer()
    ipcRenderer.send('db-request-animelist',{ userName: 'arkenthera'})
    ipcRenderer.on 'request-animelist-response', (event,arg) =>
      @animeList = arg
      console.log "???"
      deferred.resolve()
      console.log @animeList
    deferred.promise

  ipcGetOptions: ->
    deferred = _when.defer()
    ipcRenderer.send('get-options')

    ipcRenderer.on 'get-options-response', (event,arg) =>
      @appOptions = arg
      @gridManager.prepareGridData @appOptions
      deferred.resolve()

    deferred.promise


  logDebug: (text) ->
    process.console.tag("chiika-renderer").rendererDebug(text)
  getAnimeListByType: (status) ->
    data = []

    if @animeList?
      _.forEach(@animeList[0].anime, (value,k) ->
        animeStatus = value['my_status']
        if parseInt(animeStatus) == status #Watching
          entry = {}
          animeTitle = value['series_title']
          watchedEps = value['my_watched_episodes']
          totalEps   = value['series_episodes']
          serieStatus = value['series_status']
          progress   = 0
          if parseInt(totalEps) > 0
            progress   = Math.ceil((parseInt(watchedEps) / parseInt(totalEps)) * 100)

          startDate = value.series_start

          parts = startDate.split("-");
          year = parts[0];
          month = parts[1];

          iMonth = parseInt(month);

          season = "Unknown"
          if iMonth > 0 && iMonth < 4
            season =  "Winter " + year
          if iMonth > 3 && iMonth < 7
            season =  "Spring " + year
          if iMonth > 6 && iMonth < 10
            season =  "Summer " + year
          if iMonth > 9 && iMonth <= 12
            season = "Fall " + year

          score      = value['my_score']

          if score == "0"
            score = "-"

          airingStatusColor = ""
          airingStatusText = ""
          if serieStatus == "0"
            airingStatusText = "Not Aired"
            airingStatusColor = "gray"
          if serieStatus == "1"
            airingStatusText = "Airing"
            airingStatusColor = "green"
          if serieStatus == "2"
            airingStatusText = "Finished"
            airingStatusColor = "black"




          type = value['series_type']
          typeText = ""
          animeType = "fa fa-question"
          if type == "0"
           animeType = "fa fa-question"
           typeText = "Unknown"
          if type == "1"
           animeType = "fa fa-tv"
           typeText = "Tv"
          if type == "2"
           animeType = "glyphicon glyphicon-cd"
           typeText = "Ova"
          if type == "3"
           animeType = "fa fa-film"
           typeText = "Movie"
          if type == "4"
           animeType = "fa fa-star"
           typeText = "Special"
          if type == "5"
           animeType = "fa fa-chrome"
           typeText = "Ona"
          if type == "6"
           animeType = "fa fa-music"
           typeText = "Music"

          entry['animeId'] = value.series_animedb_id
          entry['recid'] = data.length
          entry['typeWithText'] = typeText
          entry['icon'] = animeType
          entry['title'] = animeTitle
          entry['progress'] = progress
          entry['score'] = score
          entry['season'] = season
          entry['airingStatusText'] = airingStatusText
          entry['airingStatusColor'] = airingStatusColor
          data.push entry
      )
      data

module.exports = ChiikaEnvironment
