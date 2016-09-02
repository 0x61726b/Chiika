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

{BrowserWindow,ipcMain} = require 'electron'

_forEach                = require 'lodash.foreach'
_assign                 = require 'lodash.assign'
_when                   = require 'when'
_find                   = require 'lodash/collection/find'
string                  = require 'string'



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

  #
  #
  #
  receive: (message,callback) ->
    ipcMain.on message,(event,args) =>
      chiika.logger.info("[yellow](IPC-Manager) Received message #{message}")
      callback(event,args)

  #
  #
  #
  systemEvent: (event,params) ->
    chiika.chiikaApi.emit 'system-event',{ name: event, params: params }

  #
  #
  #
  searching: () ->
    @receive 'make-search',(event,args) =>
      searchString = args.searchString
      searchType   = args.searchType
      searchSource = args.searchSource
      searchMode = args.searchMode

      returnFromScript = (result) =>
        event.sender.send 'make-search-response', result
      chiika.chiikaApi.emit 'search', { calling: 'search', searchString:searchString,searchMode:searchMode,searchType:searchType,searchSource:searchSource, return: returnFromScript }


  #
  #
  #
  windowMethodByName: ->
    @receive 'window-method', (event,args) =>
      win = chiika.windowManager.getWindowByName(args.window)
      win[args.method]()


  #
  #
  #
  callWindowMethod: ->
    @receive 'call-window-method', (event,method) =>
      win = BrowserWindow.fromWebContents(event.sender)
      win[method]()



  #
  #
  #
  detailsLayoutRequest: ->
    @receive 'details-layout-request', (event,args) =>
      returnFromScript = (layout) ->
        event.sender.send 'details-layout-request-response',layout

      params = { calling: args.owner, id: args.id,viewName: args.viewName, params: args.params,return: returnFromScript }
      chiika.chiikaApi.emit 'details-layout', params



  #
  #
  #
  reconstructUI: ->
    @receive 'reconstruct-ui', (event,args) =>
      #
      for script in chiika.apiManager.getScripts()
        if script.isActive
          chiika.chiikaApi.emit 'reconstruct-ui',{ calling: script.name }
      #Do something
      event.sender.send 'reconstruct-ui-response'



  #
  #
  #
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
      view = chiika.viewManager.getViewByName(args.viewName)

      params = args.params
      if view?
        onUpdateComplete = (params) =>
          event.sender.send "#{args.viewName}-refresh-response",params
        chiika.chiikaApi.requestViewUpdate(view.name,args.service,onUpdateComplete)
      else
        chiika.logger.error("#{args.viewName} couldnt be found.")


  #
  #
  #
  detailsAction: ->
    @receive 'details-action', (event,args) =>
      action = args.action
      layout = args.layout
      params = args.params

      if !action?
        chiika.logger.error("Can't perform action without action itself you baka!")

      if !layout?
        chiika.logger.error("Can't perform action without details layout")

      if !layout.owner?
        chiika.logger.error("Can't perform action knowing who to call")

      returnFromScript = (args) =>
        chiika.logger.verbose("Action performed for #{layout.owner} - #{action}")
        event.sender.send 'details-action-response', { action: action, args: args }

      chiika.chiikaApi.emit 'details-action', { calling: layout.owner, action: action, layout: layout, params: params, return: returnFromScript }



  #
  #
  #
  cardAction: ->
    @receive 'media-action', (event,args) =>
      action = args.action
      owner  = args.owner
      params = args.params

      if !action?
        chiika.logger.error("Can't perform action without action itself you baka!")

      if !owner?
        chiika.logger.error("Can't perform action knowing who to call")

      if !params?
        chiika.logger.error("Can't perform action knowing who to call")

      returnFromScript = (args) =>
        chiika.logger.verbose("Action performed for #{owner} - #{action}")
        event.sender.send "media-action-#{action}-response", args


      chiika.chiikaApi.emit 'media-action', { calling: owner, action: action, params: params,return: returnFromScript }



  #
  #
  #
  scriptAction: ->
    @receive 'script-action', (event,args) =>
      action = args.action
      owner = args.owner
      callback = args.callback
      params = args.params

      console.log params

      returnFromScript = (args) =>
        chiika.logger.verbose("Action performed for #{owner} - #{action}")
        event.sender.send "script-action-#{action}-response", args

      chiika.chiikaApi.emit action, { calling: owner, action: action, params: params,return: returnFromScript }




  #
  #
  #
  notificationBar: ->
    @receive 'notf-bar-dismiss', (event,args) =>
      chiika.notificationBar.hide()

    @receive 'notf-bar-update', (event,args) =>
      params = args.params
      chiika.chiikaApi.emit 'system-event', { calling: 'media', name:'md-update', params: params }

    @receive 'notf-bar-pick', (event,args) =>
      layout = args.layout
      entry  = args.entry

      chiika.chiikaApi.emit 'system-event', { calling: 'media', name:'md-pick', params: { layout: layout, entry: entry } }
  #
  # We receive a user pass here, redirect it to the user script and let them process it
  #
  login: ->
    @receive 'set-user-login', (event,args) =>
      returnFromLogin = (result) =>
        _assign result,args
        @send(chiika.windowManager.getLoginWindow(), 'login-response', result)
      if args.login?
        chiika.chiikaApi.emit 'set-user-login',{ calling: args.service, user: args.login.user, pass: args.login.pass, return: returnFromLogin}
      else
        params = { return: returnFromLogin,calling: args.service }
        _assign params,args
        chiika.chiikaApi.emit 'set-user-login',params

    @receive 'continue-from-login', (event,args) =>
      chiika.windowManager.getWindowByName('login').close()
      chiika.windowManager.createMainWindow()
      chiika.apiManager.postInit()


  #
  #
  #
  postInit: ->
    @receive 'post-init', (event,args) =>

      onReturn = (response) =>
        chiika.logger.info("POST-INIT is completed.")
        event.sender.send 'post-init-response'
        chiika.emitter.emit 'post-init-complete'

      scripts = chiika.apiManager.getScripts()

      async = []

      waitForScripts = _when.defer()
      async.push waitForScripts.promise

      _when.all(async).then(onReturn)

      for script in scripts
        wait = _when.defer()
        async.push wait.promise
        waitForScripts.resolve()

        chiika.chiikaApi.emit 'post-init',{ calling: script.name,defer: wait  }

  loginCustom: ->
    @receive 'set-user-auth-pin', (event,args) =>
      chiika.chiikaApi.emitTo args.service,'set-user-auth-pin',{}

  startLibraryScan: ->
    @receive 'start-library-scan', (event,args) =>
      onScanComplete = (result) =>
        event.sender.send 'scan-library-response', result

      chiika.chiikaApi.emit 'scan-library',{ return: onScanComplete }

  spectron: ->
    @receive 'spectron.', (event,args) =>
      #message will be for example spectron.set-login

      window = args.windowName
      params = args.params

      @send(chiika.windowManager.getWindowByName(window),"spectron-#{args.message}",args)


  getSettings: ->
    @receiveAnswer 'get-settings-data', (event,args) =>
      settings = chiika.settingsManager.appOptions

      if settings?
        settings

  setOption: ->
    @receive 'set-settings-option', (event,args) =>
      optionName = args.name
      optionValue = args.value

      chiika.settingsManager.setOption(optionName,optionValue)

      chiika.chiikaApi.emit 'set-settings-option',{ name: optionName, value: optionValue }



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
  setUIData: ->
    @receive 'set-ui-config', (event,args) =>
      views = chiika.viewManager.getViews()

      uiItem = args.item

      find = _find views, (o) -> o.name == uiItem.name
      if find?
        find.config[find.displayType] = uiItem.config
        chiika.uiManager.saveUIItem(find.config)


  #
  #
  #
  getViewData: ->
    @receiveAnswer 'get-view-data', (event,args) =>
      mainViews = chiika.viewManager.getViews()
      rendererViews = []

      _forEach mainViews,(view) =>
        newView = {}
        newView.displayType = view.displayType
        newView.name        = view.name
        newView.owner       = view.owner
        onGetData = (response) =>
          if response.data?
            newView.dataSource = response.data
            if response[view.displayType]?
              newView[view.displayType] = response[view.displayType]
          else
            newView.dataSource = response
          rendererViews.push newView
        chiika.chiikaApi.emit 'get-view-data', { calling: view.owner, view: view,data: view.dataSource, return: onGetData }
      rendererViews

  #
  #
  #
  getViewDataByName: ->
    @receive 'get-view-data-by-name', (event,args) =>
      view = chiika.viewManager.getViewByName(args.name)

      newView = {}
      newView.displayType = view.displayType
      newView.name        = view.name
      newView.owner       = view.owner
      onGetData = (response) =>
        if response.data?
          newView.dataSource = response.data
          if response[view.displayType]?
            newView[view.displayType] = response[view.displayType]
        else
          newView.dataSource = response
        newView
      chiika.chiikaApi.emit 'get-view-data', { calling: view.owner, view: view,data: view.dataSource, return: onGetData }
      event.sender.emit 'get-view-data-by-name-response', { name: view.name, view: newView}

  #
  #
  #
  processedViewData: (owner,view) ->
    newView = {}
    newView.displayType = view.displayType
    newView.name        = view.name
    newView.owner       = view.owner
    onGetData = (response) =>
      if response.data?
        newView.dataSource = response.data
        if response[view.displayType]?
          newView[view.displayType] = response[view.displayType]
      else
        newView.dataSource = response
    chiika.chiikaApi.emit 'get-view-data', { calling: owner, view: view,data: view.dataSource, return: onGetData }

    newView

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

  #
  #
  #
  getLoginBackgrounds: ->
    @receiveAnswer 'get-login-backgrounds', (event,args) =>
      scripts = chiika.apiManager.getScripts()



      bgs = []
      for script in scripts
        if script.instance.loginBackgrounds?
          bgs = script.instance.loginBackgrounds

      if bgs.length > 0
        return bgs
      else
        return undefined

  handleEvents: ->
    @callWindowMethod()
    @getUIData()
    @getViewData()
    @getViewDataByName()
    @getUserData()
    @getLoginBackgrounds()
    @getServices()
    @getSettings()
    @login()
    @loginCustom()
    @refreshViewByName()
    @modalWindowJsEval()
    @reconstructUI()
    @windowMethodByName()
    @detailsLayoutRequest()
    @detailsAction()
    @cardAction()
    @setOption()
    @postInit()
    @spectron()
    @startLibraryScan()
    @scriptAction()
    @notificationBar()
    @searching()
    @setUIData()
