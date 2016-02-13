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
#Date: 25.1.2016
#authors: arkenthera
#Description:
#----------------------------------------------------------------------------
path = require('path')
fs = require('fs')
remote = require('remote')
electron = require 'electron'
ipcRenderer = electron.ipcRenderer
RouteManager = require './components/RouteManager'
BrowserWindow = electron.remote.BrowserWindow

ApplicationDelegate = require './ApplicationDelegate'
ChiikaEnvironment = require './ChiikaEnvironment'

_ = require 'lodash'

{Emitter} = require 'event-kit'

class ChiikaRenderer
  DbIpcKeys:[
    'databaseRequest'
  ],
  IpcKeys:[
    'requestVerify',
    'requestMyAnimelist',
    'requestMyMangalist',
    'requestAnimeScrape'
  ]
  ipcStatus:[],
  apiBusy:false
  readyCallback:null
  databaseMyUserInfo:null
  databaseMyAnimelist:null
  databaseMyMangalist:null
  databaseSenpai:null
  firstLaunch:true
  initialized:false
  chiikaNode:null
  listener:null
  keyboardListenerMap:new Map()
  requestListenerMap:new Map()

  #Send browser async requests to retrieve data
  constructor: ->
    @appDel       =   new ApplicationDelegate()
    @routeManager =   new RouteManager()

    window.chiika =   new ChiikaEnvironment(this,@appDel,@routeManager)

    @appDel.handleEvents()

    chiika.onChiikaReady =>
      chiika.setApiBusy true

  openMyAnimeListLoginWindow: () ->
    options = {
       frame:false,
       width:600,
       height:600,
       icon:'./resources/icon.png'
    }
    LoginWindow = new BrowserWindow(options);
    LoginWindow.loadURL("file://#{__dirname}/../renderer/MyAnimeListLogin.html")
    LoginWindow.on 'closed', () ->
      LoginWindow = null

  requestVerifyUser: ->
    ipcRenderer.send 'rendererPing',@IpcKeys[0]

  requestMyAnimelist: () ->
    ipcRenderer.send 'rendererPing',@IpcKeys[1]



  requestMyMangalist: ->
    ipcRenderer.send 'rendererPing',@IpcKeys[2]

  requestAnimeScrape: (id) ->
    ipcRenderer.send 'requestAnimeScrape',id

  requestAnimeRefresh:(id) ->
    ipcRenderer.send 'requestAnimeRefresh',id

  requestAnimeUpdate:(id,score,progress,status) ->
    ipcRenderer.send 'requestAnimeUpdate', {animeId: id,score:score,progress:progress,status:status}

  dbUpdateAnime: (anime) ->
    wholeList = chiika.dbAnimelist['AnimeArray']
    console.log anime
    if wholeList? && anime?
      key = {'series_animedb_id':anime.series_animedb_id}
      updateAnime = _.find( wholeList , key)

      if updateAnime?
        index = _.indexOf(wholeList,_.find( wholeList, key ))
        chiika.dbAnimelist['AnimeArray'].splice(index,1,anime)

  getReady: (callback) ->
    @readyCallback = callback
  testListener: () ->
    @listener.trigger()

  #Helpers functions for Lists
  #The return value is formatted to match the grid
  getAnimeListByUserStatus:(status) ->
    data = []

    if chiika.dbAnimelist?
      wholeList = chiika.dbAnimelist
      for value in wholeList['AnimeArray']
       animeStatus = value['my_status']
       if parseInt(animeStatus) == status #Watching
         entry = {}
         animeTitle = value.anime['series_title']
         watchedEps = value['my_watched_episodes']
         totalEps   = value.anime['series_episodes']
         serieStatus = value.anime['series_status']
         progress   = 0
         if parseInt(totalEps) > 0
           progress   = Math.ceil((parseInt(watchedEps) / parseInt(totalEps)) * 100)

         startDate = value.anime.series_start

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




         type = value.anime['series_type']
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
      data


  addRequestListener:(name,listener) ->
    @requestListenerMap.set(name,listener)
    console.log "Registering " + name + " for request listening"
  removeRequestListener:(name) ->
    @requestListenerMap.delete(name)
    console.log "Removing " + name + " for request listening"

  notifyRequestListeners: (request) ->
    @requestListenerMap.forEach (value,key) =>
      value.onRequest request
  onRequestComplete: (request) ->
    @requestListenerMap.forEach (value,key) =>
      value[request]()

  getMangaListByUserStatus:(status) ->
      data = []

      wholeList = chiika.dbMangalist
      for value in wholeList['MangaArray']
       mangaStatus = value['my_status']
       if parseInt(mangaStatus) == status
         entry = {}
         title = value.manga['series_title']
         readChapters = value['my_read_chapters']
         readVolumes = value['my_read_volumes']
         totalVols   = value.manga['series_volumes']
         totalChaps = value.manga['series_chapters']
         serieStatus = value.manga['series_status']
         progress   = 0



         score      = value['my_score']

         if score == '0'
           score = 0
         else
           score = parseInt(score)

         if parseInt(totalChaps) == 0
           totalChaps = '-'
         if parseInt(totalVols) == 0
           totalVols = '-'
         chapters = readChapters + "/" + totalChaps;
         volumes = readVolumes + "/" + totalVols;
         entry['recid'] = data.length
         entry['chapters'] = chapters
         entry['title'] = title
         entry['volumes'] = volumes
         entry['score'] = score
         data.push entry
      data

  getAnimeById:(id) ->
    wholeList = chiika.dbAnimelist
    anime = null
    if wholeList?
      for value in wholeList['AnimeArray']
        if parseInt(value['series_animedb_id']) == parseInt(id)
          anime = value

      anime
#Export
module.exports = ChiikaRenderer
