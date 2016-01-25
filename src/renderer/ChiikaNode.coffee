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
