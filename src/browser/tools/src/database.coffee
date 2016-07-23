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

fs = require 'fs'
path = require 'path'

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
    @animeDb.stored.create 'updateAnimeEntry', (nosql,next,params) ->
      updatePredicate = (doc) ->
        require('lodash').forEach doc.anime, (v,k) ->
          if v.series_animedb_id == params.id
            v.anime_english = params.english
            v.anime_synonyms = params.synonyms
            v.anime_synopsis = params.synopsis
        doc
      nosql.update( updatePredicate, -> next() )


    @animeDb.stored.create 'updateAnimeEntryMalPage', (nosql,next,params) ->
      found = false
      updatePredicate = (doc) ->
        require('lodash').forEach doc.anime, (v,k) ->
          if v.series_animedb_id == params.series_animedb_id
            v.misc_studio = params.studio
            v.misc_source = params.source
            v.misc_synopsis = params.synopsis
            v.japanese = params.japanese
            v.broadcast = params.broadcast
            v.duration = params.duration
            v.aired = params.aired
            v.characters = params.characters
            application.logDebug "Updating " + params.series_animedb_id
            found = true
        if !found
          application.logInfo "Entry " + params.series_animedb_id + " isn't on database.Can't update."
        doc

      nosql.update( updatePredicate, -> next({ updated: found }) )


    @animeDb.stored.create 'updateAnimeEntrySmall', (nosql,next,params) ->
      updatePredicate = (doc) ->
        found = false
        require('lodash').forEach doc.anime, (v,k) ->
          if v.series_animedb_id == params.series_animedb_id
            v.misc_genres = params.genres
            v.misc_score = params.score
            v.misc_rank = params.rank
            application.logDebug "Updating " + params.series_animedb_id
            found = true
        if !found
          application.logInfo "Entry " + params.series_animedb_id + " isn't on database.Can't update."
        doc
      nosql.update( updatePredicate, -> next() )

    @animeDb.stored.create 'saveToAnimeDb', (nosql,next,params) ->
      _l = require 'lodash'
      fullMap = (doc) ->
        doc
      cb = (err,selected) ->
        if selected.length == 0
          application.logDebug "Local databse doesn't have any entries.Adding everything."
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
        else
          #Db exists, update it
          #If they both contain same ID, update that ID
          #If the local one doesn't have IDs on the remote, add it
          #param.list.anime is remote list
          #selected is the local database
          #Assume that remote list will always be the most-updated one
          application.logDebug "Local database has some entries.Checking what to do."
          updatePredicate = (upDoc) ->
            _l.forEach params.list.anime, (v,k) ->
              match = _l.find upDoc.anime, { series_animedb_id: v.series_animedb_id }
              index = _l.indexOf upDoc.anime,match

              if index == -1
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
                upDoc.anime.push animeData
                application.logDebug "Database: Adding new entry to the database " + v.series_animedb_id

            upDoc.anime.sort (a,b) ->
              i1 = parseInt(a.series_animedb_id)
              i2 = parseInt(b.series_animedb_id)
              i1 - i2
            upDoc
          nosql.update(updatePredicate, -> next() )

      nosql.all(fullMap,cb)
    @animeDb.stored.create 'insertFromSearch', (nosql,next,params) ->
      _l = require 'lodash'

      checkAnimeOnListThenAddUpdate = (upDoc,v) ->
        match = _l.find upDoc.anime, { series_animedb_id : v.id }
        index = _l.indexOf upDoc.anime,match

        if index == -1
          #No ? Add it
          animeData = {
            series_animedb_id : v.id,
            series_english : v.english,
            series_synonyms : v.synonyms,
            series_synopsis : v.synopsis,
            series_image : v.image,
            series_title: v.title,
            misc_score: v.score,
            series_episodes: v.episodes
          }
          upDoc.anime.push animeData
          application.logInfo v.id + " isn't on database. Adding..."
        else
          #ID exists, update
          match.series_english = v.english
          match.series_synopsis = v.synopsis
          match.series_synonyms = v.synonyms
          match.series_image = v.image
          match.series_episodes = v.episodes
          match.misc_score = v.score
          application.logInfo "[InsertFromSearch] Updating " + v.id
        upDoc
      updatePredicate = (upDoc) ->
        if _l.isArray params.list
          _l.forEach params.list, (v,k) ->
            checkAnimeOnListThenAddUpdate upDoc,v
          upDoc.anime.sort (a,b) ->
            i1 = parseInt(a.series_animedb_id)
            i2 = parseInt(b.series_animedb_id)
            i1 - i2
          upDoc
        else
          checkAnimeOnListThenAddUpdate upDoc,params.list #Single entry
          upDoc.anime.sort (a,b) ->
            i1 = parseInt(a.series_animedb_id)
            i2 = parseInt(b.series_animedb_id)
            i1 - i2
          upDoc

      nosql.update( updatePredicate, -> next() )


      #params.list is a array of entries from AnimeSearch

    @animeDb.stored.create 'searchByTitle', (nosql,next,params) => #Params {title,animeList}
      _l = require 'lodash'
      stringjs = require 'string'
      application.logDebug "Starting searching AnimeDB by title " + params.title
      fullMap = (doc) ->
        doc
      manipulateString = (str) ->
        str = stringjs(str).trimLeft().s
        str = stringjs(str).trimRight().s

        if str.substring(str.length - 1) == '.'
          str = stringjs(str).left(str.length - 1).s
        str


      cb = (err,selected) =>
        found = false
        result = {}

        positiveMatch = (v) =>
          findInAnimeList = _l.find params.animeList.anime, { series_animedb_id: v.series_animedb_id }

          if findInAnimeList?
            #On list,
            _l.assign findInAnimeList,v
            _l.assign result, { list: true, db: true,listEntry: findInAnimeList }
          else
            _l.assign result, { list: false, db: true }
          result

        _l.forEach selected[0].anime,(v,k) ->
          #Try direct match first
          if v.series_title == params.title || (v.series_english? && v.series_english == params.title)
            # findInAnimeList = _l.find params.animeList.anime, { series_animedb_id: v.series_animedb_id }
            #
            # if findInAnimeList?
            #   #On list,
            #   _l.assign findInAnimeList,v
            #   _l.assign result, { list: true, db: true,listEntry: findInAnimeList }
            # else
            #   _l.assign result, { list: false, db: true }
            positiveMatch(v)
            found = true
            return false
          else
            #Try manipulating strings
            title = v.series_title
            title = manipulateString(title)

            if v.series_english?
              english = v.series_english
              english = manipulateString(english)

            if params.title?
              recognizedTitle = params.title
              recognizedTitle = manipulateString(recognizedTitle)

              if title == recognizedTitle || english == recognizedTitle
                positiveMatch(v)
                found = true
                return false

            #Try synonyms
            if v.series_synonyms?
              synonyms = v.series_synonyms.split(';')
              _l.forEach synonyms, (vs,vk) ->
                if vs == params.title
                  positiveMatch(v)
                  found = true
                  return false
        if !found
          #Try generating entries that are close to this title
          _l.assign result, { list: false,db: false }
          if _l.isUndefined params.title
            return
          words = params.title.split(' ')
          stringjs = require 'string'
          suggestions = []
          _l.forEach selected[0].anime, (v,k) ->
            weight = 0
            if v.series_title?
              if stringjs(v.series_title).toLowerCase().contains(params.title.toLowerCase())
                weight++
            if v.series_english?
              if stringjs(v.series_english).toLowerCase().contains(params.title.toLowerCase())
                weight++

            synonyms = v.series_synonyms.split(';')
            _l.forEach synonyms, (vs,vk) ->
              if vs? && vs.length > 0
                if stringjs(vs).toLowerCase().contains(params.title.toLowerCase())
                  weight++
            #Try hard mode
            _l.forEach words, (wv,wk) =>
              if stringjs(v.series_title).toLowerCase().contains(wv.toLowerCase())
                weight++

              _l.forEach synonyms, (vs,vk) ->
                if stringjs(vs).toLowerCase().contains(wv.toLowerCase())
                  weight++


            if weight > 0
              suggestions.push { entry: v, weight: weight }

          sortDescending = (a,b) ->
            b.weight - a.weight
          suggestions.sort(sortDescending)
          _l.assign result, { suggestions: suggestions }

        next(result)


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

      application.emitter.emit 'animelist-ready'

    @userDb.on 'load', =>
      userDbDefer.resolve()

  searchAnimeListDbByTitle: (title,callback) ->
    onAnimeListLoad = (data) =>
      onSearchByTitle = (anime) ->
        callback anime
      @animeDb.stored.execute 'searchByTitle', {title:title, animeList: data },onSearchByTitle
    @loadAnimelist onAnimeListLoad
  updateAnimeDbFromSearchData: (list,callback) ->
    @animeDb.stored.execute( 'insertFromSearch', {list: list},callback )

  updateAnimeEntrySmall: (details,callback) ->
    @animeDb.stored.execute( 'updateAnimeEntrySmall', details,callback )

  updateAnimeEntryMalPage: (details,callback) ->
    @animeDb.stored.execute( 'updateAnimeEntryMalPage', details,callback )

  updateAnime: (anime) ->
    @animelistDb.stored.execute( 'updateAnimeEntry', anime )

  saveList: (listName,data,done) ->
    dfs = []
    dAnimeDb = _when.defer()
    dAnimelist = _when.defer()

    dfs.push dAnimeDb.promise
    dfs.push dAnimelist.promise

    @animeDb.stored.execute 'saveToAnimeDb',{ list: data }, () ->
      dAnimeDb.resolve()

    @animelistDb.clear =>
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



  loadSenpaiData: (cb) ->
    fs.readFile "#{__dirname}/../../../assets/prettifiedSenpai.json", 'utf-8', (err,data) =>
      if err
        application.logDebug "SENPAI.MOE data can't be loaded.Calendar won't function properly."
      else
        cb JSON.parse(data)
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
  isReady: (db) ->
    this[db].isReady

  QueryDb: (db,query,callback) ->
    Filter: (doc) ->
      doc

    Callback: (err, selected) ->
      filtered = _.filter selected,_.matches(query)
      callback filtered


    db.all Filter,Callback


module.exports = new Database();
