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
UIItem          = require './ui-item'
TabView         = require './ui-tabView'
SubView         = require './view-subview'



module.exports = class UIManager
  uiItems: []
  preloadPromises: []


  #
  # Returns a UI item
  # @param {String} itemName Name of the UI item
  # @return {Object} UI Item
  getUIItem: (itemName) ->
    instance = _.find @uiItems, { name: itemName }

    if instance?
      instance
    else
      chiika.logger.error("getUIItem UI item not found #{itemName}")
      return null

  addUIItem: (item) ->
    instance = _.find @uiItems, { name: item.name }
    index    = _.indexOf @uiItems, instance

    if index == -1
      @uiItems.push item
    else
      @uiItems.splice(index,1,instance)

  #
  # Returns the total number of UI items stored on DB
  # @returm {Integer}
  getUIItemsCount: ->
    @uiItems.length

  getUIItems: ->
    @uiItems


  removeUIItem: (item) ->
    match = _.find uiItems,item
    index = _.indexOf uiItems,match

    if match?
      @uiItems.splice(index,1,match)
      chiika.logger.verbose("[magenta](UI-Manager) Removed a UI Item #{item.name}")
