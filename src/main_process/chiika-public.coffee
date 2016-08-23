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

module.exports = class ChiikaPublicApi
  emitter: null
  subscriptions: []

  constructor: (params={})->
    @emitter                                    = new Emitter
    {@logger, @db,@parser,@ui,@viewManager}     = params
    @settingsManager                            = chiika.settingsManager
    @users                                      = @db.usersDb
    @custom                                     = @db.customDb
    @uiDb                                       = @db.uiDb
    @utility                                    = chiika.utility




  #
  #
  #
  makeGetRequest:(url,headers,callback) ->
    if callback?
      chiika.requestManager.makeGetRequest(url,headers,callback)
    else
      throw new InvalidParameterException("You have to supply a callback to 'makeGetRequest' method.")


  #
  #
  #
  makePostRequest:(url,headers,body,callback) ->
    if callback?
      chiika.requestManager.makePostRequest(url,headers,body,callback)
    else
      throw new InvalidParameterException("You have to supply a callback to 'makePostRequest' method.")


  #
  #
  #
  makeGetRequestAuth:(url,user,headers,callback) ->
    if callback?
      chiika.requestManager.makeGetRequestAuth(url,user,headers,callback)
    else
      throw new InvalidParameterException("You have to supply a callback to 'makeGetRequestAuth' method.")



  #
  #
  #
  makePostRequestAuth:(url,user,headers,body,callback) ->
    if callback?
      chiika.requestManager.makePostRequestAuth(url,user,headers,body,callback)
    else
      throw new InvalidParameterException("You have to supply a callback to 'makePostRequestAuth' method.")
  #
  #
  #
  sendMessageToWindow: (windowName,message,args) ->
    wnd = chiika.windowManager.getWindowByName(windowName)
    chiika.logger.info("Sending IPC #{message} to #{windowName}")

    if wnd?
      wnd.webContents.send message,args

  #
  #
  #
  requestViewUpdate: (viewName,owner,callback,params) ->
    if !params?
      params = {}

    view = chiika.viewManager.getViewByName(viewName)
    uiItem = chiika.uiManager.getUIItem(viewName)

    onUpdateComplete = (result) =>
      view = chiika.viewManager.getViewByName(viewName)
      uiItem = chiika.uiManager.getUIItem(viewName)
      viewData = chiika.ipcManager.processedViewData(owner,view)
      
      @sendMessageToWindow('main','get-view-data-by-name-response',{ name: viewName, view: viewData })
      if view?
        if view.hasUIItem
          @sendMessageToWindow('main','get-ui-data-by-name-response',{ name: viewName, item: uiItem } )
        else
          chiika.logger.warn("#{viewName} doesn't have UI item.")
      callback?(result)

    if view?
      @emit 'view-update', { calling: owner, view: view, return: onUpdateComplete, params: params }
    else
      chiika.logger.error("Can't update a non-existent view.")



  requestViewDataUpdate: (owner,viewName) ->
    view = chiika.viewManager.getViewByName(viewName)
    viewData = chiika.ipcManager.processedViewData(owner,view)
    @sendMessageToWindow('main','get-view-data-by-name-response',{ name: viewName, view: viewData })

  #
  #
  #
  requestUIDataUpdate: (viewName) ->
    uiItem = chiika.uiManager.getUIItem(viewName)
    @sendMessageToWindow('main','get-ui-data-by-name-response',{ name: viewName, item: uiItem } )


  #
  #
  #
  requestViewUpdateDynamic: (viewName,owner,callback,params) ->
    if !params?
      params = {}

    view = chiika.viewManager.getViewByName(viewName)
    if view?
      @emit 'view-dynamic-update', { calling: owner, view: view, return: callback, params: params }
    else
      chiika.logger.error("Can't update a non-existent view.")


  #
  #
  #
  createWindow: (options,returnCall) ->
    options.name += 'modal' # service/owner name + modal , anilistmodal etc.
    chiika.windowManager.createModalWindow(options,returnCall)



  #
  #
  #
  closeWindow: (windowName) ->
    wnd = chiika.windowManager.getWindowByName(windowName)
    if wnd?
      wnd.close()

  #
  #
  #
  executeJavaScript: (windowName,javascript) ->
    wnd = chiika.windowManager.getWindowByName(windowName)
    if wnd?
      wnd.webContents.executeJavaScript(javascript)



  #
  #
  #
  on: (receiver,message,callback) ->
    @emitter.on message, (args) =>
      if !args.calling?
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
  #
  #
  #
  emit: (message,args) ->
    chiika.logger.debug("Emitting #{message} to #{args.calling}")
    @emitter.emit message,args



  #
  #
  #
  dispatch: (handler,args...)->
    @emitter.constructor.dispatch handler,args...



  #
  #
  #
  emitTo: (receiver,message,args...) ->
    @emitter.emit message,args...

    # if index == -1
    #   chiika.logger.error("[magenta](Chiika-API) There was a problem when sending #{message} to #{receiver}.")
    # else
    #   @dispatch listeners[index],args...
