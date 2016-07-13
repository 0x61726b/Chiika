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
_ = require 'lodash'

_when = require 'when'

class Database
  init: (dbReadyCallback) ->
    _self = this

    Deferreds = []

    userDbDefer = _when.defer()
    Deferreds.push userDbDefer.promise

    _when.all(Deferreds).then( -> dbReadyCallback() )
    #Load list for caching reasons
    @animelistDb = NoSQL.load(application.chiikaHome + '/Data/animeList.nosql')
    @animeDb = NoSQL.load(application.chiikaHome + '/Data/anime.nosql')
    #Start from here tomorrow
    @userDb = NoSQL.load(application.chiikaHome + '/Data/user.nosql')

    @userDb.stored.create 'saveUserInfoBasic', (nosql,next,params) ->
      test = 1
      updateP = (doc) ->
        doc.userName = params.userName
        doc.password = params.password
        doc



      this.update( updateP, -> next())
    @animelistDb.stored.create 'updateAnimeEntry', (nosql,next,params) ->
      updatePredicate = (doc) ->
        require('lodash').forEach doc.anime, (v,k) ->
          if v.series_animedb_id == params.id
            v.anime_english = params.english
            v.anime_synonyms = params.synonyms
            v.anime_synopsis = params.synopsis
        doc
      nosql.update( updatePredicate, -> next() )

    # @animeDb.views.create 'db',map,sort, (err,count) =>
    #   @animeDb.views.all 'db', (err,documents,count) =>
    #     console.log documents

    @animeDb.stored.create 'saveToAnimeDb', (nosql,next,params) ->
      _l = require 'lodash'
      fullMap = (doc) ->
        doc
      cb = (err,selected) ->
        if selected.length == 0
          newList = { anime: [] }
          _l.forEach params.list.anime, (v,k) ->
            animeData = {
              series_animedb_id : v.series_animedb_id,
              series_title : v.series_title,
              series_synonyms : v.series_synonyms,
              series_episodes : v.series_episodes,
              series_status : v.series_status,
              series_start : v.series_start,
              series_end : v.series_end,
              series_image : v.series_image,
              series_type: v.series_type
            }

            newList.anime.push animeData

          nosql.insert newList, ->
            next()
          return
      nosql.all(fullMap,cb)

    @animelistDb.stored.create 'save', (nosql,next,params) ->
      _l = require 'lodash'
      fullMap = (doc) ->
        doc
      cb = (err,selected) ->
        if selected.length == 0
          newList = { anime: [] }
          _l.forEach params.list.anime, (v,k) ->
            animeData = {
              series_animedb_id : v.series_animedb_id,
              my_id : v.my_id,
              my_watched_episodes : v.my_watched_episodes,
              my_start_date : v.my_start_date,
              my_finish_date : v.my_finish_date,
              my_score : v.my_score,
              my_status : v.my_status,
              my_rewatching : v.my_rewatching,
              my_rewatching_ep : v.my_rewatching_ep,
              my_last_updated : v.my_last_updated,
              my_tags : v.my_tags,
            }

            newList.anime.push animeData

          nosql.insert newList, ->
            next()
          return
      nosql.all(fullMap,cb)

    @animelistDb.on 'load', =>
      application.logDebug "Anime list Db loaded"

      application.emitter.emit 'anime-db-ready'

    @userDb.on 'load', =>
      userDbDefer.resolve()

  updateAnime: (anime) ->
    console.log "UpdateAnime"
    @animelistDb.stored.execute( 'updateAnimeEntry', anime )

  saveList: (listName,data,done) ->
    dfs = []
    dAnimeDb = _when.defer()
    dAnimelist = _when.defer()

    dfs.push dAnimeDb.promise
    dfs.push dAnimelist.promise

    @animeDb.stored.execute 'saveToAnimeDb',{ list: data }, () ->
      dAnimeDb.resolve()

    @animelistDb.stored.execute 'save',{ list: data }, () ->
      dAnimelist.resolve()

    _when.all(dfs).then( -> done() )


  #This function is for updating user info, can only update userName and password
  saveUserInfo: (user) ->
    encodePass = new Buffer(user.password).toString('base64')
    @userDb.stored.execute('saveUserInfoBasic', { userName: user.userName, password: encodePass } )

  #This function will only get called after succesful login
  addUser: (user) ->
    @userDb.clear( -> )

    application.logDebug "Adding user " + user.userName + " ( " + user.userId + " )"

    encodePass = new Buffer(user.password).toString('base64')
    @userDb.insert({ userName: user.userName, password: encodePass,userId: user.userId })



  loadAnimelist: (cb) ->
    application.logDebug "Loading anime list..."
    map = (doc) ->
      doc

    cba = (err,data) ->
      if _.isEmpty data
        console.log "No data - animelistDb"
        return
      cb data[0]
    @animelistDb.all(map,cba)
  loadAnimeDb: (cb) ->
    application.logDebug "Loading anime database..."
    map = (doc) ->
      doc

    cba = (err,data) ->
      if _.isEmpty data
        console.log "No data - animeDb"
        return
      cb data[0]
    @animeDb.all(map,cba)
  getUser: (cb) ->
    map = (doc) ->
      doc
    callback = (err,data) ->
      user = data

      if _.isEmpty user
        cb undefined
        return
      user.password = new Buffer(user.password,'base64').toString('ascii')
      cb user

    if _.isUndefined @userDb
      cb undefined
      return
    @userDb.one(map,callback)

  QueryDb: (db,query,callback) ->
    Filter: (doc) ->
      doc

    Callback: (err, selected) ->
      filtered = _.filter selected,_.matches(query)
      callback filtered


    db.all Filter,Callback


module.exports = new Database();
