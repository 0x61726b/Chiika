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

_       = require process.cwd() + '/node_modules/lodash'
_when   = require process.cwd() + '/node_modules/when'
string  = require process.cwd() + '/node_modules/string'
moment        = require process.cwd() + '/node_modules/moment'

path          = require 'path'
fs            = require 'fs'



javascriptToExecuteOnLoginPageOfAnilist = "if (typeof document.querySelectorAll('form')[0] !== 'undefined' && document.querySelectorAll('form')[0].getAttribute('ng-submit') === 'logVm.login()') {
document.querySelectorAll('form')[0].addEventListener('submit',function() {
  var userName = document.querySelectorAll('input')[0].value;
  window.ipc.send('modal-window-message',{ name: 'set-user-name', userName: userName,windowName: window.electronWindow.name });
  }); }
if(typeof document.querySelectorAll('div.client h3')[0] !== 'undefined' && document.querySelectorAll('div.client h3')[0].innerHTML.substring(0,4) === 'Copy') {
window.ipc.send('modal-window-message', { name: 'inform-login-response',status: true, html: document.querySelectorAll('body div.client h2')[0].innerHTML, windowName: window.electronWindow.name } ); }
if(typeof document.querySelector('input[name=deny]') !== 'undefined') {
document.querySelector('input[name=deny]').addEventListener('click',function() {
  console.log('Denied');
  window.ipc.send('modal-window-message', { name: 'inform-login-response',status: false, windowName: window.electronWindow.name } );
  });
}
if(typeof document.querySelector('input[name=approve]') !== 'undefined') {
document.querySelector('input[name=approve]').addEventListener('click',function() {
  console.log('Approved');
  }); }"

authUrl = 'https://anilist.co/api/auth'
baseUrl = 'https://anilist.co/api/'
userInfoUrl = 'https://anilist.co/api/user'


