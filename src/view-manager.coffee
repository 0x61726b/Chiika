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

_find                               = require 'lodash/collection/find'
_indexOf                            = require 'lodash/array/indexOf'
#Views

module.exports = class ViewManager
  #
  # Records the tab index of a tab grid view
  #
  tabViewTabIndexCounter: []

  #
  # Records the tab index of a sorted column with sort type/dir
  #
  tabViewSortInfo: []


  scrollData: []

  getComponent: (name) ->
    if name == 'TabGridView'
      return './view-tabgridview'

  onTabSelect: (viewName,index,last) ->
    @tabViewTabIndexCounter[viewName] = { index: index }
    if @scrollData[viewName]?
      @scrollData[viewName].scrollData[last] = $(".objbox").scrollTop()
    else
      @scrollData[viewName] = { scrollData: { } }
      @scrollData[viewName].scrollData[last] = $(".objbox").scrollTop()

  onTabViewUnmount: (viewName,index) ->
    @tabViewTabIndexCounter[viewName] = { index: index }
    if @scrollData[viewName]?
      @scrollData[viewName].scrollData[index] = $(".objbox").scrollTop()




  onTabSorted: (viewName,tabIndex,sortedColumn,type,direction) ->
    oldData = _find @tabViewSortInfo, (o) -> o.viewName == viewName && o.tabIndex == tabIndex
    index   = _indexOf @tabViewSortInfo, oldData

    if oldData?
      oldData.column = sortedColumn
      oldData.direction = direction
      @tabViewSortInfo.splice(index,1,oldData)
    else
      sortInfo = { viewName: viewName, tabIndex: tabIndex, column: sortedColumn, type: type, direction: direction }
      @tabViewSortInfo.push sortInfo

  getTabSortInfo: (viewName,tabIndex) ->
    sortInfo = _find @tabViewSortInfo, (o) -> o.viewName == viewName && o.tabIndex == tabIndex

    if sortInfo?
      sortInfo
    else
      null
  getTabScrollAmount: (viewName,index) ->
    if @scrollData[viewName]?
      scroll = @scrollData[viewName].scrollData[index]
      if scroll?
        scroll
      else
        null
    else
      null

  getTabSelectedIndexByName: (viewName) ->
    v = @tabViewTabIndexCounter[viewName]
    if v?
      v
    else
      { index: null }
      #chiika.logger.error("There was a problem with remembering last tab index for #{viewName}")
