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


javascriptToExecuteOnLoginPageOfAnilist = "if(typeof document.querySelectorAll('div.client h3')[0] !== 'undefined' && document.querySelectorAll('div.client h3')[0].innerHTML.substring(0,4) === 'Copy') {
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

_             = require process.cwd() + '/node_modules/lodash'
moment        = require process.cwd() + '/node_modules/moment'


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


  # Creates a 'view'
  # A view is something which will appear at the side menu which you can navigate to
  # See the documentation for view types
  # This is a 'tabView', the most traditional thing in this app
  #
  createViewAnimelist: (promise) ->
    view = {
      name: 'animeList',
      displayName: 'Anime List',
      displayType: 'tabView',
      owner: @name,
      tabView: {
        tabList: [ 'watching','ptw','dropped','onhold','completed'],
        gridColumnList: [
          { name: 'animeType',display: 'Type', sort: 'na', width:'40' },
          { name: 'animeTitle',display: 'Title', sort: 'str', width:'150' },
          { name: 'animeProgress',display: 'Progress', sort: 'int', width:'150' },
          { name: 'animeScore',display: 'Score', sort: 'int', width:'50' },
          { name: 'animeSeason',display: 'Season', sort: 'str', width:'100' },
        ]
      }
     }
    @chiika.ui.addOrUpdate view,=>
      @chiika.logger.verbose "Added new view #{view.name}!"
      promise.resolve()

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

  #
  #
  #
  refreshAccessToken: (authPin) ->
    new Promise (resolve) =>
      isTokenValid = false
      onAuthComplete = (error,response,body) =>
        if response.statusCode == 200 or response.statusCode == 201
          @loginProps = JSON.parse(body)

          @chiika.custom.addKey { name: 'anilistAccessToken', value: @loginProps.access_token }
          @chiika.custom.addKey { name: 'anilistExpiresIn', value: @loginProps.expires_in }
          @chiika.custom.addKey { name: 'anilistExpireDate', value: @loginProps.expires }
          if @loginProps.refresh_token?
            @chiika.custom.addKey { name: 'anilistRefreshToken', value: @loginProps.refresh_token }

          isTokenValid = true

          resolve(isTokenValid,@loginProps.access_token)

      currentToken = @chiika.custom.getKey('anilistAccessToken')
      expires = @chiika.custom.getKey('anilistExpireDate')
      refreshToken = @chiika.custom.getKey('anilistRefreshToken')

      if _.isUndefined currentToken
        @chiika.logger.warn("Anilist token doesnt exist.Requesting new")
        @chiika.makePostRequest( authUrl + "/access_token?grant_type=authorization_pin&client_id=#{@anilistClientId}&client_secret=#{@anilistSecret}&code=#{authPin}",null, onAuthComplete )


      else if moment(expires).isAfter(moment())
        @chiika.logger.warn("Anilist token has expired.Requesting new")
        @chiika.makePostRequest( authUrl + "/access_token?grant_type=refresh_token&client_id=#{@anilistClientId}&client_secret=#{@anilistSecret}&refresh_token=#{refreshToken}",null, onAuthComplete )


      else
        @chiika.logger.info("Anilist token is still valid.")
        isTokenValid = true
        resolve({ valid: isTokenValid, token:currentToken })

  # Hummingbird https://github.com/hummingbird-me/hummingbird/wiki/API-v1-Methods#library--get-all-entries
  # Retrieves library
  # @param type {String} anime-manga
  retrieveLibrary: (type,userName,callback) ->
    @chiika.logger.info("Retrieving user library for #{userName}")
    onGetUserLibrary = (error,response,body) =>
      if response.statusCode == 200 or response.statusCode == 201


        callback { response: response, library: library }
      else
        @chiika.logger.warn("There was a problem retrieving library.")
        callback { response: response }

    @chiika.makeGetRequest getLibraryUrl(type,userName),null, onGetUserLibrary

  #
  #
  #
  getAnimelistData: (callback) ->
    if _.isUndefined @hummingbirdUser
      @chiika.logger.error("User can't be retrieved.")
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
      anime.animeType = v.anime.show_type
      anime.animeProgress = 50
      anime.animeTitle = v.anime.title
      anime.animeScore = 0
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
        anime.animeScore = v.rating.value
      anime.animeSeason = v.anime.started_airing
      anime.id = id
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
    animelistData.push { name: 'dropped',data: completed }
    animelistData.push { name: 'onhold',data: onhold }
    animelistData.push { name: 'completed',data: dropped }
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
    @on 'reconstruct-ui', (promise) =>
      @createViewAnimelist(promise)



    #
    # On set-user-login, we open the Anilist auth page, there user logs in
    # then we receive this message via modal-window-message
    # to verify if the user accepted or declined
    #
    @on 'ui-modal-message', (args) =>
      if args.name == 'inform-login-response'
        if args.status
          #User has accepted the client
          authPin = args.html

          # Tell login window that we're done with the auth pin
          # It will expect a 'status:true or false' and 'owner'
          @chiika.sendMessageToWindow 'login','inform-login-response', { status:true , authPin: args.html, owner: @name }
        else
          #User has denied the client
          @chiika.sendMessageToWindow 'login','inform-login-response', { status:false, owner: @name }


        @chiika.closeWindow(args.windowName)

    # args is a window instance
    @on 'ui-dom-ready', (args) =>
      @chiika.executeJavaScript(args.name,javascriptToExecuteOnLoginPageOfAnilist)

    #console.log chiika.ui.getUIItem('animeList')

    # This event is called each time the associated view needs to be updated then saved to DB
    # Note that its the actual data refreshing. Meaning for example, you need to SYNC your data to the remote one, this event occurs
    # This event won't be called each application launch unless "RefreshUponLaunch" option is ticked
    # You should update your data here
    # This event will then save the data to the view's local DB to use it locally.
    @on 'view-update', (view) =>
      chiika.logger.info("Updating view for #{view.name} - #{@name}")

      if view.name == 'animeList'
        #view.setData(@getAnimelistData())
        @getAnimelistData (result) =>
          @setAnimelistTabViewData(result.library,view)



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
        @anilistAuthorizedRequest 'user/arkenthera', 'get', (error,response,body) =>
          console.log body

      # @refreshAccessToken().then (isTokenValid) =>
      #   if isTokenValid
      #     @anilistSimpleRequest userInfoUrl + "/" + args.user, (error,response,body) =>
      #       console.log body
