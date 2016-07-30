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
{Emitter} = require 'event-kit'
{InvalidParameterException} = require './exceptions'
_ = require 'lodash'

module.exports = class ChiikaPublicApi
  emitter: null
  subscriptions: []

  constructor: (params={})->
    @emitter             = new Emitter
    {@logger, @db,@parser,@ui} = params
    @users               = @db.usersDb
    @custom              = @db.customDb
    @uiDb                = @db.uiDb

  makeGetRequest:(url,headers,callback) ->
    if _.isUndefined callback
      throw new InvalidParameterException("You have to supply a callback to 'makeGetRequest' method.")
    chiika.requestManager.makeGetRequest(url,headers,callback)

  makeGetRequestAuth:(url,user,headers,callback) ->
    if _.isUndefined callback
      throw new InvalidParameterException("You have to supply a callback to 'makeGetRequestAuth' method.")
    chiika.requestManager.makeGetRequestAuth(url,user,headers,callback)


  makePostRequestAuth:(url,user,headers,callback) ->
    if _.isUndefined callback
      throw new InvalidParameterException("You have to supply a callback to 'makePostRequestAuth' method.")
    chiika.requestManager.makePostRequestAuth(url,user,headers,callback)


  requestViewUpdate: (viewName,owner) ->
    view = chiika.uiManager.getUIItem(viewName)
    if view?
      @emitTo owner,'view-update',view
    else
      chiika.logger.error("Can't update a non-existent view.")


  on: (receiver,message,args...) ->
    sub = @emitter.on message,args...
    @subscriptions.push { receiver: receiver , message: message, sub: sub }
    sub
  emit: (message,args...) ->
    @emitter.emit message,args...

  dispatch: (handler,args...)->
    @emitter.constructor.dispatch handler,args...


  emitTo: (receiver,message,args...) ->
    listeners = @emitter.handlersByEventName[message]
    scripts = chiika.apiManager.getScripts()
    index = _.indexOf scripts, _.find(scripts,{ name: receiver })

    if index == -1
      chiika.logger.error("[magenta](Chiika-API) There was a problem when sending #{message} to #{receiver}.")
    else
      @dispatch listeners[index],args...
