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

React = require('react')
{Router,Route,BrowserHistory,Link} = require('react-router')
{ReactTabs,Tab,Tabs,TabList,TabPanel} = require 'react-tabs'

_ = require 'lodash'

AnimeListMixin =
  name: null
  ipcCall: ->
    @setGrid()
  setGrid: ->
    if @name == "watching"
      @grid = chiika.domManager.addNewGrid 'anime',@name,1
    lastColPos = -1
    lastCol = {}

    w2ui.watching.on 'columnDragStart',(e) =>
      lastColPos = e.origColumnNumber
      lastCol = @grid.columns[lastColPos]
    w2ui[@grid.name].on 'columnDragEnd',(ex) =>
      @grid.columns = w2ui[@grid.name].columns
      newColPos = ex.targetColumnNumber + 1
      console.log ex
      if lastColPos == newColPos
        return

      findObj = {}
      findObjColumn = {}
      findObj.column = findObjColumn
      findObj.column.name = lastCol.field

      match = _.find(chiika.appOptions.AnimeListColumns,findObj)
      index = _.indexOf chiika.appOptions.AnimeListColumns,_.find(chiika.appOptions.AnimeListColumns,findObj )

      if index == -1
        chiika.logDebug "There is a problem dragging the column."
      else
        match.column.order = newColPos
        chiika.appOptions.AnimeListColumns.splice(index,1,match)
        chiika.logDebug lastCol.field + " dragged from " + lastColPos + " to " + newColPos
        chiika.applicationDelegate.saveOptions chiika.appOptions

        chiika.gridManager.prepareGridData chiika.appOptions
  componentDidMount: ->
    chiika.ipcListeners.push this
  componentWillUnmount: ->
    _.pull chiika.ipcListeners,this

module.exports = AnimeListMixin
