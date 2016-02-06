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
  constructor: (chiika,name,keys,args) ->
    @name = name
    @requestKeys = keys
    @tracker = new RequestTracker this,@requestKeys
    @requestNative = chiika.request
    @chiika = chiika
    @additionalArgs = args
  initiate: ->
    @chiika.sendAsyncMessageToRenderer 'setApiBusy',true
    @chiika.setRendererStatusText RequestMessageHelper.getRequestMessage(@name),0
    if @additionalArgs != null
      console.log "Initiating request" + @name + " with args: "
      console.log @additionalArgs
      @requestNative[@name](@tracker.onRequestSuccess,@tracker.onRequestError,@additionalArgs)
    else
      console.log "Initiating request " + @name
      @requestNative[@name](@tracker.onRequestSuccess,@tracker.onRequestError)



  OnRequestSuccess: (ret) ->
    @chiika.setRendererStatusText RequestMessageHelper.getRequestSuccessMessage(ret.request_name),0

    @results = @tracker.results

  OnRequestError: (ret) ->
    @chiika.setRendererStatusText RequestMessageHelper.getRequestErrorMessage(ret.request_name),0
  OnAllComplete: (results) ->
    @chiika.sendAsyncMessageToRenderer 'setApiBusy',false
    last = null
    results.forEach (value,key) =>
      last = key

    @chiika.setRendererStatusText RequestMessageHelper.getRequestSuccessMessage(last),1000


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
  constructor: (chiika) ->
    super chiika,"VerifyUser",@keys
  Initiate: ->
    @initiate()
  onRequestSuccess: (ret) ->
    @OnRequestSuccess ret

    console.log "UserVerifyRequestChain::onRequestSuccess -> " + ret.request_name

    requestName = ret.request_name

    if requestName == 'UserVerifySuccess'
      @chiika.malLoginWindow.send 'browserPing','close'
    if requestName == 'GetMyAnimelistSuccess' || requestName == 'GetMyMangalistSuccess' || requestName == 'GetImageSuccess'
      @chiika.sendRendererData()


  onRequestError: (ret) ->
    @OnRequestError ret
    console.log "UserVerifyRequestChain::onRequestError -> " + ret.request_name
  onAllComplete: (results) ->
    @OnAllComplete results
    console.log "Results: "
    console.log results

class GetMyAnimelistRequest extends RequestChainBase
  allCompleteCallback:null
  successCallback:null
  errorCallback:null
  keys:[
    'GetMyAnimelist'
  ]
  constructor: (chiika) ->
    super chiika,"GetMyAnimelist",@keys
  Initiate: ->
    @initiate()
  onRequestSuccess: (ret) ->
    @OnRequestSuccess ret

    requestName = ret.request_name
    @chiika.sendRendererData()

    @chiika.sendAsyncMessageToRenderer 'requestMyAnimelistSuccess',{ animeList:ret }


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
  constructor: (chiika) ->
    super chiika,"GetMyMangalist",@keys
  Initiate: ->
    @initiate()
  onRequestSuccess: (ret) ->
    @OnRequestSuccess ret

    requestName = ret.request_name
    @chiika.sendRendererData()

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
  constructor: (chiika,animeId) ->
    super chiika,"RefreshAnimeDetails",@keys,{ animeId: animeId }
  Initiate: ->
    @initiate()
  onRequestSuccess: (ret) ->
    @OnRequestSuccess ret

    requestName = ret.request_name
    @chiika.sendRendererData()

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
  constructor: (chiika,animeId) ->
    super chiika,"GetAnimeDetails",@keys,{ animeId: animeId }
  Initiate: ->
    @initiate()
  onRequestSuccess: (ret) ->
    @OnRequestSuccess ret

    requestName = ret.request_name

    if requestName == "FakeRequestSuccess"
      @onAllComplete(@results)

    console.log "Request success for " + requestName
    @chiika.sendRendererData()

  onRequestError: (ret) ->
    @OnRequestError ret
  onAllComplete: (results) ->
    @OnAllComplete results

class RequestManager
  chiika:null
  constructor: (chiika) ->
    @chiika = chiika
  UserVerify: ->
    req = new UserVerifyRequestChain @chiika
    req.Initiate()

  GetMyAnimelist: ->
    req = new GetMyAnimelistRequest @chiika
    req.Initiate()
  GetMyMangalist: ->
    req = new GetMyMangalistRequest @chiika
    req.Initiate()

  #Hard refresh
  RefreshAnime: (id) ->
    req = new RefreshAnimeRequest @chiika,id
    req.Initiate()
  #Soft refresh
  GetAnimeDetails: (id) ->
    req = new GetAnimeDetailsRequest @chiika,id
    req.Initiate()

module.exports = RequestManager
