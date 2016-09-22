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

updateAnime = "http://hummingbird.me/api/v1/libraries/"
removeAnime = "http://hummingbird.me/api/v1/libraries/"
searchAnime = "http://hummingbird.me/api/v1/search/anime"

urls = [
  'http://hummingbird.me/api/v1/users/authenticate/', # Auth - POST - No Token
]
_assign       = scriptRequire 'lodash.assign'
_find         = scriptRequire 'lodash/collection/find'
_isArray      = scriptRequire 'lodash.isarray'
_forEach      = scriptRequire 'lodash/collection/forEach'
_cloneDeep    = scriptRequire 'lodash.clonedeep'
_size         = scriptRequire 'lodash/collection/size'

_when         = scriptRequire 'when'
string        = scriptRequire 'string'
xml2js        = scriptRequire 'xml2js'
moment        = scriptRequire 'moment'
{shell}       = require 'electron'


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

  order: 0

  useInSearch: true

  animeView: 'hummingbird_animelist'

  mangaView: 'hummingbird_mangalist'

  views: ['hummingbird_animelist']

  # Will be called by Chiika with the API object
  # you can do whatever you want with this object
  # See the documentation for this object's methods,properties etc.
  constructor: (chiika) ->
    @chiika = chiika

  # This method is controls the communication between app and script
  # If you change this method things will break
  #
  on: (event,args...) ->
    try
      @chiika.on @name,event,args...
    catch error
      console.log error
      throw error

  search: (type,keywords,callback) ->
    onSearchComplete = (error,response,body) =>
      if response.statusCode != 200
        callback?({ success: false, error: "request" })
      else
        results = JSON.parse(body)
        callback({ success: true, results: results })


     @chiika.makeGetRequest "#{searchAnime}?query=" + (keywords.split(" ").join("+")),null, onSearchComplete
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
    if !@hummingbirdUser?
      @chiika.logger.error("User can't be retrieved.")
      callback( {success: false })
    else
      @retrieveLibrary @hummingbirdUser.realUserName, (result) =>
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
    animeDb = @chiika.viewManager.getViewByName('anime_db')

    if animeDb?
      data = animeDb.getData()

      if data.length > 0
        animeDbArray = data
      else
        animeDbArray = []

    commonFormatList = []
    _forEach animeList, (anime) =>
      newAnime = {}
      newAnime.id = animeDbArray.length
      _assign newAnime, @toAnimeDbFormat(anime)
      animeDbArray.push newAnime

      commonFormatList.push @libraryToCommonFormat(anime)

    animeDb.setDataArray(animeDbArray)
    view.setDataArray(commonFormatList)

  toAnimeDbFormat: (v) ->
    anime = {}
    anime = @animeToCommonFormat(v.anime)
    anime.owner = 'hummingbird'
    anime

  animeToCommonFormat: (v) ->
    anime = {}

    anime.hmb_id                    = v.id
    anime.mal_id                    = v.mal_id
    anime.animeSlug                 = v.slug
    anime.animeSeriesStatus         = v.status
    anime.animeUrl                  = v.url
    anime.animeTitle                = v.title
    anime.animeAlternateTitle       = v.alternate_title
    anime.animeTotalEpisodes        = v.episode_count
    anime.animeEpisodeLength        = v.episode_length
    anime.animeImage                = v.cover_image
    anime.animeSynopsis             = v.synopsis
    anime.animeType                 = v.show_type
    anime.animeSeriesStartDate      = v.started_airing
    anime.animeSeriesEndDate        = v.finished_airing
    anime.animeScoreAverage         = v.community_rating
    anime.animeAgeRating            = v.age_rating
    anime.animeGenres               = v.genres
    anime
  #
  #
  #
  libraryToCommonFormat: (v) ->
    anime = {}
    anime.hmb_id                    = v.anime.id
    anime.animeUserLastWatched      = v.last_watched
    anime.animeLastUpdated          = moment(v.updated_at,'YYYY-MM-DDTHH:mm:ss').valueOf()
    anime.animeWatchedEpisodes      = v.episodes_watched
    anime.animeUserStatus           = v.status
    anime.animeRewatchedTimes       = v.rewatched_times
    anime.animeRewatching           = v.rewatching
    anime.animeNotes                = v.notes
    anime.animeNotesPresent         = v.notes_present
    anime.animePrivate              = v.private

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
      anime.animeScore = parseFloat(v.rating.value)


    anime

  initialize: ->
    @hummingbirdUser = @chiika.users.getDefaultUser(@name)

    if @hummingbirdUser?
      @chiika.logger.info("Default user : #{@hummingbirdUser.realUserName}")
    else
      @chiika.logger.warn("Default user for #{@name} doesn't exist. If this is the first time launch, you can ignore this.")

    animelistView   = @chiika.viewManager.getViewByName('hummingbird_animelist')
    animeDbView  = @chiika.viewManager.getViewByName('anime_db')

    if animelistView?
      @animelist = animelistView.getData()
      @chiika.logger.script("[yellow](#{@name}) Animelist data length #{@animelist.length} #{@name}")

    if animeDbView?
      @animedb = animeDbView.getData()
      @chiika.logger.script("[yellow](#{@name}) Anime DB data length #{@animedb.length} #{@name}")

  # After the constructor run() method will be called immediately after.
  # Use this method to do what you will
  #
  run: (chiika) ->
    #This is the first event called here to let user do some initializing
    @on 'initialize',=>
      # You may not use an account for Chiika
      # But to use hummingbird, you need one regardlesss.
      @initialize()

    @on 'post-init',(init) =>
      init.defer.resolve()



    # This method will be called if there are no UI elements in the database
    # or the user wants to refresh the views
    @on 'reconstruct-ui', (update) =>
      @chiika.logger.script("reconstruct-ui #{@name}")

      @createViewAnimelist()

    @on 'get-user', (args) =>
      @hummingbirdUser = @chiika.users.getDefaultUser(@name)

      if @hummingbirdUser?
        @hummingbirdUser.profileImage = @hummingbirdUser.avatar
        args.return(@hummingbirdUser)

    @on 'get-view-data', (args) =>
      view = args.view
      data = args.data

      if data.length == 0
        return

      @chiika.logger.script("[yellow](#{@name}) Requesting View Data for #{view.name}")

      if view.name == 'hummingbird_animelist'
        watching    = []
        ptw         = []
        onhold      = []
        dropped     = []
        completed   = []

        _forEach data, (anime) =>
          animeValues = @getAnimeValues(anime)

          status = anime.animeUserStatus
          newAnime = _cloneDeep anime

          #Pre process - add some more columns
          newAnime.id                            = animeValues.id # Renderer should not know which ID its dealing with.
          newAnime.animeTitle                    = animeValues.title
          newAnime.animeWatchedEpisodes          = animeValues.watchedEpisodes
          newAnime.animeTotalEpisodes            = animeValues.totalEpisodes
          newAnime.animeImage                    = animeValues.image
          newAnime.animeScoreAverage             = animeValues.averageScore
          newAnime.animeType                     = animeValues.type
          newAnime.animeProgress                 = (parseInt(anime.animeWatchedEpisodes) / parseInt(anime.animeTotalEpisodes)) * 100
          newAnime.animeSeasonText               = animeValues.seasonText
          newAnime.animeScoreAverage             = animeValues.averageScore
          newAnime.animeLastUpdatedText          = animeValues.lastUpdatedText

          if status == "currently-watching"
            watching.push newAnime
          else if status == "completed"
            completed.push newAnime
          else if status == "on-hold"
            onhold.push newAnime
          else if status == "dropped"
            dropped.push newAnime
          else if status == "plan-to-watch"
            ptw.push newAnime

        animelistData = []

        animelistData.push { name: 'al_watching',data: watching }
        animelistData.push { name: 'al_ptw',data: ptw }
        animelistData.push { name: 'al_dropped',data: dropped }
        animelistData.push { name: 'al_onhold',data: onhold }
        animelistData.push { name: 'al_completed',data: completed }
        args.return(animelistData)

    @on 'list-action', (args) =>
      action = args.action
      params = args.params

      @chiika.logger.script("Receiving details-action - #{action} for #{@name}")

      onActionError = (error) =>
        @chiika.logger.script("Could not perform action #{action}")
        if error?
          @chiika.logger.script(error)

        args.return({ success: false, error: error })

      switch action
        when 'progress-update'
          item = params.item

          if params.viewName == @views[0]
            @updateProgress params.id,'anime',item.current, (result) =>
              args.return(result)

        when 'score-update'
          item = params.item

          if params.viewName == @views[0]
            @updateScore params.id,item.current, (result) =>
              args.return(result)

        when 'status-update'
          item = params.item

          if params.viewName == @views[0]
            @updateStatus params.id,'anime',item.identifier, (result) =>
              args.return(result)

        when 'delete-entry'
          if !params.id?
            onActionError("Need ID for delete-entry")
          else
            console.log params
            if params.layoutType == 'anime'
              animeView = @chiika.viewManager.getViewByName(@views[0])
              if animeView?
                entry = _find animeView.getData(), (o) -> o.hmb_id == params.id
                if entry?
                  @removeAnime entry, (response) =>
                    if response.success
                      animeView.remove 'hmb_id',params.id, (dbop) =>
                        if dbop.count > 0
                          # Update the local list
                          @animelist = animeView.getData()
                          @chiika.requestViewDataUpdate(@name,@views[0])
                          args.return(response)

    # This event is called each time the associated view needs to be updated then saved to DB
    # Note that its the actual data refreshing. Meaning for example, you need to SYNC your data to the remote one, this event occurs
    # This event won't be called each application launch unless "RefreshUponLaunch" option is ticked
    # You should update your data here
    # This event will then save the data to the view's local DB to use it locally.
    @on 'view-update', (update) =>
      @chiika.logger.script("[yellow](#{@name}) Updating view for #{update.view.name} - #{@name}")

      if update.view.name == 'hummingbird_animelist'
        @getAnimelistData (result) =>
          if result.success
            @setAnimelistTabViewData(result.library,update.view).then =>
              update.return({ success: result.success })
          else
            @chiika.logger.warn("[yellow](#{@name}) view-update has failed.")
            update.return({ success: result.success })


    @on 'details-layout', (args) =>
      @chiika.logger.script("[yellow](#{@name}) Details-Layout #{args.id}")

      id        = args.id
      viewName  = args.viewName
      params    = args.params

      if viewName == 'hummingbird_animelist'
        @onAnimeDetailsLayout id,params, (result) =>
          args.return(result)


    @on 'sync', (args) =>
      syncAnimelist = (resolve) =>

        @chiika.requestViewUpdate @views[0],@name,(params) =>
          error = !params.success
          if params.success
            @chiika.requestViewDataUpdate(@name,@views[0])

          resolve(error)

      syncAnimelistPromise = _when.promise(syncAnimelist).then (error) =>
        args.return(error)

    @on 'make-search', (args) =>
      @chiika.logger.script("[yellow](#{@name}) make-search")

      title = args.title
      type  = args.type

      @doSearch type,title, (results) =>
        args.return(results)

    @on 'is-in-list', (args) =>
      entry = args.entry
      listType = args.type

      inList = false

      if listType == 'anime'
        animeEntry = _find @animelist, (o) -> (o.hmb_id) == entry.hmb_id
        if animeEntry?
          inList = true


      @chiika.logger.script("[yellow](#{@name}) #{entry.mal_id} - is-in-list #{args.type} -> #{inList}")
      args.return(inList)

    @on 'get-entry-user-status', (args) =>
      @chiika.logger.script("[yellow](#{@name}) get-entry-user-status #{args.type} - #{args.statusType}")
      entry = args.entry
      type = args.type
      statusType = args.statusType

      if type == 'anime'
        animeEntry = _find @animelist, (o) -> (o.mal_id) == entry.mal_id
        if animeEntry?
          status = animeEntry.animeUserStatus
          args.return(@getAnimeUserStatus(status))

    @on 'get-entry-type', (args) =>
      @chiika.logger.script("[yellow](#{@name}) get-entry-type #{args.type} - #{args.statusType}")
      entry = args.entry
      type = args.type
      statusType = args.statusType

      if type == 'anime'
        args.return(entry.animeType)

    @on 'get-anime-values', (args) =>
      @chiika.logger.script("[yellow](#{@name}) get-anime-values #{args.entry.hmb_id}")
      args.return @getAnimeValues(args.entry)

    @on 'set-user-login', (args,callback) =>
      @chiika.logger.script("[yellow](#{@name}) Auth in process " + args.user)
      onAuthComplete = (error,response,body) =>
        if error?
          @chiika.logger.error(error)
        else
          if response.statusCode == 200 or response.statusCode == 201
            token = JSON.parse(body)
            if @chiika.custom.getKey('hummingbirdToken')?
              @chiika.custom.updateKeys { name: 'hummingbirdToken', value: JSON.parse(body) }
            else
              @chiika.custom.addKey { name: 'hummingbirdToken', value: JSON.parse(body) }

            #Get user info
            # /users/{userName}
            @retrieveUserInfo args.user, (info) =>
              if info.response.statusCode == 200
                newUser = { userName: args.user + "_" + @name,owner: @name, password: args.pass, realUserName: args.user }
                _assign newUser, info.userInfo


                @hummingbirdUser = @chiika.users.getUser(args.user + "_" + @name)

                users = @chiika.users.getUsers()
                if users.length == 0
                  _assign newUser, { isDefault: true }

                updateAnimelist = (resolve) =>
                  @chiika.requestViewUpdate 'hummingbird_animelist',@name, () =>
                    resolve()

                userAdded = =>
                  getAnimelist = _when.promise(updateAnimelist)
                  getAnimelist.then () =>
                    args.return({ success: true })
                    @initialize()


                if !@hummingbirdUser?
                  @hummingbirdUser = newUser
                  @chiika.users.addUser @hummingbirdUser,userAdded
                else
                  @chiika.users.updateUser @hummingbirdUser,userAdded



            #  if @chiika.users.getUser(malUser.userName)?
            #    @chiika.users.updateUser malUser
            #  else
            #  @chiika.users.addUser malUser
          else
            #Login failed, use the callback to tell the app that login isn't succesful.
            #
            errorMessage = JSON.parse(response.body)
            args.return( { success: false, response: response,error: errorMessage.error })

      @chiika.makePostRequestAuth( urls[0], { userName: args.user, password: args.pass },null, null, onAuthComplete )


  doSearch: (type,title,callback) ->
    results = []
    @search type,title, (list) =>
      if list.success
        _forEach list.results, (entry) =>
          results.push @animeToCommonFormat(entry)

      @lastAnimeSearch = results
      # Save to anime db
      animeDbView = @chiika.viewManager.getViewByName('anime_db')

      if animeDbView?
        animeDbData = animeDbView.getData()

        animeDbFormat = []
        _forEach results, (anime) =>
          newAnime = {}
          hmb_id = anime.hmb_id
          # Check if this exists on db
          findInDb = _find animeDbData, (o) -> o.hmb_id == hmb_id
          if findInDb?
            newAnime.id = findInDb.id
          else
            newAnime.id = (animeDbData.length + animeDbFormat.length).toString()
          _assign newAnime,anime

          animeDbFormat.push newAnime

        animeDbView.setDataArray(animeDbFormat).then =>
          # Update local animedb
          animeDbView = @chiika.viewManager.getViewByName('anime_db')
          @animedb = animeDbView.getData()
          callback?({ success: list.success, error: list.error, results: results })

  updateProgress:(id,type,newProgress,callback) ->
    @chiika.logger.script("Updating #{type} progress - #{id} - to #{newProgress}")
    switch type
      when 'anime'
        animeEntry = _find @animelist, (o) -> (o.hmb_id) == id
        if animeEntry?
          animeEntry.animeWatchedEpisodes = newProgress
          @updateAnime animeEntry, (result) =>
            if result.success
              @updateViewAndRefresh @views[0],animeEntry,'hmb_id', (result) =>
                if result.updated > 0
                  callback({ success: true, updated: result.updated })
                else
                  callback({ success: false, updated: result.updated, error:"Update request has failed.", response: result.response, errorDetailed: "Something went wrong when saving to database." })
            else
              callback({ success: false, updated: 0, error: "Update request has failed.",errorDetailed: "Something went wrong with the http request.", response: result.response })

  #
  #
  #
  updateScore:(id,newScore,callback) ->
    onUpdateView = (result) =>
      if result.updated > 0
        callback({ success: true, updated: result.updated })
      else
        callback({ success: false, updated: result.updated, error:"Update request has failed.", errorDetailed: "Something went wrong when saving to database." })


    @chiika.logger.script("Updating score - #{id} - to #{newScore}")
    animeEntry = _find @animelist, (o) -> (o.id) == id
    if animeEntry?
      animeEntry.animeScore = newScore
      @updateAnime animeEntry, (result) =>
        if result.success
          @updateViewAndRefresh @views[0],animeEntry,'id', (result) =>
            onUpdateView(result)
        else
          callback({ success: false, updated: 0, error: "Update request has failed.",errorDetailed: "Something went wrong with the http request. #{result.response}" })


  #
  #
  #
  updateStatus:(id,type,newStatus,callback) ->
    @chiika.logger.script("Updating #{type} status - #{id} - to #{newStatus}")

    entry = { }
    newTabName = ""
    oldTabName = ""

    switch type
      when 'anime'
        entry = _find @animelist, (o) -> (o.hmb_id) == id
      when 'manga'
        entry = _find @mangalist, (o) -> (o.hmb_id) == id

    switch type
      when 'anime'
        if entry?
          # Update the entry's status
          entry.animeUserStatus = newStatus

          @updateAnime entry, (result) =>
            if result.success
              @updateViewAndRefresh @views[0],entry,'hmb_id', (result) =>
                if result.updated > 0
                  callback({ success: true, updated: result.updated })
                else
                  callback({ success: false, updated: result.updated, error:"Update request has failed.", errorDetailed: "Something went wrong when saving to database." })
            else
              callback({ success: false, updated: 0, error: "Update request has failed.",errorDetailed: "Something went wrong with the http request. #{result.response}" })



  #
  #
  #
  updateAnime: (anime,callback) ->
    anime.animeLastUpdated = moment().valueOf()
    data = @buildUrlForUpdating(anime)

    @post "#{updateAnime}#{anime.hmb_id}?#{data}",data,(result) =>
      if result.success
        callback(result)

        #Save history
        historyView = @chiika.viewManager.getViewByName('hummingbird_animelist_history')

        if historyView?
          historyData = historyView.getData()

          historyItem =
            history_id: historyData.length
            updated: moment().valueOf()
            id: anime.id
            episode: anime.animeWatchedEpisodes

          historyView.setData( historyItem, 'history_id').then (args) =>
            @chiika.requestViewDataUpdate(@name,'hummingbird_animelist')
            # @chiika.requestViewDataUpdate('cards','cards_statistics')
            # @chiika.requestViewDataUpdate('cards','cards_continueWatching')
      else
        # It can return status code 200 but if the body isn't updated,it failed.
        result.success = false
        callback(result)


  #
  #
  #
  removeAnime: (anime,callback) ->
    token = @chiika.custom.getKey('hummingbirdToken')

    url = "#{removeAnime}#{anime.hmb_id}?auth_token=#{token.value}"
    @post url,"",(result) =>
      if result.statusCode == 201
        callback?(result)
      else
        callback?(result)


  updateViewAndRefresh: (viewName,newEntry,key,callback) ->
    view = @chiika.viewManager.getViewByName(viewName)
    view.setData(newEntry,key).then =>
      callback?({ success: true,updated: 1 })

  buildUrlForUpdating: (entry) ->
    token = @chiika.custom.getKey('hummingbirdToken')
    body = ""
    body += "id=#{entry.hmb_id}&"
    body += "auth_token=#{token.value}&"
    body += "status=#{entry.animeUserStatus}&"
    body += "rating=#{entry.animeScore}&"
    body += "episodes_watched=#{entry.animeWatchedEpisodes}&"
    body


  onAnimeDetailsLayout: (id,params,callback) ->
    animeEntry = _find @animelist, (o) -> parseInt(o.hmb_id) == parseInt(id)
    if animeEntry?
      callback({ updated:false, layout:@getAnimeDetailsLayout(animeEntry)})
    else
      # Not in list
      findInLastSearch = _find @lastAnimeSearch, (o) -> parseInt(o.hmb_id) == parseInt(id)

      console.log @lastAnimeSearch

      if findInLastSearch?
        callback({ updated:false, layout:@getAnimeDetailsLayout(findInLastSearch)})

      # @doSearch type,title, (results) =>
      #   args.return(results)


  getAnimeDetailsLayout: (entry) ->
    av    = @getAnimeValues(entry)

    typeCard =
      name: 'typeMiniCard'
      title: 'Type'
      content: av.type
      type: 'miniCard'

    seasonCard =
      name: 'seasonMiniCard'
      title: 'Season'
      content: av.season
      type: 'miniCard'

    durationCard =
      name: 'durationMiniCard'
      title: 'Duration'
      content: av.duration
      type: 'miniCard'

    cards = [typeCard,seasonCard]

    if av.duration != ""
      cards.push durationCard

    genresText = ""
    av.genres.map (genre,i) => genresText += genre.name + ","
    av.genres = genresText


    detailsLayout =
      id: av.id
      layoutType: 'anime'
      title: av.title
      genres: av.genres
      list: av.list
      status:
        items:
          [
            { title: 'Episodes', current: av.watchedEpisodes, total: av.totalEpisodes },
          ]
        user: av.userStatus
        series: av.seriesStatus
        defaultAction: av.userStatusText
        actions:[
          { name: 'Watching', action: 'status-action-watching', identifier: 'currently-watching' },
          { name: 'Completed', action: 'status-action-completed', identifier: 'completed'}
          { name: 'Plan to Watch', action: 'status-action-ptw', identifier: 'plan-to-watch'},
          { name: 'On Hold', action: 'status-action-onhold', identifier: 'on-hold'},
          { name: 'Dropped', action: 'status-action-dropped',identifier: 'dropped'}
        ]
      synopsis: av.synopsis
      cover: av.image
      voted: ""
      owner: @name
      characters: []
      actionButtons: [
        { name: 'Torrent', action: 'torrent',color: 'lightblue' },
        { name: 'Library', action: 'library',color: 'purple' }
        { name: 'Play Next', action: 'playnext',color: 'teal' }
        { name: 'Search', action: 'search',color: 'green' }
      ]
      scoring:
        type: 'onefive'
        userScore: av.score
        average: av.averageScore
      miniCards: cards

    if !av.list
      detailsLayout.rawEntry = entry
    detailsLayout

  getAnimeValues: (entry) ->
    if entry?
      findInAnimelist = _find @animelist, (o) -> o.hmb_id == entry.hmb_id
      animeDbEntry    = _find @animedb, (o) -> o.hmb_id == entry.hmb_id

    if !animeDbEntry?
      animeDbEntry = {}

    if findInAnimelist?
      list = true
    else
      list = false

    if !findInAnimelist?
      findInAnimelist = {}

    slug                = animeDbEntry.animeSlug ? ""
    seriesStatus        = animeDbEntry.animeSeriesStatus ? "unknown"
    seriesUrl           = animeDbEntry.animeUrl ? ""
    title               = animeDbEntry.animeTitle ? ""
    alternateTitle      = animeDbEntry.animeAlternateTitle ? ""
    totalEpisodes       = animeDbEntry.animeTotalEpisodes ? "0"
    duration            = animeDbEntry.animeDuration ? ""
    image               = animeDbEntry.animeImage ? "../assets/images/chitoge.png"
    synopsis            = animeDbEntry.animeSynopsis ? ""
    type                = animeDbEntry.animeType ? ""
    seriesStartDate     = animeDbEntry.animeSeriesStartDate ? ""
    seriesEndDate       = animeDbEntry.animeSeriesEndDate ? ""
    averageScore        = animeDbEntry.animeScoreAverage ? "-"
    ageRating           = animeDbEntry.animeAgeRating ? ""
    genres              = animeDbEntry.animeGenres ? ""
    lastUpdated         = entry.animeLastUpdated ? ""
    watchedEpisodes     = entry.animeWatchedEpisodes ? "0"
    userStatus          = entry.animeUserStatus ? "0"
    userRewatching      = entry.animeRewatching ? false
    rewatchedTimes      = entry.animeRewatchedTimes ? 0
    score               = entry.animeScore ? 0
    notes               = entry.animeNotes ? ""
    notesPresent        = entry.animeNotesPresent ? ""
    animePrivate        = entry.animePrivate ? ""


    # Change the season from date to text
    startDate = animeDbEntry.animeSeriesStartDate

    if startDate?
      parts = startDate.split("-");
      year = parts[0];
      month = parts[1];

      iMonth = parseInt(month);

      season = "Unknown"
      if iMonth > 0 && iMonth < 4
        season =  "Winter " + year
      if iMonth > 3 && iMonth < 7
        season =  "Spring " + year
      if iMonth > 6 && iMonth < 10
        season =  "Summer " + year
      if iMonth > 9 && iMonth <= 12
        season = "Fall " + year

    # change last updated from unix timestamp to text
    date = moment(lastUpdated)
    now = moment()
    diffSeconds = Math.floor(moment.duration(now.diff(date)).asSeconds())
    diffMinutes = Math.floor(moment.duration(now.diff(date)).asMinutes())
    diffHours = Math.floor(moment.duration(now.diff(date)).asHours())
    diffDays = Math.floor(moment.duration(now.diff(date)).asDays())
    diffWeeks = Math.floor(moment.duration(now.diff(date)).asWeeks())
    diffMonths = Math.floor(moment.duration(now.diff(date)).asMonths())
    diffYears = Math.floor(moment.duration(now.diff(date)).asYears())

    lastUpdatedText = "a moment ago"

    if diffMinutes > 0
      lastUpdatedText = "#{diffMinutes} minutes ago"


    if diffHours > 0
      lastUpdatedText = "#{diffHours} hours ago"

    if diffDays > 0
      lastUpdatedText = "#{diffDays} days ago"

    if diffWeeks > 0
      lastUpdatedText = "#{diffWeeks} weeks ago"

    if diffMonths > 0
      lastUpdatedText = "#{diffMonths} months ago"

    if diffYears > 0
      lastUpdatedText = "#{diffYears} years ago"

    averageScore = averageScore.toFixed(2)

    userStatusText = "Not In List"
    userStatusText = @getAnimeUserStatus(userStatus)

    anime =
      id: entry.hmb_id
      list: list
      slug: slug
      seriesStatus: seriesStatus
      seriesUrl:seriesUrl
      title: title
      alternateTitle:alternateTitle
      totalEpisodes: totalEpisodes
      duration:duration
      image:image
      synopsis:synopsis
      type:type
      seriesStartDate:seriesStartDate
      seriesEndDate:seriesEndDate
      averageScore:averageScore
      ageRating:ageRating
      genres:genres
      lastUpdated:lastUpdated
      lastUpdatedText:lastUpdatedText
      watchedEpisodes:watchedEpisodes
      userStatus:userStatus
      userStatusText: userStatusText
      userRewatching:userRewatching
      rewatchedTimes:rewatchedTimes
      score:score
      notes:notes
      notesPresent:notesPresent
      animePrivate:animePrivate
      season: season
      seasonText: season


  getAnimeUserStatus: (status) ->
    userStatusText = "Not In List"
    if status == "currently-watching"
      userStatusText = "Watching"

    if status == "plan-to-watch"
      userStatusText = "Plan to Watch"

    if status == "completed"
      userStatusText = "Completed"

    if status == "dropped"
      userStatusText = "Dropped"

    if status == "on-hold"
      userStatusText = "On Hold"

    userStatusText


  post: (url,body,callback) ->
    onAuthorizedPostComplete = (error,response,body) =>
      if error
        callback( { success: false , response: body, statusCode: response.statusCode })

      else if response.statusCode == 200 or response.statusCode == 201
        callback( { success: true, response: body, statusCode: response.statusCode })

      else
        callback( { success: false , response: body, statusCode: response.statusCode })

    @chiika.makePostRequest( url, null,null, onAuthorizedPostComplete )

  createViewAnimelist: () ->
    defaultView = {
      name: 'hummingbird_animelist',
      displayName: 'Anime List',
      displayType: 'TabGridView',
      owner: @name, #Script name, the updates for this view will always be called at 'owner'
      category: 'Hummingbird',
      TabGridView: {
        sortBy: 'animeTitle',
        sortingPrefCol: 'animeTitle',
        sortingPrefDir: 'asc',
        lastTabIndex: 0,
        tabList: [
          { name:'al_watching', display: 'Watching' },
          { name:'al_completed', display: 'Completed'},
          { name:'al_onhold', display: 'On Hold'},
          { name:'al_dropped', display: 'Dropped'},
          { name:'al_ptw', display: 'Plan to Watch'}
          ],
        gridColumnList: [
          { name: 'animeType',display: 'Type', sort: 'int', css: 'grid-40'},
          { name: 'animeTitle',display: 'Title', sort: 'str',css: 'grid-title'},
          { name: 'animeProgress',display: 'Progress', sort: 'float', css: 'grid-progress'},
          { name: 'animeScore',display: 'Score', sort: 'int', css: 'grid-80'},
          { name: 'animeScoreAverage',display: 'Avg Score', sort: 'float',css: 'grid-80'},
          { name: 'animeSeasonText',display: 'Season', sort: 'date', css: 'grid-160'},
          { name: 'animeLastUpdatedText',display: 'Last Updated', sort: 'int', css: 'grid-160'}
        ]
      }
     }
    historyView =
      name: 'hummingbird_animelist_history'
      owner: @name
      displayName: 'AnimeList History'
      displayType: 'none'
      noUpdate: true


    @chiika.viewManager.addView defaultView
    @chiika.viewManager.addView historyView
