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


baseUrl = 'http://hummingbird.me/api/v1/users/'
authUrl = 'http://hummingbird.me/api/v1/users/authenticate/' # POST - No token

urls = [
  'http://hummingbird.me/api/v1/users/authenticate/', # Auth - POST - No Token
]

_ = require process.cwd() + '/node_modules/lodash'
_when   = require process.cwd() + '/node_modules/when'
string  = require process.cwd() + '/node_modules/string'


module.exports = class Hummingbird
  # Description for this script
  # Will be visible on app
  displayDescription: "Hummingbird v1"

  # Unique identifier for the app
  #
  name: "hummingbird"

  # Logo which will be seen at the login screen
  #
  logo: '../assets/images/hm.png'

  # Chiika lets you define multiple users
  # In the methods below you can use whatever user you want
  # For the default we use the user when you login.
  #
  hummingbirdUser: null

  isService: true

  isActive: true

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


  # Hummingbird https://github.com/hummingbird-me/hummingbird/wiki/API-v1-Methods#user--get-information
  # Retrieves user info
  #
  retrieveUserInfo: (userName,callback) ->
    @chiika.logger.info("Retrieving user info for #{userName}")
    onGetUserInfo = (error,response,body) =>
      if response.statusCode == 200 or response.statusCode == 201
        infoObj = JSON.parse(body)

        callback { response: response, userInfo: infoObj }
      else
        @chiika.logger.warn("There was a problem retrieving user info.")
        callback { response: response }

    @chiika.makeGetRequest baseUrl + userName,null, onGetUserInfo


  # Hummingbird https://github.com/hummingbird-me/hummingbird/wiki/API-v1-Methods#library--get-all-entries
  # Retrieves library
  #
  retrieveLibrary: (userName,callback) ->
    @chiika.logger.info("Retrieving user library for #{userName}")
    onGetUserLibrary = (error,response,body) =>
      if response.statusCode == 200 or response.statusCode == 201
        library = JSON.parse(body)

        callback { success: true,response: response, library: library }
      else
        @chiika.logger.warn("There was a problem retrieving library.")
        callback { success: false,response: response }

    @chiika.makeGetRequest baseUrl + userName + "/library",null, onGetUserLibrary

  #
  #
  #
  getAnimelistData: (callback) ->
    if _.isUndefined @hummingbirdUser
      @chiika.logger.error("User can't be retrieved.")
      callback( {success: false })
    else
      @retrieveLibrary @hummingbirdUser.userName, (result) =>
        if result.response.statusCode == 200 or result.response.statusCode == 201
          callback(result)
        else
          @chiika.logger.error("Library from #{@name} couldn't be retrieved.")
          callback(result)
  #
  # In the @createViewAnimelist, we created 5 tab
  # Here we supply the data of the tabs
  # The format is { name: 'tabname', data: [] }
  # The data array has to follow the grid rules in order to appear in the grid correctly.
  # Also they need to have a unique ID
  # For animeList object, see https://github.com/hummingbird-me/hummingbird/wiki/API-v1-Structures#library-entry-object
  setAnimelistTabViewData: (animeList,view) ->
    sampleData = [{ id:0 , animeType: 'TV', animeProgress: 50, animeTitle: 'Test', animeScore: 5, animeSeason: '2016-05-05'}]

    watching = []
    ptw = []
    completed = []
    onhold = []
    dropped = []

    matchGridColumns = (v,id) ->
      anime = {}
      episodes_watched = v.episodes_watched
      episode_count = v.anime.episode_count

      if parseInt(episode_count) == 0
        anime.animeProgress = 0
      else
        anime.animeProgress = (parseInt(episodes_watched) / parseInt(episode_count)) * 100
      anime.animeType = v.anime.show_type

      anime.animeCommunityRating = v.anime.community_rating
      anime.animeAgeRating = v.anime.age_rating
      anime.animeAlternateTitle = v.anime.alternate_title
      anime.animeEpisodeLength = v.anime.episode_length
      anime.animeGenres = v.anime.genres
      anime.animeTitle = v.anime.title
      anime.animeScore = 0
      anime.animeLastUpdated = v.updated_at
      anime.animeLastWatched = v.last_watched
      if v.rating.type == "simple"
        if v.rating.value == "negative"
          anime.animeScore = 2.4
        if v.rating.value == "neutral"
          anime.animeScore = 3.6
        if v.rating.value == "positive"
          anime.animeScore = 5
        if v.rating.value == null
          anime.animeScore = 0
      else
        anime.animeScore = parseInt(v.rating.value)


      anime.animeSeason = v.anime.started_airing
      anime.id = id + 1
      anime

    _.forEach animeList, (v,k) =>
      if v.status == "currently-watching"
        watching.push matchGridColumns(v,watching.length)
      if v.status == "plan-to-watch"
        ptw.push matchGridColumns(v,ptw.length)
      if v.status == "completed"
        completed.push matchGridColumns(v,completed.length)
      if v.status == "on-hold"
        onhold.push matchGridColumns(v,onhold.length)
      if v.status == "dropped"
        dropped.push matchGridColumns(v,dropped.length)



    animelistData = []
    animelistData.push { name: 'watching',data: watching }
    animelistData.push { name: 'ptw',data: ptw }
    animelistData.push { name: 'dropped',data: dropped }
    animelistData.push { name: 'onhold',data: onhold }
    animelistData.push { name: 'completed',data: completed }
    view.setData(animelistData)

  # After the constructor run() method will be called immediately after.
  # Use this method to do what you will
  #
  run: (chiika) ->
    #This is the first event called here to let user do some initializing
    @on 'initialize',=>
      # You may not use an account for Chiika
      # But to use hummingbird, you need one regardlesss.
      @hummingbirdUser = @chiika.users.getDefaultUser(@name)

      if _.isUndefined @hummingbirdUser
        @chiika.logger.warn("Default user for hummingbird doesn't exist. If this is the first time launch, you can ignore this.")



    # This method will be called if there are no UI elements in the database
    # or the user wants to refresh the views
    @on 'reconstruct-ui', (update) =>
      chiika.logger.script("reconstruct-ui #{@name}")

      async = []
      async.push @createViewAnimelist()

      _when.all(async).then => update.defer.resolve()

    # This event is called each time the associated view needs to be updated then saved to DB
    # Note that its the actual data refreshing. Meaning for example, you need to SYNC your data to the remote one, this event occurs
    # This event won't be called each application launch unless "RefreshUponLaunch" option is ticked
    # You should update your data here
    # This event will then save the data to the view's local DB to use it locally.
    @on 'view-update', (update) =>
      chiika.logger.script("Updating view for #{update.view.name} - #{@name}")

      if update.view.name == 'animeList_hummingbird'
        @getAnimelistData (result) =>
          if result.success
            @setAnimelistTabViewData(result.library,update.view).then => update.defer.resolve({ success: result.success })
          else
            update.defer.resolve({ success: result.success })


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
            token = body
            if !_.isUndefined chiika.custom.getKey('hummingbirdToken')
              chiika.custom.updateKeys { name: 'hummingbirdToken', value: body }
            else
              chiika.custom.addKey { name: 'hummingbirdToken', value: body }

            #Get user info
            # /users/{userName}
            @retrieveUserInfo args.user, (info) =>
              if info.response.statusCode == 200
                newUser = { userName: args.user, password: args.password, owner: @name }
                _.assign newUser, info.userInfo


                @hummingbirdUser = chiika.users.getUser(args.user)

                deferUpdate = _when.defer()

                userAdded = =>
                  chiika.requestViewUpdate('animeList_hummingbird',@name,deferUpdate)

                if _.isUndefined @hummingbirdUser
                  @hummingbirdUser = newUser
                  chiika.users.addUser @hummingbirdUser,userAdded
                else
                  chiika.users.updateUser @hummingbirdUser,userAdded

                deferUpdate.promise.then =>
                  args.return( { success: true })


            #  if chiika.users.getUser(malUser.userName)?
            #    chiika.users.updateUser malUser
            #  else
            #  chiika.users.addUser malUser
          else
            #Login failed, use the callback to tell the app that login isn't succesful.
            #
            args.return( { success: false, response: response })

      chiika.makePostRequestAuth( urls[0], { userName: args.user, password: args.pass },null, onAuthComplete )


  createViewAnimelist: () ->
    defer = _when.defer()

    defaultView = {
      name: 'animeList_hummingbird',
      displayName: 'Anime List',
      displayType: 'TabGridView',
      owner: @name, #Script name, the updates for this view will always be called at 'owner'
      category: 'Hummingbird',
      TabGridView: {
        tabList: [
          { name:'watching', display: 'Watching' },
          { name:'completed', display: 'Completed'},
          { name:'onhold', display: 'On Hold'},
          { name:'dropped', display: 'Dropped'},
          { name:'ptw', display: 'Plan to Watch'}
          ],
        gridColumnList: [
          { name: 'animeType',display: 'Type', sort: 'na', width:'40',align: 'center',headerAlign: 'center' },
          { name: 'animeTitle',display: 'Title', sort: 'str', widthP:'60', align: 'left', headerAlign: 'left' },
          { name: 'animeProgress',display: 'Progress', sort: 'int', widthP:'40', align: 'center',headerAlign: 'center' },
          { name: 'animeScore',display: 'Score', sort: 'int', width:'100',align: 'center',headerAlign: 'center' },
          { name: 'animeScoreAverage',display: 'Avg Score', sort: 'str', width:'100', align: 'center',hidden:true,headerAlign: 'center' },
          { name: 'animeSeason',display: 'Season', sort: 'str', width:'100', align: 'center',headerAlign: 'center'},
          { name: 'animeLastUpdated',display: 'Season', sort: 'str', width:'100', align: 'center',hidden:true,headerAlign: 'center' },
          { name: 'animeId',hidden: true }
        ]
      }
    }
    viewConfig = "Config/DefaultHummingbirdAnimeTabGridView.json" #Path relative to app home
    exists = @chiika.utility.fileExistsSmart(viewConfig)
    view = {}
    if !exists
      @chiika.utility.writeFileSmart(viewConfig,JSON.stringify(defaultView))
      view = defaultView
    else
      view = JSON.parse(@chiika.utility.readFileSmart(viewConfig))

    @chiika.ui.addOrUpdate view,=>
      @chiika.logger.verbose "Added new view #{view.name}!"
      defer.resolve()

    defer.promise
