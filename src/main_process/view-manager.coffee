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

_find                   = require 'lodash/collection/find'
_indexOf                = require 'lodash/array/indexOf'
_forEach                = require 'lodash.foreach'
_remove                 = require 'lodash/array/remove'
_when                   = require 'when'
View                    = require './view'
TabView                 = require './view-tabview'
SubView                 = require './view-subview'



module.exports = class ViewManager
  views: []

  getViewByName: (viewName) ->
    find = _find @views, (o) -> o.name == viewName
    if find?
      find
    else
      chiika.logger.error("Trying to access non-existent view #{viewName}")
      null


  getViews: ->
    @views


  preload: ->
    new Promise (resolve) =>
      #
      # Read view config
      #
      # config = { views: [ { name: '' }] }
      config = chiika.settingsManager.readConfigFile('view')

      # No views?
      # Call reconstruct
      if !config? or config.views.length == 0
        chiika.logger.warn("[magenta](UI-Manager) There are no views...Calling reconstruct event")

        scripts = chiika.apiManager.getScripts()
        for script in scripts
          chiika.chiikaApi.emit 'reconstruct-ui',{ calling: script.name }
        resolve()
      else
        chiika.logger.info("[magenta](UI-Manager) There are #{config.views.length} views...")
        _forEach config.views, (v) =>
          @addView(v)
        @loadViewData().then(resolve)

  loadViewData: ->
    new Promise (resolve) =>
      async = []
      needUpdateCount = 0
      _forEach @views, (view) =>
        promise = view.db.load()
        async.push promise
        promise.then (data) =>
          if data.length == 0 && !view.noUpdate
            view.needUpdate = true
            needUpdateCount++
          else
            chiika.logger.info("View #{view.name} has data length of #{data.length}")
            view.setDataSource(data)
      _when.all(async).then =>
        chiika.logger.info("#{needUpdateCount} views need update.")
        wait = []
        _forEach @views, (view) =>
          if view.needUpdate
            if !view.noUpdate?
              wait.push view.update()
        _when.all(wait).then(resolve)

  removeView: (name) ->
    findView = _find @views,(o) -> o.name == name
    index    = _indexOf @views,findView

    if index != -1
      _remove @views,findView
      findView = null

      chiika.uiManager.removeUIItem(name)
      chiika.logger.info("Removed view #{name}")

  addView: (view,callback) ->

    config = chiika.settingsManager.readConfigFile('view')

    if !view.dynamic?
      if config?
        #Check this view exists
        findConfig = _find config.views,(o) -> o.name == view.name
        indexConfig = _indexOf config.views,findConfig

        if indexConfig == -1
          config.views.push view
        else
          config.views.splice(indexConfig,1,view)

        chiika.settingsManager.saveConfigFile('view',config)
        chiika.logger.info("Saving config file view...")
      else
        #Config file doesn't exists
        config = { views: [] }
        config.views.push view
        chiika.logger.info("Saving config file view...")
        chiika.settingsManager.saveConfigFile('view',config)

    findView = _find @views,(o) -> o.name == view.name
    index    = _indexOf @views,findView

    if findView?
      dataSource = findView.dataSource
      findView = view
      findView.dataSource = dataSource
      @views.splice(index,1,view)

      chiika.logger.info("Updated view #{view.name} - Data source Len #{findView.dataSource.length}")
      return

    # Create the view
    newView = {}

    # UI item
    if view.displayType == "TabGridView"
      uiItem =
        name: view.name
        type: 'side-menu-item'
        category: view.category
        display: view.displayName
        owner: view.owner
        displayType: 'TabGridView'
        tabList: view.TabGridView.tabList
        columns: view.TabGridView.gridColumnList


      chiika.uiManager.addUIItem uiItem
      newView = new SubView(view)
      newView.hasUIItem = true

    else if view.displayType == "subview"
      newView = new SubView(view)

    else if view.displayType == "CardListItem"
      uiItem =
        name: view.name
        type: 'card-list-item'
        display: view.displayName
        owner: view.owner
        displayType: 'CardListItem'
        cardProperties: view.CardListItem

      chiika.uiManager.addUIItem uiItem
      newView = new SubView(view)
      newView.hasUIItem = true

      if index != -1
        newView.dataSource = findView.dataSource


    else if view.displayType == 'CardFullEntry'
      uiItem =
        name: view.name
        type: 'card-full-entry'
        display: view.displayName
        owner: view.owner
        displayType: 'CardFullEntry'
        cardProperties: view.CardFullEntry

      chiika.uiManager.addUIItem uiItem
      newView = new SubView(view)
      newView.hasUIItem = true

    else if view.displayType == 'CardStatistics'
      uiItem =
        name: view.name
        type: 'card-statistics'
        display: view.displayName
        owner: view.owner
        displayType: view.displayType
        cardProperties: view.CardStatistics

      chiika.uiManager.addUIItem uiItem
      newView = new SubView(view)
      newView.hasUIItem = true

    else if view.displayType == 'CardListItemUpcoming'
      uiItem =
        name: view.name
        type: 'card-list-item-upcoming'
        display: view.displayName
        owner: view.owner
        displayType: 'CardListItemUpcoming'
        cardProperties: view.CardListItemUpcoming

      chiika.uiManager.addUIItem uiItem
      newView = new SubView(view)
      newView.hasUIItem = true


    else if view.displayType == 'CardItemContinueWatching'
      uiItem =
        name: view.name
        type: 'card-item-continue-watching'
        display: view.displayName
        owner: view.owner
        displayType: 'CardItemContinueWatching'
        cardProperties: view.CardItemContinueWatching

      chiika.uiManager.addUIItem uiItem
      newView = new SubView(view)
      newView.hasUIItem = true

    else if view.displayType == 'CardItemNotRecognized'
      uiItem =
        name: view.name
        type: 'card-item-not-recognized'
        display: view.displayName
        owner: view.owner
        displayType: 'CardItemNotRecognized'
        cardProperties: view.CardItemNotRecognized

      chiika.uiManager.addUIItem uiItem
      newView = new SubView(view)
      newView.hasUIItem = true

    else if view.displayType == 'none'
      newView = new SubView(view)

    chiika.logger.verbose("Adding new view #{view.displayType} - #{view.name}")

    dbView = chiika.dbManager.createViewDb(view.name)
    newView.setDatabaseInterface(dbView)
    @views.push newView
