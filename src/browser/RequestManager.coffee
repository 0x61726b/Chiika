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
#Date: 6.2.2016
#authors: arkenthera
#Description:
#
#----------------------------------------------------------------------------
RequestMessageHelper = require './RequestStatusMessages'
_ = require 'lodash'

#Native Request JS Wrappers
#These are Native function calls on chiika-node
#See https://github.com/arkenthera/chiika-node/blob/master/src/RequestWrapper.cc
#for implementations of the methods below
#
#Note: These functions will exit immediately.Since cURL requests run its own
#thread, success or error callbacks will be called when the request thread finally exists.
#Native functions and its wrappers start with capitals

class RequestTracker
  listener:null
  count:0
  results:null
  keys:null
  self:null
  constructor:(listener,keys) ->
    @listener = listener
    @results = new Map()
    @keys = keys
    RequestTracker::self = this

  onRequestSuccess: (ret) ->
    RequestTracker::self.results.set(ret.request_name,true)
    RequestTracker::self.listener.onRequestSuccess(ret)
    RequestTracker::self.checkStatus()

  onRequestError: (ret) ->
    RequestTracker::self.results.set(ret.request_name,false)
    RequestTracker::self.listener.onRequestError(ret)
    RequestTracker::self.checkStatus()

  checkStatus: ->
    status = false
    index = 0
    @results.forEach (value,key) =>
      status = value
      index = index + 1

    if index == @keys.length
      @onAllComplete()


  onAllComplete: ->
    @listener.onAllComplete(@results)

class RequestChainBase
  name:""
  count:0
  tracker: null
  requestNative:null
  requestKeys:null
  chiika:null
  additionalArgs:null
  results:null
  constructor: (name,keys,args) ->
    @name = name
    @requestKeys = keys
    @tracker = new RequestTracker this,@requestKeys
    @requestNative = chiika.request
    @additionalArgs = args
  initiate: ->
    application.setApiBusy(true)

    application.setRendererStatusText requestMessageHelper.getRequestMessage(@name),0
    if @additionalArgs?
      application.logDebug("Request " + @name + " is starting with args ..." + @additionalArgs)
      console.log @additionalArgs
      @requestNative[@name](@tracker.onRequestSuccess,@tracker.onRequestError,@additionalArgs)
    else
      application.logDebug "Request " + @name + " is starting..."
      @requestNative[@name](@tracker.onRequestSuccess,@tracker.onRequestError)

    d = {}

    @checkTimeout = _.debounce(@onTimeout,15000)



  OnRequestSuccess: (ret) ->
    application.logDebug "Request " + ret.request_name + " is successful."
    application.setRendererStatusText requestMessageHelper.getRequestSuccessMessage(ret.request_name),0

    @results = @tracker.results

    @checkTimeout()

  OnRequestError: (ret) ->
    application.logDebug "Request " + ret.request_name + " has some errors!."
    application.logDebug ret
    application.setRendererStatusText requestMessageHelper.getRequestErrorMessage(ret.request_name),0

    @checkTimeout()
  checkTimeout: () ->
    application.logDebug "Setting timeout to ... 15seconds"
  onTimeout: () ->
    application.logDebug "Request has timed out."

    application.setRendererStatusText "",0

    application.setApiBusy(false)
  OnAllComplete: (results) ->
    application.setApiBusy(false)
    last = null
    results.forEach (value,key) =>
      last = key

    application.setRendererStatusText requestMessageHelper.getRequestSuccessMessage(last),1000

    application.logDebug "Results: "
    application.logDebug results



class UserVerifyRequestChain extends RequestChainBase
  allCompleteCallback:null
  successCallback:null
  errorCallback:null
  keys:[
    'UserVerify',
    'GetMyAnimelist',
    'GetMyMangalist',
    'GetImage'
  ]
  constructor: () ->
    super "VerifyUser",@keys
  Initiate: ->
    @initiate()
  onRequestSuccess: (ret) ->
    @OnRequestSuccess ret

    requestName = ret.request_name

    if requestName == 'UserVerifySuccess'
      application.emitter.emit 'login-success'
      chiika.setUserInfoData()
    if requestName == 'GetMyAnimelistSuccess'
      chiika.setAnimelistData()
    if requestName == 'GetMyMangalistSuccess'
      chiika.setMangalistData()
    if requestName == 'GetImageSuccess'
      application.sendEvent 'db-update-user-image-downloaded',true



  onRequestError: (ret) ->
    @OnRequestError ret
  onAllComplete: (results) ->
    @OnAllComplete results

