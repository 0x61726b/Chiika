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

path          = require 'path'
fs            = require 'fs'


getLibraryUrl = (type,user) ->
  return "http://myanimelist.net/malappinfo.php?u=#{user}&type=#{type}&status=all"


authUrl = 'http://myanimelist.net/api/account/verify_credentials.xml'

_       = require process.cwd() + '/node_modules/lodash'
string  = require process.cwd() + '/node_modules/string'


module.exports = class MyAnimelist
  # Description for this script
  # Will be visible on app
  displayDescription: "MyAnimelist"

  # Unique identifier for the app
  #
  name: "myanimelist"

  # Logo which will be seen at the login screen
  #
  logo: '../assets/images/my.png'

  # Chiika lets you define multiple users
  # In the methods below you can use whatever user you want
  # For the default we use the user when you login.
  #
  malUser: null

  #
  #
  #
  isService: true

  # Will be called by Chiika with the API object
  # you can do whatever you want with this object
  # See the documentation for this object's methods,properties etc.
  constructor: (chiika) ->
    @chiika = chiika

  # This method is controls the communication between app and script
  # If you change this method things will break
  #
  on: (event,args...) ->
    @chiika.on @name,event,args...


  # Hummingbird https://github.com/hummingbird-me/hummingbird/wiki/API-v1-Methods#library--get-all-entries
  # Retrieves library
  # @param type {String} anime-manga
  retrieveLibrary: (type,userName,callback) ->
    userName = string(userName).chompRight("_" + @name).s
    @chiika.logger.info("Retrieving user library for #{userName} - #{type}")
    onGetUserLibrary = (error,response,body) =>

      if response.statusCode == 200 or response.statusCode == 201
        @chiika.parser.parseXml(body)
                      .then (result) =>
                        callback { response: response, library: result }
      else
        @chiika.logger.warn("There was a problem retrieving library.")
        callback { response: response }

    @chiika.makeGetRequest getLibraryUrl(type,userName),null, onGetUserLibrary

  #
  #
  #
  getAnimelistData: (callback) ->
    if _.isUndefined @malUser
      @chiika.logger.error("User can't be retrieved.Aborting anime list request.")
    else
      @retrieveLibrary 'anime',@malUser.realUserName, (result) =>
           userInfo = result.library.myanimelist.myinfo

           _.assign @malUser, { malAnimeInfo: userInfo }
           @chiika.users.updateUser @malUser

           callback(result)

  #
  #
  #
  getMangalistData: (callback) ->
    if _.isUndefined @malUser
      @chiika.logger.error("User can't be retrieved.Aborting manga list request.")
    else
      @retrieveLibrary 'manga',@malUser.realUserName, (result) =>
           userInfo = result.library.myanimelist.myinfo

           _.assign @malUser, { malMangaInfo: userInfo }
           @chiika.users.updateUser @malUser

           callback(result)


  #
  # In the @createViewAnimelist, we created 5 tab
  # Here we supply the data of the tabs
  # The format is { name: 'tabname', data: [] }
  # The data array has to follow the grid rules in order to appear in the grid correctly.
  # Also they need to have a unique ID
  # For animeList object, see myanimelist.net/malappinfo.php?u=arkenthera&type=anime&status=all
  setAnimelistTabViewData: (animeList,view) ->
    sampleData = [{ id:0 , animeType: 'TV', animeProgress: 50, animeTitle: 'Test', animeScore: 5, animeSeason: '2016-05-05'}]

    watching = []
    ptw = []
    completed = []
    onhold = []
    dropped = []

    matchGridColumns = (v,id) ->
      anime = {}
      anime.animeType = "TV"
      seriesEpisodes = v.series_episodes

      if seriesEpisodes != "0"
        anime.animeProgress = (parseInt(v.my_watched_episodes) / parseInt(v.series_episodes)) * 100
      else
        anime.animeProgress = 0
      anime.animeTitle = v.series_title
      anime.animeScore = v.my_score

      anime.animeSeason = v.series_start
      anime.id = id
      anime.mal_id = v.series_animedb_id
      anime

    _.forEach animeList, (v,k) =>
      if v.my_status == "1"
        watching.push matchGridColumns(v,watching.length)
      if v.my_status == "6"
        ptw.push matchGridColumns(v,ptw.length)
      if v.my_status == "2"
        completed.push matchGridColumns(v,completed.length)
      if v.my_status == "3"
        onhold.push matchGridColumns(v,onhold.length)
      if v.my_status == "4"
        dropped.push matchGridColumns(v,dropped.length)



    animelistData = []

    animelistData.push { name: 'watching',data: watching }
    animelistData.push { name: 'ptw',data: ptw }
    animelistData.push { name: 'dropped',data: dropped }
    animelistData.push { name: 'onhold',data: onhold }
    animelistData.push { name: 'completed',data: completed }
    view.setData(animelistData)

    baka = 42


  #
  # In the @createViewAnimelist, we created 5 tab
  # Here we supply the data of the tabs
  # The format is { name: 'tabname', data: [] }
  # The data array has to follow the grid rules in order to appear in the grid correctly.
  # Also they need to have a unique ID
  # For animeList object, see myanimelist.net/malappinfo.php?u=arkenthera&type=anime&status=all
  setMangalistTabViewData: (mangaList,view) ->
    reading = []
    ptr = []
    completed = []
    onhold = []
    dropped = []



    matchGridColumns = (v,id) ->
      manga = {}
      manga.mangaType = ""
      seriesChapters = v.series_chapters

      if seriesChapters != "0"
        manga.mangaProgress = (parseInt(v.my_read_chapters) / parseInt(v.series_chapters)) * 100
      else
        manga.mangaProgress = 0
      manga.mangaTitle = v.series_title
      manga.mangaScore = v.my_score
      manga.id = id
      manga.mal_id = v.series_mangadb_id
      manga

    _.forEach mangaList, (v,k) =>
      if v.my_status == "1"
        reading.push matchGridColumns(v,reading.length)
      if v.my_status == "6"
        ptr.push matchGridColumns(v,ptr.length)
      if v.my_status == "2"
        completed.push matchGridColumns(v,completed.length)
      if v.my_status == "3"
        onhold.push matchGridColumns(v,onhold.length)
      if v.my_status == "4"
        dropped.push matchGridColumns(v,dropped.length)




    mangalistData = []
    mangalistData.push { name: 'reading',data: reading }
    mangalistData.push { name: 'ptr',data: ptr }
    mangalistData.push { name: 'dropped',data: dropped }
    mangalistData.push { name: 'onhold',data: onhold }
    mangalistData.push { name: 'completed',data: completed }
    view.setData(mangalistData)

  # After the constructor run() method will be called immediately after.
  # Use this method to do what you will
  #
  run: (chiika) ->
    #This is the first event called here to let user do some initializing
    @on 'initialize',=>
      # You may not use an account for Chiika
      # But to use hummingbird, you need one regardlesss.
      @malUser = @chiika.users.getDefaultUser(@name)

      if _.isUndefined @malUser
        @chiika.logger.warn("Default user for myanimelist doesn't exist. If this is the first time launch, you can ignore this.")



    # This method will be called if there are no UI elements in the database
    # or the user wants to refresh the views
    @on 'reconstruct-ui', (promise) =>
      @createViewAnimelist(promise)
      @createViewMangalist(promise)

    #console.log chiika.ui.getUIItem('animeList')

    # This event is called each time the associated view needs to be updated then saved to DB
    # Note that its the actual data refreshing. Meaning for example, you need to SYNC your data to the remote one, this event occurs
    # This event won't be called each application launch unless "RefreshUponLaunch" option is ticked
    # You should update your data here
    # This event will then save the data to the view's local DB to use it locally.
    @on 'view-update', (update) =>
      chiika.logger.info("[blue](SCRIPT) Updating view for #{update.view.name} - #{@name}")


      if update.view.name == 'animeList_myanimelist'
        #view.setData(@getAnimelistData())
        @getAnimelistData (result) =>
          @setAnimelistTabViewData(result.library.myanimelist.anime,update.view)

      if update.view.name == 'mangaList_myanimelist'
        @getMangalistData (result) =>
          @setMangalistTabViewData(result.library.myanimelist.manga,update.view)


    # chiika.makeGetRequestAuth urls[1],malUser,null, (error,response,body) =>
    #   chiika.parser.parseXml(body)
    #                .then (xmlObject) =>
    #                  _.assign malUser, { mal: xmlObject.myanimelist.myinfo }
    #                  chiika.users.updateUser malUser


    # This function is called from the login window.
    # For example, if you need a token, retrieve it here then store it by calling chiika.custom.addkey
    # Note that you dont have to do anything here if you want
    # But storing a user to avoid logging in each time you launch the app is a good practice
    # Another note is , you MUST call the  'args.return' or the app wont continue executing
    #
    @on 'set-user-login', (args,callback) =>
      chiika.logger.script("[yellow](#{@name}) Auth in process " + args.user)
      onAuthComplete = (error,response,body) =>
        if error?
          chiika.logger.error(error)
        else
          if response.statusCode == 200 or response.statusCode == 201
            userAdded = =>
              chiika.requestViewUpdate('animeList_myanimelist',@name)
              chiika.requestViewUpdate('mangaList_myanimelist',@name)
            newUser = { userName: args.user + "_" + @name,owner: @name, password: args.password, realUserName: args.user }

            chiika.parser.parseXml(body)
                         .then (xmlObject) =>
                           @malUser = chiika.users.getUser(args.user + "_" + @name)

                           _.assign newUser, { malID: xmlObject.user.id }
                           if _.isUndefined @malUser
                             @malUser = newUser
                             chiika.users.addUser @malUser,userAdded
                           else
                             _.assign @malUser,newUser
                             chiika.users.updateUser @malUser,userAdded
            args.return( { success: true })

            #  if chiika.users.getUser(malUser.userName)?
            #    chiika.users.updateUser malUser
            #  else
            #  chiika.users.addUser malUser
          else
            #Login failed, use the callback to tell the app that login isn't succesful.
            #
            args.return( { success: false, response: response })

      chiika.makePostRequestAuth( authUrl, { userName: args.user, password: args.pass },null, onAuthComplete )

  createViewAnimelist: (promise) ->
    view = {
      name: 'animeList_myanimelist',
      displayName: 'Anime List',
      displayType: 'tabView',
      owner: @name, #Script name, the updates for this view will always be called at 'owner'
      category: 'MyAnimelist',
      tabView: {
        tabList: [ 'watching','ptw','dropped','onhold','completed'],
        gridColumnList: [
          { name: 'animeType',display: 'Type', sort: 'na', width:'40' },
          { name: 'animeTitle',display: 'Title', sort: 'str', width:'150' },
          { name: 'animeProgress',display: 'Progress', sort: 'int', width:'150' },
          { name: 'animeScore',display: 'Score', sort: 'int', width:'50' },
          { name: 'animeSeason',display: 'Season', sort: 'str', width:'100' },
          { name: 'animeId',hidden: true }
        ]
      }
     }
    @chiika.ui.addUIItem [view],=>
      @chiika.logger.verbose "Added new view #{view.name}!"
      promise.resolve()


  createViewMangalist: (promise) ->
    view = {
      name: 'mangaList_myanimelist',
      displayName: 'Manga List',
      displayType: 'tabView',
      owner: @name, #Script name, the updates for this view will always be called at 'owner'
      category: 'MyAnimelist',
      tabView: {
        tabList: [ 'reading','ptr','dropped','onhold','completed'],
        gridColumnList: [
          { name: 'mangaType',display: 'Type', sort: 'na', width:'40' },
          { name: 'mangaTitle',display: 'Title', sort: 'str', width:'150' },
          { name: 'mangaProgress',display: 'Progress', sort: 'int', width:'150' },
          { name: 'mangaScore',display: 'Score', sort: 'int', width:'50' },
          { name: 'mangaId',hidden: true }
        ]
      }
     }
    @chiika.ui.addUIItem [view],=>
      @chiika.logger.verbose "Added new view #{view.name}!"
      promise.resolve()