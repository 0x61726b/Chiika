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
#Date: 26.1.2016
#authors: arkenthera
#Description:
#----------------------------------------------------------------------------
React = require 'react'
Search = require './../../RouteManager'
cn = require './../../../ChiikaNode'
fs = require 'fs'
path = require 'path'

GridHelper = require './GridHelper'

AnimeListMixin =
  gridName:""
  contextMenu:null
  gh:null
  localGrid:{
    name:'',
    reorderColumns:true
    columns:[]
    records:[]
    onClick: (event) ->
      false
    onDblClick: (event) ->
      window.location = "#Anime/" + @records[event.recid].animeId
  }
  componentDidMount: ->
    @list = []

  addColumns: ->
    @props.columns.sort( (a,b) ->
      x = a.order
      y = b.order
      return !((x < y) ? -1 : ((x > y) ? 1 : 0)))

    @gh = new GridHelper @localGrid



    for col in @props.columns
      if col.hiddenDefault == false
          @gh.addColumn col.name
  componentWillUnmount: ->
    columnDataPath = path.join(process.env.CHIIKA_HOME,'Config','animeListTable.json')
    stream = fs.createWriteStream(columnDataPath)
    columnData = []

    for col,index in @props.columns
      findInGrid = $.grep w2ui[@localGrid.name].columns, (e) -> e.field == col.name

      orderInGrid = -1
      for column,j in w2ui[@localGrid.name].columns
        if column.field == col.name
          orderInGrid = j

      hidden = true
      i = -1
      if findInGrid.length > 0
        hidden = false
        i = orderInGrid
      columnData.push { column: { name: col.name, order: i,toggleable: col.toggleable,hiddenDefault:hidden}}


    stream.once 'open', (fd) =>
      stream.write JSON.stringify columnData
      stream.end('')

    @localGrid.columns = []


  setGridName: (grid) ->
    @localGrid.name = grid
    chiika.routeManager.updateAnimelistState grid
    chiika.routeManager.animeListJsObjects.set grid,this
    @gridName = grid
  setList: (l) ->
    @list = l
    @localGrid.records = @list
  removeColumn: (name) ->
    _ = require 'lodash'
    _.remove w2ui[@localGrid.name].columns, { field: name }
    _.remove @localGrid.columns, { field: name }
    w2ui[@localGrid.name].refresh()
  refresh: ->
    w2ui[@localGrid.name].columns = @localGrid.columns
    w2ui[@localGrid.name].refresh()


  getGrid: () ->
    @gh.getGrid()
  attachContextMenu: () ->






module.exports = AnimeListMixin
