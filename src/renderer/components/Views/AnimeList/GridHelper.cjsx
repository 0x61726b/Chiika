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
#Date: 7.2.2016
#authors: arkenthera
#Description:
#----------------------------------------------------------------------------

class AnimelistGridHelper
  fileFuncMap:[
      { column: 'typeWithIcon',fnc: 'addTypeWithIconColumn' },
      { column: 'title',fnc: 'addTitleColumn' },
      { column: 'score',fnc: 'addScoreColumn' },
      { column: 'progress',fnc: 'addProgressColumn' },
      { column: 'season',fnc: 'addSeasonColumn' },
      { column: 'typeWithText',fnc: 'addTypeWithTextColumn' },
      { column: 'typeWithIconColors',fnc: 'addTypeWithIconColors' },
      { column: 'airingStatusText',fnc: 'addAiringStatusTextColumn' },
    ]
  grid:null
  constructor: (grid) ->
    @grid = grid
  getGrid:() ->
    @grid

  addColumn: (name) ->
    res = $.grep @fileFuncMap, (e) -> e.column == name

    this[res[0].fnc]()
  removeColumn: (name) ->
    res = $.grep @grid.columns, (e) -> e.field == name

    if res.length > 0
      obj = res[0]

      _ = require 'lodash'
      _.remove @grid.columns, { field: obj.field }
      console.log obj
      w2ui[@getGrid()] = @grid
      w2ui[@getGrid()].refresh()

  addTypeWithIconColors: ->
    @grid.columns.push { field: 'typeWithIconColors',  caption: '',attr: "align=center",size: '40px',render:(icon) ->
      '<i class="'+icon.icon+'" style="color:'+icon.airingStatusColor+'"></i>' }
  addTypeWithTextColumn: ->
    @grid.columns.push { field: 'typeWithText', caption: 'Type', size: '120px',resizable: true, sortable: true  },
  addTypeWithIconColumn: ->
    @grid.columns.push { field: 'typeWithIcon', caption: '',attr: "align=center", size: '40px',render:(icon) ->
      '<i class="'+icon.icon+'"></i>'  }
  addTitleColumn: ->
    @grid.columns.push {
       field: 'title',
       caption: 'Title',
       size: '40%',
       resizable: true,
       sortable: true,
       render:(title) ->
         '<div anime-id="'+title.animeId+'" id="details">'+title.title+'</a>'
    }
  addAiringStatusTextColumn: ->
    @grid.columns.push { field: 'airingStatusText', caption: 'Airing Status', size: '120px',resizable: true, sortable: true},
  addScoreColumn: ->
    @grid.columns.push { field: 'score', caption: 'Score', size: '10%',resizable: true, sortable: true }
  addProgressColumn: ->
    @grid.columns.push { field: 'progress', caption: 'Progress', size: '40%',resizable: true, sortable: true}
  addSeasonColumn: ->
    @grid.columns.push { field: 'season', caption: 'Season', size: '120px',resizable: true, sortable: true  }

module.exports = AnimelistGridHelper
