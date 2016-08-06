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

{BrowserWindow,ipcMain,globalShortcut,Tray,Menu} = require 'electron'

_           = require 'lodash'
_when       = require 'when'
string      = require 'string'


module.exports = class IpcManager
  #
  # Answer to a message coming from renderer process.
  #
  answer: (receiver,message,args...) ->
    chiika.logger.verbose("[yellow](IPC-Manager) Sending answer #{message}-response")
    receiver.send message + '-response',args...

  #
  # Receiver is a BrowserWindow
  # Send message to a renderer process
  #
  send: (receiver,message,args...) ->
    chiika.logger.verbose("[yellow](IPC-Manager) Sending message #{message} to #{receiver.name} ")
    receiver.webContents.send message,args...

  #
  # Receive message on the main process
  #
  receiveAnswer: (message,callback) ->
    ipcMain.on message,(event,args) =>
      chiika.logger.info("[yellow](IPC-Manager) Received message #{message}")
      @answer event.sender,message,callback(event,args)

  receive: (message,callback) ->
    ipcMain.on message,(event,args) =>
      chiika.logger.info("[yellow](IPC-Manager) Received message #{message}")
      callback(event,args)

  handleEvents: ->
    @callWindowMethod()
    @getUIData()
    @getUserData()
    @login()
    @loginCustom()
    @getServices()
    @refreshViewByName()
    @modalWindowJsEval()
    @reconstructUI()
    @windowMethodByName()
    @detailsLayoutRequest()

  windowMethodByName: ->
    @receive 'window-method', (event,args) =>
      console.log args
      win = chiika.windowManager.getWindowByName(args.window)
      win[args.method]()

  callWindowMethod: ->
    @receive 'call-window-method', (event,method) =>
      console.log method
      win = BrowserWindow.fromWebContents(event.sender)
      win[method]()


  detailsLayoutRequest: ->
    @receive 'details-layout-request', (event,args) =>
      returnFromScript = (layout) ->
        event.sender.send 'details-layout-request-response',layout

      params = { calling: args.owner, id: args.id, return: returnFromScript }
      chiika.chiikaApi.emit 'details-layout', params

  reconstructUI: ->
    @receive 'reconstruct-ui', (event,args) =>
      #
      async = []
      for script in chiika.apiManager.getScripts()
        if script.isActive
          defer = _when.defer()
          async.push defer.promise
          chiika.chiikaApi.emit 'reconstruct-ui',{ defer: defer, calling: script.name }
      _when.all(async).then =>
        #Do something
        event.sender.send 'reconstruct-ui-response'


  modalWindowJsEval: ->
    @receive 'modal-window-message', (event,args) =>
      #Args must have the 'windowName' property or the script will never receive the callback
      owner = string(args.windowName).chompRight('modal').s
      console.log owner

      chiika.chiikaApi.emit 'ui-modal-message',{ calling: owner, args: args }
      # if args.status
      #   console.log "Auth pin " + args.html
      #   chiika.windowManager.getWindowByName(args.windowName).close()
      # else
      #   #Denied
      #   chiika.windowManager.getWindowByName(args.windowName).close()

  #
  # Calls script event 'view-update' to give the script a chance to update data
  #
  refreshViewByName: ->
    @receive 'refresh-view-by-name', (event,args) =>
      view = chiika.uiManager.getUIItem(args.viewName)

      deferUpdate = _when.defer()
      if view?
        chiika.chiikaApi.emit 'view-update',{ calling: args.service,view: view,defer: deferUpdate }

        deferUpdate.promise.then () =>
          uiItems = chiika.uiManager.getUIItems()

          if uiItems.length > 0
            event.sender.send 'get-ui-data-response',uiItems



  #
  # We receive a user pass here, redirect it to the user script and let them process it
  #
  login: ->
    @receive 'set-user-login', (event,args) =>
      returnFromLogin = (result) =>
        _.assign result,args
        @send(chiika.windowManager.getLoginWindow(), 'login-response', result)
      if args.login?
        chiika.chiikaApi.emit 'set-user-login',{ calling: args.service, user: args.login.user, pass: args.login.pass, return: returnFromLogin}
      else
        params = { return: returnFromLogin,calling: args.service }
        _.assign params,args
        chiika.chiikaApi.emit 'set-user-login',params

    @receive 'continue-from-login', (event,args) =>
      chiika.windowManager.showMainWindow(true)
      chiika.apiManager.postInit()


  loginCustom: ->
    @receive 'set-user-auth-pin', (event,args) =>
      chiika.chiikaApi.emitTo args.service,'set-user-auth-pin',{}
  #
  # When the main window loads , it will request UI data.
  # We send it here..
  #
  getUIData: ->
    @receiveAnswer 'get-ui-data', (event,args) =>
      uiItems = chiika.uiManager.getUIItems()

      if uiItems.length > 0
        uiItems


  #
  #
  #
  getUserData: ->
    @receiveAnswer 'get-user-data', (event,args) =>
      users = chiika.dbManager.usersDb.users

      if users.length > 0
        users


  getServices: ->
    @receiveAnswer 'get-services', (event,args) =>
      scripts = chiika.apiManager.getScripts()

      services = []
      for script in scripts
        if script.isService && script.isActive
          services.push script

      if services.length > 0
        return services
      else
        return undefined
