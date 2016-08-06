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

_         = require 'lodash'
_when     = require 'when'
UIItem    = require './ui-item'

{InvalidOperationException,InvalidParameterException} = require './exceptions'


module.exports = class TabView extends UIItem
  TabGridView:null
  gridSuffix: '_grid'
  constructor: (params={}) ->
    {@TabGridView} = params
    super params

  loadTabData: ->
    new Promise (resolve) =>
      onAll = (data) =>
        L = data.length

        if L == 0
          @needUpdate = true
        else
          @setDataSource(data)

        _.forEach data, (v,k) =>
          @setTabData(v.name,v.data)

        resolve()
      @db.all(onAll)

  getTabData: (tabName) ->
    findUIItem = _.find @children, { name: tabName + @gridSuffix }
    index = _.indexOf @children, findUIItem

    if findUIItem?
      return findUIItem.dataSource

  getData: ->
    data = []
    _.forEach @children, (v,k) ->
      _.forEach v.dataSource, (v,k) ->
        data.push v
    data


  save: ->
    chiika.logger.info("[red](#{@name}) Saving tab view data...")

    async = []

    _.forEach @children, (v,k) =>
      deferSave = _when.defer()
      async.push deferSave.promise
      onSaved = ->
        deferSave.resolve()
      @db.save { name: v.name, data: v.dataSource }, onSaved

    _when.all(async)

  #
  # Set multiple tabs at once
  # Example
  #   @example
  #    [
  #     {name: 'watching', data: [] }
  #     {name: 'ptw', data: [] }
  #     {name: 'dropped', data: [] }
  #     {name: 'onhold', data: [] }
  #     {name: 'completed', data: [] }
  #    ]
  # @param {Array} data
  # @return
  setData: (data) ->
    if _.isUndefined data
      throw new InvalidParameterException("You didn't specify data to be added.")

    if !_.isArray data
      throw new InvalidParameterException("Specified data has to be type of array.")

    chiika.logger.info("Setting data source for #{@name}")

    @dataSource = data
    _.forEach @dataSource, (v,k) =>
      @setTabData(v.name,v.data)

    @save()

  #
  # A Tab view consists of tabs
  # Each tab has a child UIItem which holds the grid data
  # Tabs are unique to their name, so we set the data using their names as a key
  # @param {String} tabName Name of the tab,
  # @param {Array} data Array of records to be added to the grid. The number of properties in each record must match the grid configuration.
  # @return
  setTabData: (tabName,data) ->
    checkName = tabName.indexOf @gridSuffix
    if checkName == -1
      tabName += @gridSuffix
    uiItem = new UIItem({name: tabName, displayName: tabName, displayType: 'grid' })

    if _.isUndefined data
      throw new InvalidParameterException("You didn't specify data to be added.")

    if !_.isArray data
      throw new InvalidParameterException("Specified data has to be type of array.")

    # _.forEach data, (v,k) =>
    #   columnCount = @TabGridView.gridColumnList.length
    #   requestedDataColumnCount = Object.keys(v).length
    #
    #   if columnCount != requestedDataColumnCount - 1 # recordId
    #     throw new InvalidOperationException("You can't add more or less columns than specified. #{columnCount} vs #{requestedDataColumnCount - 1}")


    findUIItem = _.find @children, { name: tabName }
    index = _.indexOf @children, findUIItem

    childExists = false
    if index != -1
      _.forEach @children, (v,k) =>
        if v.name == tabName
          childExists = true
          chiika.logger.warn("You are trying to set data for an existing child item. Replacing data source instead. #{v.name} vs #{tabName}")
          findUIItem.setDataSource(data)
          @children.splice(index,1,findUIItem)
          return false


    if !childExists
      @addChild uiItem
      uiItem.setDataSource(data)