class GetMyAnimelistRequest extends RequestChainBase
  allCompleteCallback:null
  successCallback:null
  errorCallback:null
  keys:[
    'GetMyAnimelist'
  ]
  constructor: () ->
    super "GetMyAnimelist",@keys
  Initiate: ->
    @initiate()
  onRequestSuccess: (ret) ->
    @OnRequestSuccess ret

    requestName = ret.request_name
    chiika.setAnimelistData()


  onRequestError: (ret) ->
    @OnRequestError ret
  onAllComplete: (results) ->
    @OnAllComplete results
    console.log results

class GetMyMangalistRequest extends RequestChainBase
  allCompleteCallback:null
  successCallback:null
  errorCallback:null
  keys:[
    'GetMyMangalist'
  ]
  constructor: () ->
    super "GetMyMangalist",@keys
  Initiate: ->
    @initiate()
  onRequestSuccess: (ret) ->
    @OnRequestSuccess ret

    requestName = ret.request_name
    chiika.setMangalistData()

  onRequestError: (ret) ->
    @OnRequestError ret
  onAllComplete: (results) ->
    @OnAllComplete results
    console.log results

class RefreshAnimeRequest extends RequestChainBase
  allCompleteCallback:null
  successCallback:null
  errorCallback:null
  keys:[
    'GetMalAjax',
    'GetImage',
    'GetSearchAnime',
    'GetAnimePageScrape'
  ]
  constructor: (animeId) ->
    super "RefreshAnimeDetails",@keys,{ animeId: animeId }
  Initiate: ->
    @initiate()
  onRequestSuccess: (ret) ->
    @OnRequestSuccess ret

    requestName = ret.request_name

    if requestName == "GetImageSuccess"
      application.sendEvent 'db-update-image-downloaded',true
    if requestName == "GetMalAjaxSuccess"
      application.sendEvent 'db-update-anime',ret
    if requestName == "GetAnimePageScrapeSuccess"
      application.sendEvent 'db-update-anime',ret
    if requestName == "GetSearchAnimeSuccess"
      application.sendEvent 'db-update-anime',ret

  onRequestError: (ret) ->
    @OnRequestError ret
  onAllComplete: (results) ->
    @OnAllComplete results
    console.log results

class GetAnimeDetailsRequest extends RequestChainBase
  allCompleteCallback:null
  successCallback:null
  errorCallback:null
  keys:[
    'GetMalAjax',
    'GetImage',
    'GetSearchAnime',
    'GetAnimePageScrape'
  ]
  constructor: (animeId) ->
    super "GetAnimeDetails",@keys,{ animeId: animeId }
  Initiate: ->
    @initiate()
  onRequestSuccess: (ret) ->
    @OnRequestSuccess ret

    requestName = ret.request_name

    if requestName == "FakeRequestSuccess"
      @onAllComplete(@results)
    if requestName == "GetImageSuccess"
      application.sendEvent 'db-update-image-downloaded',true
    if requestName == "GetMalAjaxSuccess"
      application.sendEvent 'db-update-anime',ret
    if requestName == "GetAnimePageScrapeSuccess"
      application.sendEvent 'db-update-anime',ret
    if requestName == "GetSearchAnimeSuccess"
      application.sendEvent 'db-update-anime',ret

  onRequestError: (ret) ->
    @OnRequestError ret
  onAllComplete: (results) ->
    @OnAllComplete results

    application.sendEvent 'request-anime-details',true

class RequestManager
  constructor: ->
    global.requestManager = this
    global.requestMessageHelper = new RequestMessageHelper
  UserVerify: ->
    req = new UserVerifyRequestChain
    req.Initiate()

  GetMyAnimelist: ->
    req = new GetMyAnimelistRequest
    req.Initiate()
  GetMyMangalist: ->
    req = new GetMyMangalistRequest
    req.Initiate()

  #Hard refresh
  RefreshAnime: (id) ->
    req = new RefreshAnimeRequest id
    req.Initiate()
  #Soft refresh
  GetAnimeDetails: (id) ->
    req = new GetAnimeDetailsRequest id
    req.Initiate()

module.exports = RequestManager
