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
#THIS CLASS IS NOW OBSOLOTE

class GridManager
  fileFuncMap:[
      { column: 'typeWithIcon',fnc: 'addTypeWithIconColumn' },
      { column: 'title',fnc: 'addTitleColumn' },
      { column: 'score',fnc: 'addScoreColumn' },
      { column: 'progress',fnc: 'addProgressColumn' },
      { column: 'season',fnc: 'addSeasonColumn' },
      { column: 'typeWithText',fnc: 'addTypeWithTextColumn' },
      { column: 'typeWithIconColors',fnc: 'addTypeWithIconColors' },
      { column: 'airingStatusText',fnc: 'addAiringStatusTextColumn' },
    ],
  grids: []
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


module.exports = GridManager
