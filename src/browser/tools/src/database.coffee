#----------------------------------------------------------------------------
#Chiika
#
#This program is free software; you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation; either version 2 of the License, or
#(at your option) any later version.
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#Date: 9.6.2016
#authors: arkenthera
#Description:
#----------------------------------------------------------------------------

NoSQL = require('nosql')


class Database
  init: () ->
    _self = this
    #Load list for caching reasons
    @animelistDb = NoSQL.load(application.chiikaHome + '/Data/anime.nosql')
    @userDb = NoSQL.load(application.chiikaHome + '/Data/user.nosql')

    @userDb.stored.create 'saveUserInfoBasic', (nosql,next,params) ->
      test = 1
      updateP = (doc) ->
        doc.userName = params.userName
        doc.password = params.password
        doc



      this.update( updateP, -> next())

    @animelistDb.on 'load', ->
      application.logDebug "Anime list Db loaded"

    @userDb.on 'load', =>
      getUserCb = (user) ->
        application.logDebug "User DB loaded - Welcome " + user.userName
      @getUser getUserCb



  #This function is for updating user info, can only update userName and password
  saveUserInfo: (user) ->
    encodePass = new Buffer(user.password).toString('base64')
    @userDb.stored.execute('saveUserInfoBasic', { userName: user.userName, password: encodePass } )

  #This function will only get called after succesful login
  addUser: (user) ->
    @userDb.clear( -> )

    encodePass = new Buffer(user.password).toString('base64')
    @userDb.insert({ userName: user.userName, password: encodePass })

    application.logDebug "Adding user " + user.userName

  getUser: (cb) ->
    map = (doc) ->
      doc
    callback = (err,data) ->
      user = data
      user.password = new Buffer(user.password,'base64').toString('ascii')
      cb user

    @userDb.one(map,callback)

  QueryDb: (db,query,callback) ->
    Filter: (doc) ->
      doc

    Callback: (err, selected) ->
      filtered = _.filter selected,_.matches(query)
      callback filtered


    db.all Filter,Callback


module.exports = new Database();
