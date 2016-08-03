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

React                               = require('react')

_                                   = require 'lodash'
#Views

module.exports = class ViewManager
  #
  # Records the tab index of a tab grid view
  #
  tabViewTabIndexCounter: []

  scrollData: []

  getComponent: (name) ->
    if name == 'TabGridView'
      return './view-tabGrid'

  onTabSelect: (viewName,index,last) ->
    console.log viewName
    @tabViewTabIndexCounter[viewName] = { index: index }
    if @scrollData[viewName]?
      @scrollData[viewName].scrollData[last] = $(".objbox").scrollTop()
    else
      @scrollData[viewName] = { scrollData: { } }
      @scrollData[viewName].scrollData[last] = $(".objbox").scrollTop()

    console.log @scrollData[viewName]
  onTabViewUnmount: (viewName) ->
    #@scrollData[viewName] = null

  getTabScrollAmount: (viewName,index) ->
    if @scrollData[viewName]?
      scroll = @scrollData[viewName].scrollData[index]
      if scroll?
        scroll
      else
        0
    else
      0
  getTabSelectedIndexByName: (viewName) ->
    v = @tabViewTabIndexCounter[viewName]
    if v?
      v
    else
      { index: 0 }
      #chiika.logger.error("There was a problem with remembering last tab index for #{viewName}")
