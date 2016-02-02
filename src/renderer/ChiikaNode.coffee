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
h = require './components/Helpers'
BrowserWindow = electron.remote.BrowserWindow

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
  firstLaunch:true
  initialized:false
  chiikaNode:null
  listener:null
  requestData: () ->
    @apiBusy = true
    ipcRenderer.send 'rendererPing','databaseRequest'

  #Send browser async requests to retrieve data
  constructor: ->
    @requestData()

  #Check if browser answered everything
  isInitialized: () ->
    @initialized

  setApiBusy:(busy) ->
    @apiBusy = busy
    h.SetApiBusy(@apiBusy)


  checkApiBusy: () ->
    if @isInitialized() == false
      @apiBusy = true

    h.SetApiBusy(@apiBusy)

    if @isInitialized()
      if @readyCallback
        @readyCallback()
        @readyCallback = null
      @setSidebarInfo()

  openMyAnimeListLoginWindow: () ->
    options = {
       frame:false,
       width:600,
       height:600,
       icon:'./resources/icon.png'
    }
    LoginWindow = new BrowserWindow(options);
    LoginWindow.loadURL("file://#{__dirname}/../renderer/MyAnimeListLogin.html")
    #LoginWindow.openDevTools()
    LoginWindow.on 'closed', () ->
      LoginWindow = null

  setSidebarInfo: () ->
    if @getUserInfo().UserInfo.user_name == 'undefined' || @getUserInfo().UserInfo.user_id == 'user_id'
      $("div.userInfo").html("No User")
    else
      $("div.userInfo").html(@getUserInfo().UserInfo.user_name)
      imageUrl = @chiikaNode.rootOptions.imagePath + @getUserInfo().UserInfo.user_id+".jpg"

      $("img#userAvatar").attr('src',imageUrl)

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

  requestAnimeDetails:(id) ->
    ipcRenderer.send 'requestAnimeDetails',id

  getMyAnimelist:() ->
    @databaseMyAnimelist
  getMyMangalist:() ->
    @databaseMyMangalist
  getUserInfo:() ->
    @databaseMyUserInfo

  getReady: (callback) ->
    @readyCallback = callback
  testListener: () ->
    @listener.trigger()

  #Helpers functions for Lists
  #The return value is formatted to match the grid
  getAnimeListByUserStatus:(status) ->
    data = []

    wholeList = @databaseMyAnimelist
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

       season     = "Spring 2016"
       score      = value['my_score']

       type = value.anime['series_type']
       animeType = "fa fa-question"
       if type == "0"
        animeType = "fa fa-question"
       if type == "1"
        animeType = "fa fa-tv"
       if type == "2"
        animeType = "glyphicon glyphicon-cd"
       if type == "3"
        animeType = "fa fa-film"
       if type == "4"
        animeType = "fa fa-star"
       if type == "5"
        animeType = "fa fa-chrome"
       if type == "6"
        animeType = "fa fa-music"

       entry['animeId'] = value.series_animedb_id
       entry['recid'] = data.length
       entry['icon'] = animeType
       entry['title'] = animeTitle
       entry['progress'] = progress
       entry['score'] = score
       entry['season'] = season
       data.push entry
    data

  getMangaListByUserStatus:(status) ->
      data = []

      wholeList = @databaseMyMangalist
      for value in wholeList['MangaArray']
       mangaStatus = value['my_status']
       if parseInt(mangaStatus) == status
         entry = {}
         title = value.manga['series_title']
         readChapters = value['my_read_chapters']
         readVolumes = value['my_read_volumes']
         totalVols   = value.manga['series_chapters']
         totalChaps = value.manga['series_volumes']
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
    wholeList = @databaseMyAnimelist
    anime = null
    for value in wholeList['AnimeArray']
      if parseInt(value['series_animedb_id']) == parseInt(id)
        anime = value

    anime




chiikaRenderer = new ChiikaRenderer

ipcRenderer.on 'loginSuccess', (event,arg) ->
    chiikaRenderer.requestMyAnimelist()

    chiikaRenderer.setApiBusy(true)

ipcRenderer.on 'browserPing',(event,arg) ->
  if arg == 'refreshData'
    console.log "[Renderer]IPC Message from browser process -refreshData- "
    chiikaRenderer.requestData()

ipcRenderer.on 'databaseRequest', (event,arg) ->
    console.log 'Receiving IPC message from browser process!Event:databaseRequest'

    chiikaRenderer.databaseMyAnimelist = arg.animeList
    chiikaRenderer.databaseMyMangalist = arg.mangaList
    chiikaRenderer.databaseMyUserInfo = arg.userInfo
    chiikaRenderer.chiikaNode = arg.chiikaNode
    #Important!!! Dont remove
    chiikaRenderer.initialized = true
    chiikaRenderer.checkApiBusy()
    chiikaRenderer.setApiBusy(false)

    if chiikaRenderer.listener != null
      chiikaRenderer.listener.trigger()

#
ipcRenderer.on 'reRender', (event,arg) ->
    console.log 'Receiving IPC message from browser process!Event:reRender'
    if chiikaRenderer.listener != null
      chiikaRenderer.listener.trigger()

ipcRenderer.on 'setApiBusy', (event,arg) ->
    console.log 'Receiving IPC message from browser process!Event:setApiBusy'
    chiikaRenderer.setApiBusy(arg)
#
#
#Export
module.exports = chiikaRenderer
