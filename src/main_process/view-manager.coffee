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

_               = require 'lodash'
_when           = require 'when'
View            = require './view'
TabView         = require './view-tabview'
SubView         = require './view-subview'


module.exports = class ViewManager
  views: []

  getViewByName: (viewName) ->
    find = _.find @views, (o) -> o.name == viewName
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
        _.forEach config.views, (v) =>
          @addView(v)
        @loadViewData().then(resolve)


  loadViewData: ->
    new Promise (resolve) =>
      async = []
      _.forEach @views, (view) =>
        promise = view.db.load()
        async.push promise
        promise.then (data) =>
          if data.length == 0
            view.needUpdate = true
          else
            chiika.logger.info("View #{view.name} has data length of #{data.length}")
            view.setDataSource(data)
      _when.all(async).then =>
        _.forEach @views, (view) =>
          if view.needUpdate
            view.update()
        resolve()


  addView: (view,callback) ->

    config = chiika.settingsManager.readConfigFile('view')

    if config?
      #Check this view exists
      findConfig = _.find config.views,(o) -> o.name == view.name
      indexConfig = _.indexOf config.views,findConfig

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

    findView = _.find @views,(o) -> o.name == view.name
    index    = _.indexOf @views,findView

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

    else if view.displayType == "subview"
      newView = new SubView(view)

    chiika.logger.verbose("Adding new view #{view.displayType} - #{view.name}")


    dbView = chiika.dbManager.createViewDb(view.name)
    newView.setDatabaseInterface(dbView)


    if index != -1
      @views.splice(index,1,newView)
    else
      @views.push newView
