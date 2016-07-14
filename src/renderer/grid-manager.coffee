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
    if _.isUndefined _.find @grids,_.matchesProperty 'name', 'watching'
      return false
    else
      return true
  removeGrid: (name) ->
    _.remove @grids, (o) ->
      return o.name == name
  addGrid: (grid) ->
    @grids.push grid
  addTypeWithIconColors: (grid) ->
    grid.columns.push { field: 'typeWithIconColors',  caption: '',attr: "align=center",size: '40px',render:(icon) ->
      '<i class="'+icon.icon+'" style="color:'+icon.airingStatusColor+'"></i>' }
  addTypeWithTextColumn: (grid) ->
    grid.columns.push { field: 'typeWithText', caption: 'Type', size: '120px',resizable: true, sortable: true  },
  addTypeWithIconColumn: (grid) ->
    grid.columns.push { field: 'typeWithIcon', caption: '',attr: "align=center", size: '40px',render:(icon) ->
      '<i class="'+icon.icon+'"></i>'  }
  addTitleColumn: (grid) ->
    grid.columns.push {
       field: 'title',
       caption: 'Title',
       size: '40%',
       resizable: true,
       sortable: true,
       render:(title) ->
         '<div anime-id="'+title.animeId+'" id="details">'+title.title+'</div>'
    }
  addAiringStatusTextColumn: (grid) ->
    grid.columns.push { field: 'airingStatusText', caption: 'Airing Status', size: '120px',resizable: true, sortable: true},
  addScoreColumn: (grid) ->
    grid.columns.push { field: 'score', caption: 'Score', size: '10%',resizable: true, sortable: true }
  addProgressColumn: (grid) ->
    grid.columns.push { field: 'progress', caption: 'Progress', size: '40%',resizable: true, sortable: true, render:(progress) ->
      '<div class="progress-bar thin">
      <div class="indigo" style="width:'+progress.progress+'%;height: 14px;" />
      </div>' }
  addSeasonColumn: (grid) ->
    grid.columns.push { field: 'season', caption: 'Season', size: '120px',resizable: true, sortable: true  }


module.exports = GridManager
