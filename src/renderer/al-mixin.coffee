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
_when = require 'when'

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

      timeOutFnc = (o) =>
        @findGridOrderAfterDrag(o)
      setTimeout(timeOutFnc,500,lastCol)
      return
      #console.log ex
      if lastColPos == newColPos
        return

      findObj = {}
      findObjColumn = {}
      findObj.column = findObjColumn
      findObj.column.name = lastCol.field

      match = _.find(chiika.appOptions.AnimeListColumns,findObj)
      index = _.indexOf chiika.appOptions.AnimeListColumns,match

      if index == -1
        chiika.logDebug "There is a problem dragging the column."
      else
        match.column.order = newColPos
        chiika.appOptions.AnimeListColumns.splice(index,1,match)
        chiika.logDebug lastCol.field + " dragged from " + lastColPos + " to " + newColPos
        chiika.applicationDelegate.saveOptions chiika.appOptions

        chiika.gridManager.prepareGridData chiika.appOptions
  findGridOrderAfterDrag: (orig)->
    grid = w2ui[@grid.name]

    newColumn = _.find(grid.columns, { field: orig.field })
    newIndex = _.indexOf grid.columns, newColumn

    findObj = {}
    findObjColumn = {}
    findObj.column = findObjColumn
    findObj.column.name = orig.field

    match = _.find(chiika.appOptions.AnimeListColumns,findObj)
    index = _.indexOf chiika.appOptions.AnimeListColumns,match

    if index == -1
      chiika.logDebug "There is a problem dragging the column."
    else
      counter = 0
      _.forEach grid.columns, (v,k) =>
        obj1 = {}
        obj1Column = {}
        obj1.column = obj1Column
        obj1.column.name = v.field
        findCounterpartInOptionsArray = _.find chiika.appOptions.AnimeListColumns, obj1
        iFindCounterpartInOptionsArray = _.indexOf chiika.appOptions.AnimeListColumns, findCounterpartInOptionsArray

        if iFindCounterpartInOptionsArray != -1
          findCounterpartInOptionsArray.column.order = counter
          chiika.appOptions.AnimeListColumns.splice(iFindCounterpartInOptionsArray,1,findCounterpartInOptionsArray)
        counter = counter + 1

      chiika.logDebug orig.field + " dragged to " + newIndex
      chiika.applicationDelegate.saveOptions chiika.appOptions

      chiika.gridManager.prepareGridData chiika.appOptions


  componentDidMount: ->
    chiika.ipcListeners.push this
  componentWillUnmount: ->
    _.pull chiika.ipcListeners,this

module.exports = AnimeListMixin
