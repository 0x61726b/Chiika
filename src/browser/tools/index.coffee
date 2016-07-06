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

Request = require('./src/request');
Parser = require('./src/parser');
Database = require('./src/database');



NoSQL = require 'nosql'

_ = require 'lodash'


fs = require 'fs'

class Tools
  chiikaPath: null,
  readyCallback: null
  init: (callback) ->
    application.logDebug "Initializing tools"
    @readyCallback = callback
    @chiikaPath = "C:/Users/alperen/AppData/Roaming/Chiika/"

    GLOBAL.chiika = this

    _self = this

    @dummyList = fs.readFileSync @chiikaPath + "Data/dummydata.txt", "utf-8"
    Parser.ParseSync(@dummyList)
          .then (result) ->
            _self.dummyList = result


    Database.init()

    _self.readyCallback()

  #Saves list data to %chiikahome%/data
  saveList: (listName,data,callback) ->
    lisql = NoSQL.load @chiikaPath + listName

    lisql.clear ( -> )
    lisql.insert data, (err,count) -> callback err


  #Loads list data from %chiikahome%/data , Async
  loadList: (listName,callback) ->
    lisql = NoSQL.load @chiikaPath + listName

    map = (dc) ->
      return dc

    lisql.on 'load', ->
      lisql.all map,callback

  wipeList: (listName,callback) ->
    lisql = NoSQL.load @chiikaPath + listName

    lisql.clear ( ->)

  getAnimelistOfUser: (userName,callback) ->
    if _.isEmpty(userName)
      return

    Request.getAnimelist userName,callback

  getMangalistOfUser: (userName,callback) ->
    if _.isEmpty(userName)
      return

    Request.getMangalist userName,callback
  login:(userName,password,callback) ->
    if _.isEmpty(userName) || _.isEmpty(password)
      application.logDebug "Empty user name or password."
      return
    application.logDebug "Login: " + userName

    Request.verifyCredentials {userName: userName, password:password},callback


module.exports = Tools
