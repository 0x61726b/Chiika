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
path = require 'path'

fs = require 'fs'



class Tools
  chiikaPath: null,
  readyCallback: null
  init: (callback) ->
    application.logDebug "Initializing tools"

    dbReadyCallback = ->
      callback()

    Database.init(dbReadyCallback)

  getAnimelistOfUser: (userName,callback) ->
    if _.isEmpty(userName)
      application.logDebug "Empty user name."
      return
    #Strip away user info
    getAnimelistCb = (response) ->
      callback response


    application.logDebug "GetAnimelist: " + userName
    Request.getAnimelist userName,getAnimelistCb

  getMangalistOfUser: (userName,callback) ->
    if _.isEmpty(userName)
      return

    Request.getMangalist userName,callback

  #Should be used as checkIfFileExists('Data/anime.nosql')
  checkIfFileExists: (fileName) ->
    appPath = application.chiikaHome
    try
      file = fs.statSync path.join(appPath,fileName)
    catch e
      file = undefined
    if _.isUndefined file
      return false
    else
      return true
  login:(userName,password,callback) ->
    if _.isEmpty(userName) || _.isEmpty(password)
      application.logDebug "Empty user name or password."
      return
    application.logDebug "Login: " + userName

    Request.verifyCredentials {userName: userName, password:password},callback
  downloadImage: (link,fileName,extension,cb) ->
    Request.downloadImage link,fileName,extension,cb
  downloadAnimeCover: (link,animeId,cb) ->
    @downloadImage link,animeId,"jpg",cb
  downloadUserImage: (id,cb) ->
    @downloadImage "http://cdn.myanimelist.net/images/userimages/"+id+".jpg",id,"jpg",cb

  searchAnime: (user,q,cb) ->
    q = q.replace(' ','+')
    Request.searchAnime user,q,cb
  animeDetailsSmall: (animeId,cb) ->
    Request.getAnimeDetailsSmall animeId,cb
  animeDetailsMalPage: (animeId,cb) ->
    Request.getAnimeDetailsMalPage animeId,cb


module.exports = Tools
