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
{Emitter} = require 'event-kit'
ipcHelpers = require '../ipcHelpers'
{BrowserWindow, ipcRenderer,remote} = require 'electron'

_ = require 'lodash'


class GridManager
  grids: []
  constructor: (chiika) ->
    chiika.emitter.on 'animelist-stab-changed', (args) =>
      @currentAnimeTab = args.index
  prepareGridData: (options) ->
    @animeListColumns = []
    console.log options.AnimeListColumns
    _.forEach(options.AnimeListColumns, (v,k) =>
      @animeListColumns.push v.column
      )
  checkIfGridExists: (name) ->
    console.log name
    if _.isUndefined _.find @grids,_.matchesProperty 'name', name
      return false
    else
      return true

  handleColumnDrag: (grid,oldPos,newPos) ->
    console.log "Column drag " + oldPos + " to " + newPos

  handleRowDoubleClick: (grid,rId,cInd) ->
    animeId = grid.getUserData rId - 1,'animeId'
    chiika.animeDetailsPreRequest animeId
    window.location = "#Anime/" + animeId
  addGrid: (name,grid) ->
    @grids[name] = grid
    console.log @getSearchInput()
    grid.filterBy(1,@getSearchInput())
  getGridByName: (name) ->
    @grids[name]
  getSearchInput: ->
    $(".form-control").val()
  filterGrid: (filter) ->
    #Find out which grid to filter
    if _.isUndefined @currentAnimeTab
      @currentAnimeTab = 0
    if @currentAnimeTab == 0 #watching
      @getGridByName('watching').filterBy(1,filter)
    if @currentAnimeTab == 1 #PlanToWatch
      @getGridByName('ptw').filterBy(1,filter)
    if @currentAnimeTab == 2 #watching
      @getGridByName('completed').filterBy(1,filter)
    if @currentAnimeTab == 3 #watching
      @getGridByName('onhold').filterBy(1,filter)
    if @currentAnimeTab == 4 #watching
      @getGridByName('dropped').filterBy(1,filter)




module.exports = GridManager
