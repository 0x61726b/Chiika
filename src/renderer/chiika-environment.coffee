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
{BrowserWindow, ipcRenderer,remote,shell} = require 'electron'

ChiikaDomManager = require './chiika-dom'
GridManager = require './grid-manager'
AnimeDetailsHelper = require './anime-details-helper'

_ = require 'lodash'
fs = require 'fs'
path = require 'path'

_when = require 'when'

class ChiikaEnvironment
  ipcListeners: [],
  isWaiting: true,
  apiEvents: [ 'downloadImage','downloadUserImage']
  constructor: (params={}) ->
    {@applicationDelegate, @window,@chiikaHome} = params

    # scribe = require 'scribe-js'
    # express = require 'express'
    #
    # scribe = scribe()
    # console = process.console

    @emitter          = new Emitter
    @domManager       = new ChiikaDomManager
    @gridManager      = new GridManager(this)
    @animeHelper      = new AnimeDetailsHelper


    #console.addLogger('rendererDebug','red')
    #console.addLogger('rendererInfo','blue')
    @logInfo("Renderer initializing...")


    ipcRenderer.on 'window-reload', (event,arg) =>
      @logDebug("IPC: window-reload")

    ipcRenderer.on 'request-search-response', (event,arg) =>
      @logDebug 'IPC: request-search-response'
      if _.isArray arg.results
        @logInfo "Search returned " + arg.results.length + " entries"
      else
        @logInfo "Search returned 1 entry"
      @emitter.emit 'anime-details-update'

    ipcRenderer.on 'download-image', (event,arg) =>
      @logDebug('IPC: download-image')
      @emitter.emit 'download-image' #This will cause to listeners of this message to react, see side-menu


    ipcRenderer.on 'request-anime-details-small-response', (event,arg) =>
      @animeDb = arg.newDb
      @emitter.emit 'anime-details-update', {updatedEntry: arg.updatedEntry }

    ipcRenderer.on 'request-anime-details-mal-page-response', (event,arg) =>
      @animeDb = arg.newDb
      @emitter.emit 'anime-details-update', {updatedEntry: arg.updatedEntry }

    ipcRenderer.on 'request-anime-cover-image-download-response', (event,arg) =>
      @logDebug('IPC: request-anime-cover-image-download-response')
      @emitter.emit 'download-image', { downloadedEntry: arg.animeId }

    ipcRenderer.on 'request-calendar-data-response', (event,arg) =>
      @logDebug('IPC: request-calendar-data-response')
      @calendarData = arg.calendarData
      @emitter.emit 'calendar-ready'

    #When the window is reloaded using Ctrl+R (which will never happen in prod environment),
    #renderer side of the application will request user data and app data such as user info,lists,app options
    #when reloading occurs,if the current route is one of the lists (anime,manga list), tables will be ready even before the data arrives at renderer process
    #In another words, if you refresh the app while looking at anime list,
    #when refreshing finishes anime list will be empty because data isn't arrived when the React's mount function called (didComponentMount)
    #To workaround this we first have to wait for the data to arrive at renderer process, then tell React to fill the table
    @ipcWaitforDeferredCalls().then( =>
      @isWaiting = false
      @emitter.emit 'chiika-ready'
      chiika.logInfo "Chiika-Ready"
      _.forEach @ipcListeners, (v,k) =>
        v.ipcCall()
    )
    ipcRenderer.send 'request-calendar-data'


  sendNotification: (notf) ->
    notf = new Notification('Test',{ body: 'Test notification sent by Chiika!', icon: 'D:/Arken/C++/ElectronProjects/Chiika/src/assets/images/chiika.png'})
  getWorkingDirectory: ->
    process.cwd()
  getResourcesPath: ->
    process.resourcesPath
  getUserTimezone: ->
    moment = require 'moment-timezone'
    userTimezone = moment.tz(moment.tz.guess())
    utcOffset = moment.parseZone(userTimezone).utcOffset() * 60# In seconds
    return { timezone: userTimezone , offset: utcOffset }
  getAnimeCoverById: (animeId) ->
    #This function will try to download the image if it doesn't exist locally
    coverPath = path.join(@chiikaHome,'Data','Images',animeId + '.jpg')
    coverExists = @checkIfFileExists coverPath



    if coverExists
      return coverPath

    chiika.logDebug("Cover for " + animeId + " doesn't exist.Requesting download..")
    #It doesn't exist at this point, let's download it.
    findAnimeEntry = _.find @animeDb.anime, { series_animedb_id: animeId }
    if findAnimeEntry && !coverExists
      ipcRenderer.send 'request-anime-cover-image-download', { animeId: animeId,coverLink: findAnimeEntry.series_image }
      return './../assets/images/avatar.jpg'
    if findAnimeEntry && coverExists
      return coverPath
    else
      chiika.logDebug("Image cover can't be retrieved. It doesn't exist in our database.")

  animeDetailsPreRequest: (animeId) ->
    #Check animeDb if this is required
    findAnimeEntry = _.find @animeDb.anime, { series_animedb_id: animeId }

    if findAnimeEntry? && !findAnimeEntry.series_english?
      chiika.logInfo "Search info not found, requesting update for " + animeId
      ipcRenderer.send('request-search-anime', {searchTerms: findAnimeEntry.series_title })

    if findAnimeEntry? && !findAnimeEntry.misc_genres?
      chiika.logInfo "Basic info not found, requesting update for " + animeId
      ipcRenderer.send('request-anime-details-small', { animeId: animeId})

    if findAnimeEntry? && !findAnimeEntry.misc_source
      chiika.logInfo "Requesting extra update for ." + animeId
      ipcRenderer.send('request-anime-details-mal-page', { animeId: animeId })




  getAnimeListByType: (status) ->
    data = []

    if @animeList?
      _.forEach(@animeList.anime, (value,k) =>
        animeStatus = value['my_status']

        animeDbResult = _.find(@animeDb.anime, { series_animedb_id: value.series_animedb_id} )

        if animeDbResult?
          $.extend(value,animeDbResult)
        else
          console.log "There is a problem with anime database."
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
          entry['animeProgress'] = progress
          entry['score'] = score
          entry['season'] = season
          entry['image'] = value.series_image
          entry['airingStatusText'] = airingStatusText
          entry['airingStatusColor'] = airingStatusColor
          data.push entry
      )
      data
  getAnimeById: (id) ->
    anime = { }
    if @animeList?
      animeListEntry = _.find @animeList.anime, { series_animedb_id: id }

      if animeListEntry?
        $.extend anime,animeListEntry
    if @animeDb?
      animeDbEntry = _.find @animeDb.anime, { series_animedb_id: id }
      if animeDbEntry?
        $.extend anime,animeDbEntry
    anime
  openMalLink: ->
    shell.openExternal("http://myanimelist.net/anime/" + @anime.anime.series_animedb_id)


  ipcGetOptions: ->
    deferred = _when.defer()
    ipcRenderer.send('get-options')

    ipcRenderer.on 'get-options-response', (event,arg) =>
      @appOptions = arg
      @gridManager.prepareGridData @appOptions
      deferred.resolve()

    deferred.promise


  logDebug: (text) ->
    #process.console.tag("chiika-renderer").rendererDebug(text)
    console.log text
  logInfo: (text) ->
    #process.console.tag("chiika-renderer").rendererInfo(text)
    console.log text

  checkIfFileExists: (fileName) ->
    try
      file = fs.statSync fileName
    catch e
      file = undefined
    if _.isUndefined file
      return false
    else
      return true
  ipcWaitforDeferredCalls: ->
    Dfs = []

    Dfs.push @ipcGetUserInfo()
    Dfs.push @ipcGetAnimelist()
    Dfs.push @ipcGetOptions()
    Dfs.push @ipcGetAnimeDb()
    Dfs.push @ipcGetLoginStatus()


    _when.all Dfs

  ipcGetLoginStatus: ->
    deferred = _when.defer()
    ipcRenderer.send 'get-login-status'

    ipcRenderer.on 'get-login-status-response', (event,arg) =>
      console.log "get-login-status-response"
      deferred.resolve()
    deferred.promise

  ipcGetUserInfo: ->
    deferred = _when.defer()
    ipcRenderer.send('get-user-info')

    ipcRenderer.on 'get-user-info-response', (event,arg) =>
      @user = arg
      @domManager.setUserInfo @user
      deferred.resolve()
      #@emitter.emit 'download-image' #Little hack, sidebar depends on user ID , so its safe to update it when we have user here
    deferred.promise

  ipcGetAnimelist: ->
    deferred = _when.defer()
    ipcRenderer.send('db-request-animelist',{ userName: ''})
    ipcRenderer.on 'request-animelist-response', (event,arg) =>
      if arg.success
        @animeList = arg.list
        console.log @animeList
      else
        chiika.logInfo "Retrieving animelist resulted with error. " + arg.response.errorMessage + " " + arg.response.body
      deferred.resolve()
    deferred.promise
  ipcGetAnimeDb: ->
    deferred = _when.defer()
    ipcRenderer.send('db-request-anime')
    ipcRenderer.on 'request-animedb-response', (event,arg) =>
      @animeDb = arg.list
      console.log @animeDb
      deferred.resolve()
    deferred.promise
  devRequestAnimelist: ->
    ipcRenderer.send('request-animelist',{ userName: ''})

  devRequestAnimeSearch: (search) ->
    ipcRenderer.send('request-search-anime', {searchTerms: search })

module.exports = ChiikaEnvironment
