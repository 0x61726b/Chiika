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

_ = require 'lodash'
_when = require 'when'
TabView = require './ui-tabView'


module.exports = class UIManager
  uiItems: []
  preloadPromises: []
  preloadUIItems: () ->
    chiika.logger.verbose("[magenta](UI-Manager) Preload UI items..")

    _.forEach(chiika.dbManager.uiDb.uiData, (v,k) => @preloadPromises.push @addUIItem(v,->) )
    _when.all(@preloadPromises).then( => chiika.logger.verbose("[magenta](UI-Manager) Preload complete.") )



  uiReconstruct: ->
    chiika.logger.verbose("[magenta](UI-Manager) Reconstruct requested.")
    _.forEach @uiItems, (v,k) =>
      chiika.apiManager.chiikaApi.emit 'uiReconstruct-item',v


  addTabView: (item) ->
    tabView = new TabView({ name: item.name, displayName: item.displayName, tabView: item.tabView })
    dbView = chiika.dbManager.createViewDb(item.name)
    tabView.setDatabaseInterface(dbView)
    tabView.loadTabData()
    tabView

  addUIItem: (item,callback) ->
    defer = _when.defer()
    if item.displayType == 'tabView'
      tabView = @addTabView(item)
      @preloadPromises.push tabView.db.promise

      @uiItems.push @addTabView(item)
      chiika.dbManager.uiDb.addUIItem item, (err,count) =>
        defer.resolve()
        callback()

      chiika.logger.verbose("[magenta](UI-Manager) Added a UI Item #{item.name}")
    defer.promise
  removeUIItem: (item) ->
    match = _.find uiItems,item
    index = _.indexOf uiItems,match

    if match?
      uiItems.splice(index,1,match)
      chiika.logger.verbose("[magenta](UI-Manager) Removed a UI Item #{item.name}")
