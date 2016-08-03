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
TabView         = require './ui-tabView'


module.exports = class UIManager
  uiItems: []
  preloadPromises: []



  #
  # The purpose of this method is to load UI views and their respective databases
  # Why 'preload' is, I wanted to delay script compilation before UI is loaded
  # So scripts can access UI elements without subscribing to a event.
  # I think it worts the trade off between loading time, which doesn't affect much
  # @return
  preloadUIItems: () ->
    chiika.logger.verbose("[magenta](UI-Manager) Preloading UI items..")
    defer = _when.defer()

    if chiika.dbManager.uiDb.uiData.length == 0
      chiika.logger.warn("[magenta](UI-Manager) There are no UI items...Calling reconstruct event")
      scripts = chiika.apiManager.getScripts()

      async = []
      for script in scripts
        if script.isActive
          defer = _when.defer()
          async.push defer.promise
          chiika.chiikaApi.emit 'reconstruct-ui',{ defer: defer, calling: script.name }
      return _when.all(async)
    else
      _.forEach(chiika.dbManager.uiDb.uiData, (v,k) => @preloadPromises.push @addUIItem(v,->) )
      return _when.all(@preloadPromises)


  #
  # Will check if there are empty 'dataSource's. If one is found, we will mark it needUpdate
  # then update method will call the script and there the script can fill data
  # If the data source meant to be empty, just ignore the callback on the script end
  # @return
  checkUIData: ->
    requiresUpdate = []
    _.forEach @uiItems, (v,k) =>
      dataSource = v.dataSource

      if dataSource? && _.isEmpty dataSource
        v.needUpdate = true
        requiresUpdate.push v

    # Sort if necessary
    # Naah
    chiika.logger.info("#{requiresUpdate.length} item is waiting to update!")

    async = []
    requiresUpdate.map (item,i) =>
      async.push item.update()

    _when.all(async)


  #
  # Adds a tab view, creates its associated DB interface and tries to load its data from DB
  #
  addTabView: (item) ->
    tabView = (new TabView({ name: item.name,
    displayName: item.displayName,
    TabGridView: item.TabGridView,
    owner: item.owner,
    category: item.category,
    displayType: item.displayType
     }))
    dbView = chiika.dbManager.createViewDb(item.name)
    tabView.setDatabaseInterface(dbView)
    tabView.loadTabData()
    tabView


  #
  # Adds a UI item respective to their type, then creates a DB view for its data source
  #
  # @return {Object} promise Returns a promise
  addUIItem: (item,callback) ->
    defer = _when.defer()
    if item.displayType == 'TabGridView'
      tabView = @addTabView(item)
      @preloadPromises.push tabView.db.promise

      @uiItems.push tabView
      defer.resolve()
      chiika.dbManager.uiDb.addUIItem item, (err,count) =>
        defer.resolve()
        callback(err,count)
        #@checkUIData()


      chiika.logger.verbose("[magenta](UI-Manager) Added a UI Item #{item.name}")
    defer.promise

  #
  # Returns a UI item
  # @param {String} itemName Name of the UI item
  # @return {Object} UI Item
  getUIItem: (itemName) ->
    instance = _.find @uiItems, { name: itemName }

    if instance?
      instance
    else
      chiika.logger.error("Request UI item not found #{itemName}")
      return null

  #
  # Returns the total number of UI items stored on DB
  # @returm {Integer}
  getUIItemsCount: ->
    chiika.dbManager.uiDb.uiData.length

  getUIItems: ->
    @uiItems



  removeUIItem: (item) ->
    match = _.find uiItems,item
    index = _.indexOf uiItems,match

    if match?
      uiItems.splice(index,1,match)
      chiika.logger.verbose("[magenta](UI-Manager) Removed a UI Item #{item.name}")
