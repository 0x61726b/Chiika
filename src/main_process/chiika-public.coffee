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
    @emitter                                    = new Emitter
    {@logger, @db,@parser,@ui,@viewManager}     = params
    @users                                      = @db.usersDb
    @custom                                     = @db.customDb
    @uiDb                                       = @db.uiDb
    @utility                                    = chiika.utility

  #
  #
  #
  makeGetRequest:(url,headers,callback) ->
    if _.isUndefined callback
      throw new InvalidParameterException("You have to supply a callback to 'makeGetRequest' method.")
    chiika.requestManager.makeGetRequest(url,headers,callback)


  #
  #
  #
  makePostRequest:(url,headers,body,callback) ->
    if _.isUndefined callback
      throw new InvalidParameterException("You have to supply a callback to 'makePostRequest' method.")
    chiika.requestManager.makePostRequest(url,headers,body,callback)



  #
  #
  #
  makeGetRequestAuth:(url,user,headers,callback) ->
    if _.isUndefined callback
      throw new InvalidParameterException("You have to supply a callback to 'makeGetRequestAuth' method.")
    chiika.requestManager.makeGetRequestAuth(url,user,headers,callback)


  makePostRequestAuth:(url,user,headers,body,callback) ->
    if _.isUndefined callback
      throw new InvalidParameterException("You have to supply a callback to 'makePostRequestAuth' method.")
    chiika.requestManager.makePostRequestAuth(url,user,headers,body,callback)




  sendMessageToWindow: (windowName,message,args) ->
    wnd = chiika.windowManager.getWindowByName(windowName)

    if !_.isUndefined wnd
      wnd.webContents.send message,args


  requestViewUpdate: (viewName,owner,defer,params) ->
    if !params?
      params = {}

    if _.isUndefined params
      params = {}

    view = chiika.viewManager.getViewByName(viewName)
    if view?
      @emit 'view-update', { calling: owner, view: view, defer: defer, params: params }
    else
      chiika.logger.error("Can't update a non-existent view.")


  createWindow: (options,returnCall) ->
    options.name += 'modal' # service/owner name + modal , anilistmodal etc.
    chiika.windowManager.createModalWindow(options,returnCall)

  closeWindow: (windowName) ->
    wnd = chiika.windowManager.getWindowByName(windowName)
    if !_.isUndefined wnd
      wnd.close()


  executeJavaScript: (windowName,javascript) ->
    wnd = chiika.windowManager.getWindowByName(windowName)
    if !_.isUndefined wnd
      wnd.webContents.executeJavaScript(javascript)



  on: (receiver,message,callback) ->
    @emitter.on message, (args) =>
      if _.isUndefined args.calling
        # console.log "#{receiver} - #{message}"
        # chiika.logger.error("Emitter has received #{message} but we don't know who to call to #{receiver} != #{args.calling}. Are you sure about this?")
        # Assume, if no caller call everyone
        callback(args)
      if args.calling == receiver
        script = chiika.apiManager.getScriptByName(receiver)

        if script?
          if script.isActive
            callback(args)
          else
            chiika.logger.warn("Skipping #{receiver} - #{message} because #{receiver} is not active.")

  emit: (message,args) ->
    chiika.logger.debug("Emitting #{message} to #{args.calling}")
    @emitter.emit message,args

  dispatch: (handler,args...)->
    @emitter.constructor.dispatch handler,args...


  emitTo: (receiver,message,args...) ->
    @emitter.emit message,args...

    # if index == -1
    #   chiika.logger.error("[magenta](Chiika-API) There was a problem when sending #{message} to #{receiver}.")
    # else
    #   @dispatch listeners[index],args...
