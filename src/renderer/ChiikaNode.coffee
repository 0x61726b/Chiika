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

class ChiikaNode
  rootOptions:{
    userName:"arkenthera",
    pass:"123456789",
    debugMode:true,
    appMode:true
  }
  @chiika: null
  @root:null
  @db:null
  @request:null
  @modulePath:''
  constructor: ->
    @chiika = require("./../../../chiika-node")
    @modulePath = path.join(path.dirname(fs.realpathSync(@chiika.path)), '../')
    @rootOptions.modulePath = @modulePath
    @root = @chiika.Root(@rootOptions)
    @db = @chiika.Database()
    @request = @chiika.Request()


  #Native Request JS Wrappers
  #These are Native function calls on chiika-node
  #See https://github.com/arkenthera/chiika-node/blob/master/src/RequestWrapper.cc
  #for implementations of the methods below
  #
  #Note: These functions will exit immediately.Since cURL requests run its own
  #thread, success or error callbacks will be called when the request thread finally exists.
  #Native functions and its wrappers start with capitals
  requestSuccess:(ret) ->
    console.log ret
  requestError:(ret) ->
    console.log ret
  RequestVerifyUser: ->
    @request.VerifyUser(@requestSuccess,@requestError)
  RequestMyAnimelist: () ->
    @request.GetMyAnimelist(@requestSuccess,@requestError)
  RequestMyMangalist: ->
    @request.GetMyMangalist(@requestSuccess,@requestError)
  #Native Database JS Wrappers
  #These synchronous functions will only load related data into v8 structures and send it back.
  #See https://github.com/arkenthera/chiika-node/blob/master/src/DatabaseWrapper.cc for more info.
  getMyAnimelist:() ->
    @db.Animelist
  getMyMangalist:() ->
    @db.Mangalist
  getUserInfo:() ->
    @db.User

  #Helpers functions for Lists
  #The return value is formatted to match the grid
  getAnimeListByUserStatus:(status) ->
    data = []
    wholeList = @db.Animelist
    for value in wholeList['AnimeArray']
     animeStatus = value['my_status']
     if parseInt(animeStatus) == status #Watching
       entry = {}
       animeTitle = value.anime['series_title']
       watchedEps = value['my_watched_episodes']
       totalEps   = value.anime['series_episodes']
       serieStatus = value.anime['series_status']
       progress   = "?"
       if parseInt(totalEps) > 0
         progress   = (parseInt(watchedEps) / parseInt(totalEps)) * 100
       season     = "Spring 2016"
       score      = value['my_score']

       if score == '0'
         score = '-'

       icon = 'black'
       if serieStatus == "1"
         icon = '#2db039'
       if serieStatus == "0"
         icon = 'gray'
       if serieStatus == "2"
         icon = '#26448f'

       entry['recid'] = data.length
       entry['icon'] = icon
       entry['title'] = animeTitle
       entry['progress'] = progress
       entry['score'] = score
       entry['season'] = season
       data.push entry
    data



chiikaNode = new ChiikaNode

#IPC
#Handle async messages from browser process
#
ipcRenderer.on 'browserPing',(event,arg)->
  console.log "Receiving IPC message from browser process! Args: " + arg

  if arg == 'requestVerify'
    chiikaNode.RequestVerifyUser()
  if arg == 'requestMyAnimelist'
    chiikaNode.RequestMyAnimelist()
  if arg == 'requestMyMangalist'
    chiikaNode.RequestMyMangalist()
  if arg == 'databaseAnimelist'
    console.log chiikaNode.getMyAnimelist()
  if arg == 'databaseMangalist'
    console.log chiikaNode.getMyMangalist()
  if arg == 'databaseUserInfo'
    console.log chiikaNode.getUserInfo()


#
#
#Export
module.exports = chiikaNode