module.exports = class Anilist
  # Description for this script
  # Will be visible on app
  displayDescription: "Anilist"

  # Unique identifier for the app
  #
  name: "anilist"

  # Logo which will be seen at the login screen
  #
  logo: '../assets/images/logo_al.png'

  # Chiika lets you define multiple users
  # In the methods below you can use whatever user you want
  # For the default we use the user when you login.
  #
  anilistUser: null


  #
  # Client ID for anilist requests
  #
  anilistClientId: "arkenthera-71vj2"

  #
  # Client Secret for anilist requests
  #
  anilistSecret: "T4a8AMEyk389ENC6RwysxIRYTdHI1p"

  #
  # Login Type
  #
  loginType: "authPin"

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


  #
  #
  #
  anilistSimpleRequest: (baseUrl,callback) ->
    @refreshAccessToken().then (token) =>
      if token.valid
        @chiika.makeGetRequest( baseUrl + "?access_token=#{token.token.value}", {},null, callback )

  #
  #
  #
  anilistAuthorizedRequest: (url,type,callback) ->

    @refreshAccessToken().then (token) =>
      if token.valid
        if type == 'get'
          @chiika.makeGetRequest( baseUrl + url ,{ 'Authorization': "Bearer #{token.token.value}"}, callback )
        else
          @chiika.makePostRequest( baseUrl + url,{ 'Authorization': "Bearer #{token.token.value}"}, callback )

  addOrUpdateKey: (key) ->
    defer = _when.defer()
    @chiika.custom.addKey key, ->
      defer.resolve()
    defer.promise
  #
  #
  #
  refreshAccessToken: (authPin) ->
    new Promise (resolve) =>
      isTokenValid = false
      onAuthComplete = (error,response,body) =>
        if response.statusCode == 200 or response.statusCode == 201
          @loginProps = JSON.parse(body)

          async = []

          async.push @addOrUpdateKey { name: 'anilistAccessToken', value: @loginProps.access_token }
          async.push @addOrUpdateKey { name: 'anilistExpiresIn', value: @loginProps.expires_in }
          async.push @addOrUpdateKey { name: 'anilistExpireDate', value: @loginProps.expires }
          if @loginProps.refresh_token?
            async.push @addOrUpdateKey { name: 'anilistRefreshToken', value: @loginProps.refresh_token }

          isTokenValid = true
          _when.all(async).then => resolve({ valid: isTokenValid, token:currentToken })

      currentToken = @chiika.custom.getKey('anilistAccessToken')
      expires = @chiika.custom.getKey('anilistExpireDate')
      refreshToken = @chiika.custom.getKey('anilistRefreshToken')

      if _.isUndefined currentToken
        @chiika.logger.warn("Anilist token doesnt exist.Requesting new")
        @chiika.makePostRequest( authUrl + "/access_token?grant_type=authorization_pin&client_id=#{@anilistClientId}&client_secret=#{@anilistSecret}&code=#{authPin}",null, onAuthComplete )


      else if moment().isAfter(moment.unix(expires.value))
        @chiika.logger.warn("Anilist token has expired.Requesting new")
        @chiika.makePostRequest( authUrl + "/access_token?grant_type=refresh_token&client_id=#{@anilistClientId}&client_secret=#{@anilistSecret}&refresh_token=#{refreshToken.value}",null, onAuthComplete )


      else
        @chiika.logger.info("Anilist token is still valid.")
        isTokenValid = true
        resolve({ valid: isTokenValid, token:currentToken })


  # Retrieves library
  # @param type {String} anime-manga
  retrieveLibrary: (type,userName,callback) ->
    @chiika.logger.info("Retrieving user library for #{userName}")
    onGetUserLibrary = (error,response,body) =>
      if response.statusCode == 200 or response.statusCode == 201
        library = JSON.parse(body)
        callback { response: response, library: library, success: true }
      else
        @chiika.logger.warn("There was a problem retrieving library.")
        callback { response: response,success: false }

    @anilistAuthorizedRequest "user/#{userName}/#{type}", 'get', onGetUserLibrary

  #
  #
  #
  getAnimelistData: (callback) ->
    if _.isUndefined @anilistUser
      @chiika.logger.error("User can't be retrieved.")
      callback( {success: false })
    else
      @retrieveLibrary 'animelist',@anilistUser.realUserName, (result) =>
        if result.response.statusCode == 200 or result.response.statusCode == 201
          callback(result)
        else
          @chiika.logger.error("Library from #{@name} couldn't be retrieved.")
          callback(result)
  #
  #
  #
  getMangalistData: (callback) ->
    if _.isUndefined @anilistUser
      @chiika.logger.error("User can't be retrieved.")
      callback( {success: false })
    else
      @retrieveLibrary 'mangalist',@anilistUser.realUserName, (result) =>
        if result.response.statusCode == 200 or result.response.statusCode == 201
          callback(result)
        else
          @chiika.logger.error("Library from #{@name} couldn't be retrieved.")
          callback(result)


  # After the constructor run() method will be called immediately after.
  # Use this method to do what you will
  #
  run: (chiika) ->
    #This is the first event called here to let user do some initializing
    @on 'initialize',=>
      # You may not use an account for Chiika
      # But to use hummingbird, you need one regardlesss.
      @anilistUser = @chiika.users.getDefaultUser(@name)

      if _.isUndefined @anilistUser
        @chiika.logger.warn("Default user for hummingbird doesn't exist. If this is the first time launch, you can ignore this.")



    # This method will be called if there are no UI elements in the database
    # or the user wants to refresh the views
    @on 'reconstruct-ui', (update) =>
      async = []
      async.push @createViewAnimelist()
      async.push @createViewMangalist()

      _when.all(async).then => update.defer.resolve()


    #
    # On set-user-login, we open the Anilist auth page, there user logs in
    # then we receive this message via modal-window-message
    # to verify if the user accepted or declined
    #
    @on 'ui-modal-message', (args) =>
      if args.args.name == 'inform-login-response'
        if args.args.status
          #User has accepted the client
          authPin = args.args.html

          # Tell login window that we're done with the auth pin
          # It will expect a 'status:true or false' and 'owner'
          @chiika.sendMessageToWindow 'login','inform-login-response', { status:true , authPin: args.args.html, owner: @name }
        else
          #User has denied the client
          @chiika.sendMessageToWindow 'login','inform-login-response', { status:false, owner: @name }


        @chiika.closeWindow(args.args.windowName)

      if args.args.name == 'set-user-name'
        # Send the user name to login form
        # From anilist, the userName will come as userName@mail.com
        # But to use in API we need displayName or user ID.
        # Assume that the userName userName@mail.com will be displayName
        # Inform users that they need to input their displayName if its different
        userName = args.args.userName

        if userName.indexOf('@') > 0
          #Is an email adress
          userName = userName.substring(0,userName.indexOf('@'))
        @chiika.sendMessageToWindow 'login','inform-login-set-form-value', { owner: @name, target: 'userName', value: userName }


    # args is a window instance
    @on 'ui-dom-ready', (args) =>
      @chiika.executeJavaScript(args.name,javascriptToExecuteOnLoginPageOfAnilist)

    #console.log chiika.ui.getUIItem('animeList')

    # This event is called each time the associated view needs to be updated then saved to DB
    # Note that its the actual data refreshing. Meaning for example, you need to SYNC your data to the remote one, this event occurs
    # This event won't be called each application launch unless "RefreshUponLaunch" option is ticked
    # You should update your data here
    # This event will then save the data to the view's local DB to use it locally.
    @on 'view-update', (update) =>
      chiika.logger.script("[yellow](#{@name}) Updating view for #{update.view.name} - #{@name}")

      if update.view.name == 'animeList_anilist'
        @getAnimelistData (result) =>
          if result.success
            @setAnimelistTabViewData(result.library.lists,update.view).then => update.defer.resolve({ success: result.success })
          else
            update.defer.resolve({ success: result.success })

      if update.view.name == 'mangaList_anilist'
        @getMangalistData (result) =>
          if result.success
            @setMangalistTabViewData(result.library.lists,update.view).then => update.defer.resolve({ success: result.success })
          else
            update.defer.resolve({ success: result.success })



    @on 'set-user-auth-pin', (args,callback) =>
      chiika.logger.script("[yellow](#{@name}) Auth in process")
      onAuthComplete = (error,response,body) =>
        console.log body

      modalWindowOptions = {
        url: "https://anilist.co/api/auth/authorize?grant_type=authorization_pin&client_id=#{@anilistClientId}&response_type=pin",
        parent: 'login',
        name: @name
      }
      chiika.createWindow modalWindowOptions, () =>

    # This function is called from the login window.
    # For example, if you need a token, retrieve it here then store it by calling chiika.custom.addkey
    # Note that you dont have to do anything here if you want
    # But storing a user to avoid logging in each time you launch the app is a good practice
    # Another note is , you MUST call the  'args.return' or the app wont continue executing
    #
    @on 'set-user-login', (args,callback) =>
      @refreshAccessToken(args.authPin).then (token) =>
        if token.valid
          userName = args.user
          newUser = { userName: userName + "_" + @name,owner: @name, realUserName: userName }

          userAdded = ->
            async = []

            deferUpdate1 = _when.defer()
            deferUpdate2 = _when.defer()
            async.push deferUpdate1.promise
            async.push deferUpdate2.promise

            chiika.requestViewUpdate('animeList_anilist',@name,deferUpdate1)
            chiika.requestViewUpdate('mangaList_anilist',@name,deferUpdate2)

            _when.all(async).then =>
              args.return( { success: true })

          @anilistUser = chiika.users.getUser(args.user + "_" + @name)
          if _.isUndefined @anilistUser
            @anilistUser = newUser
            chiika.users.addUser @anilistUser,userAdded
          else
            _.assign @anilistUser,newUser
            chiika.users.updateUser @anilistUser,userAdded

  #
  # In the @createViewAnimelist, we created 5 tab
  # Here we supply the data of the tabs
  # The format is { name: 'tabname', data: [] }
  # The data array has to follow the grid rules in order to appear in the grid correctly.
  # Also they need to have a unique ID
  # For animeList object, see https://github.com/hummingbird-me/hummingbird/wiki/API-v1-Structures#library-entry-object
  setAnimelistTabViewData: (animeList,view) ->
    watching = []
    ptw = []
    completed = []
    onhold = []
    dropped = []

    matchGridColumns = (v,id) ->
      anime = {}
      anime.animeType = v.anime.type
      anime.animeTitleRomaji = v.anime.title_romaji
      anime.animeTitleJapanese = v.anime.title_japanese
      anime.animeTitleEnglish = v.anime.title_english
      anime.animeImageUrlSmall = v.anime.image_url_sml
      anime.animeImageUrlMedium = v.anime.image_url_med
      anime.animeImageUrlLarge = v.anime.image_url_lge
      anime.animeScoreAverage = v.anime.average_score
      anime.animeTitle = anime.animeTitleEnglish
      anime.airingStatus = v.anime.airing_status
      anime.animePopularity = v.anime.populartiy
      anime.animeSynonyms = v.anime.synonyms
      anime.animeTotalEpisodes = v.anime.total_episodes
      anime.anilistId = v.anime.id
      anime.animeAdult = v.anime.adult

      anime.animeEpisodesWatched = v.episodes_watched
      anime.animeLastUpdated = v.updated_time
      anime.animeAddedTime = v.added_time
      anime.animeScoreRaw = v.score_raw
      anime.animeScore = v.score_raw

      if parseInt(v.anime.total_episodes) > 0
        progress = (parseInt(v.episodes_watched) / parseInt(v.anime.total_episodes)) * 100
      else
        progress = 0

      anime.animeProgress = progress
      anime.id = id + 1
      anime


    _.forEach animeList.watching, (v,k) =>
      watching.push matchGridColumns(v,watching.length)

    _.forEach animeList.plan_to_watch, (v,k) =>
      ptw.push matchGridColumns(v,ptw.length)

    _.forEach animeList.dropped, (v,k) =>
      dropped.push matchGridColumns(v,dropped.length)

    _.forEach animeList.completed, (v,k) =>
      completed.push matchGridColumns(v,completed.length)

    _.forEach animeList.on_hold, (v,k) =>
      onhold.push matchGridColumns(v,onhold.length)




    animelistData = []
    animelistData.push { name: 'watching',data: watching }
    animelistData.push { name: 'ptw',data: ptw }
    animelistData.push { name: 'dropped',data: dropped }
    animelistData.push { name: 'onhold',data: onhold }
    animelistData.push { name: 'completed',data: completed }
    view.setData(animelistData)


  #
  # In the @createViewAnimelist, we created 5 tab
  # Here we supply the data of the tabs
  # The format is { name: 'tabname', data: [] }
  # The data array has to follow the grid rules in order to appear in the grid correctly.
  # Also they need to have a unique ID
  # For animeList object, see https://github.com/hummingbird-me/hummingbird/wiki/API-v1-Structures#library-entry-object
  setMangalistTabViewData: (mangaList,view) ->
    reading = []
    ptr = []
    completed = []
    onhold = []
    dropped = []

    matchGridColumns = (v,id) ->
      manga = {}
      manga.mangaType = v.manga.type
      manga.mangaTitleRomaji = v.manga.title_romaji
      manga.mangaTitleJapanese = v.manga.title_japanese
      manga.mangaTitleEnglish = v.manga.title_english
      manga.mangaImageUrlSmall = v.manga.image_url_sml
      manga.mangaImageUrlMedium = v.manga.image_url_med
      manga.mangaImageUrlLarge = v.manga.image_url_lge
      manga.mangaScoreAverage = v.manga.average_score
      manga.mangaTitle = manga.mangaTitleEnglish
      manga.mangaPopularity = v.manga.populartiy
      manga.mangaSynonyms = v.manga.synonyms
      manga.mangaId = v.manga.id
      manga.mangaAdult = v.manga.adult
      manga.mangaPublishingStatus = v.manga.publishing_status

      manga.mangaChaptersRead = v.chapters_read
      manga.mangaVolumesRead = v.volumes_read
      manga.mangaLastUpdated = v.updated_time
      manga.mangaAddedTime = v.added_time
      manga.mangaScoreRaw = v.score_raw
      manga.mangaScore = v.score_raw
      manga.mangaTotalChapters = v.manga.total_chapters
      manga.mangaTotalVolumes = v.manga.total_volumes
      manga.mangaScore = v.score_raw

      if parseInt(manga.mangaTotalVolumes) > 0
        progress = (parseInt(manga.mangaChaptersRead) / parseInt(manga.mangaTotalVolumes)) * 100
      else
        progress = 0

      manga.mangaProgress = progress
      manga.id = id + 1
      manga


    _.forEach mangaList.reading, (v,k) =>
      reading.push matchGridColumns(v,reading.length)

    _.forEach mangaList.plan_to_read, (v,k) =>
      ptr.push matchGridColumns(v,ptr.length)

    _.forEach mangaList.dropped, (v,k) =>
      dropped.push matchGridColumns(v,dropped.length)

    _.forEach mangaList.completed, (v,k) =>
      completed.push matchGridColumns(v,completed.length)

    _.forEach mangaList.on_hold, (v,k) =>
      onhold.push matchGridColumns(v,onhold.length)




    mangalistData = []
    mangalistData.push { name: 'reading',data: reading }
    mangalistData.push { name: 'ptr',data: ptr }
    mangalistData.push { name: 'dropped',data: dropped }
    mangalistData.push { name: 'onhold',data: onhold }
    mangalistData.push { name: 'completed',data: completed }
    view.setData(mangalistData)
  # Creates a 'view'
  # A view is something which will appear at the side menu which you can navigate to
  # See the documentation for view types
  # This is a 'tabView', the most traditional thing in this app
  #
  createViewAnimelist: () ->
    defer = _when.defer()

    defaultView = {
      name: 'animeList_anilist',
      displayName: 'Anime List',
      displayType: 'TabGridView',
      owner: @name, #Script name, the updates for this view will always be called at 'owner'
      category: 'Anilist',
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
          { name: 'animeProgress',display: 'Progress', sort: 'int',widthP:'40', align: 'center',headerAlign: 'center' },
          { name: 'animeScore',display: 'Score', sort: 'int', width:'100',align: 'center',headerAlign: 'center' },
          { name: 'animeScoreAverage',display: 'Avg Score', sort: 'str', width:'100', align: 'center',headerAlign: 'center' },
          { name: 'animeSeason',display: 'Season', sort: 'str', width:'100', align: 'center',headerAlign: 'center', hidden: true },
          { name: 'animeLastUpdated',display: 'Last Updated', sort: 'str', width:'100', align: 'center',hidden:true,headerAlign: 'center' },
          { name: 'animeId',hidden: true }
        ]
      }
     }
    #Check if view config file exists
    viewConfig = "Config/Default#{@name}AnimeTabGridView.json" #Path relative to app home
    exists = @chiika.utility.fileExistsSmart(viewConfig)
    view = {}
    if !exists
      @chiika.utility.writeFileSmart(viewConfig,JSON.stringify(defaultView))
      view = defaultView
    else
      view = JSON.parse(@chiika.utility.readFileSmart(viewConfig))

    @chiika.ui.addOrUpdate view,=>
      @chiika.logger.verbose "Added or updated new view #{view.name}!"
      defer.resolve()

    defer.promise


  createViewMangalist: () ->
    defer = _when.defer()

    defaultView = {
      name: 'mangaList_anilist',
      displayName: 'Manga List',
      displayType: 'TabGridView',
      owner: @name, #Script name, the updates for this view will always be called at 'owner'
      category: 'Anilist',
      TabGridView: { #Must be the same name with displayType
        tabList: [
          { name:'reading', display: 'Reading' },
          { name:'completed', display: 'Completed'},
          { name:'onhold', display: 'On Hold'},
          { name:'dropped', display: 'Dropped'},
          { name:'ptr', display: 'Plan to Read'}
          ],
        gridColumnList: [
          { name: 'mangaType',display: 'Type', sort: 'na', width:'40', align:'center',headerAlign: 'center',hidden:true },
          { name: 'mangaTitle',display: 'Title', sort: 'str', widthP:'60', align: 'left',headerAlign: 'left' },
          { name: 'mangaProgress',display: 'Progress', sort: 'int', widthP:'40', align: 'center',headerAlign: 'center' },
          { name: 'mangaScore',display: 'Score', sort: 'int', width:'100', align: 'center',headerAlign: 'center' },
          { name: 'mangaScoreAverage',display: 'Avg Score', sort: 'str', width:'100', align: 'center',headerAlign: 'center' },
          { name: 'mangaLastUpdated',display: 'Season', sort: 'str', width:'100', align: 'center',headerAlign: 'center' },
          { name: 'mangaId',hidden: true }
        ]
      }
     }
    viewConfig = "Config/Default#{@name}MangaTabGridView.json" #Path relative to app home
    exists = @chiika.utility.fileExistsSmart(viewConfig)
    view = {}
    if !exists
      @chiika.utility.writeFileSmart(viewConfig,JSON.stringify(defaultView))
      view = defaultView
    else
      view = JSON.parse(@chiika.utility.readFileSmart(viewConfig))

    @chiika.ui.addOrUpdate view,=>
      @chiika.logger.verbose "Added or updated new view #{view.name}!"
      defer.resolve()
    defer.promise

      # @refreshAccessToken().then (isTokenValid) =>
      #   if isTokenValid
      #     @anilistSimpleRequest userInfoUrl + "/" + args.user, (error,response,body) =>
      #       console.log body
