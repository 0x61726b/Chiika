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
React = require 'React'
Search = require './../../RouteManager'
cn = require './../../../ChiikaNode'
Grid = {
    name   : '',
    reorderColumns:true,
    columns: [
      { field: 'typeWithIcon', caption: '',attr: "align=center", size: '40px',render:(icon) ->
        '<i class="'+icon.icon+'"></i>'  },
        {
           field: 'title',
           caption: 'Title',
           size: '40%',
           resizable: true,
           sortable: true,
           render:(title) ->
             '<div anime-id="'+title.animeId+'" id="details">'+title.title+'</a>'
        },
        { field: 'score', caption: 'Score', size: '10%',resizable: true, sortable: true},
        { field: 'progress', caption: 'Progress', size: '40%',resizable: true, sortable: true}
        { field: 'season', caption: 'Season', size: '120px',resizable: true, sortable: true  },
        { field: 'typeWithText', caption: 'Type', size: '120px',resizable: true, sortable: true,hidden:true  },
        { field: 'typeWithIconColors',  caption: '',attr: "align=center", hidden:true,size: '40px',render:(icon) ->
          '<i class="'+icon.icon+'" style="color:'+icon.airingStatusColor+'"></i>' }
        { field: 'airingStatusText', caption: 'Type', size: '120px',resizable: true, sortable: true,hidden:true  },
    ],
    records: [
    ]
    onClick: (event) ->
      false
    onDblClick: (event) ->
      window.location = "#Anime/" + Grid.records[event.recid].animeId
}

AnimeListMixin =
  gridName:""
  fileFuncMap:[
    { column: 'typeWithIcon',fnc: 'addTypeWithIconColumn' },
    { column: 'Title',fnc: 'addTitleColumn' },
    { column: 'Score',fnc: 'addScoreColumn' },
    { column: 'Progress',fnc: 'addProgressColumn' },
    { column: 'Season',fnc: 'addSeasonColumn' },
  ]
  localGrid:{
    name:'',
    reorderColumn:true
    columns:[]
    records:[]
    onClick: (event) ->
      false
    onDblClick: (event) =>
      window.location = "#Anime/" + @localGrid.records[event.recid].animeId
  }
  componentWillMount: ->
    @list = []

    @props.columns.sort( (a,b) ->
      x = a.order
      y = b.order
      return !((x < y) ? -1 : ((x > y) ? 1 : 0)))

    for col in @props.columns
      func = $.grep(@fileFuncMap, (e) -> return e.column == col.name)
      console.log func[0].fnc
      this[func[0].fnc]()
  componentWillUnmount: ->
    @localGrid.columns = []

  setGridName: (grid) ->
    @localGrid.name = grid
    Search.updateAnimelistState grid
    Search.animeListJsObjects.set grid,this
    @gridName = grid
  setList: (l) ->
    @list = l
    @localGrid.records = @list

  addTypeWithIconColumn: ->
    @localGrid.columns.push { field: 'typeWithIcon', caption: '',attr: "align=center", size: '40px',render:(icon) ->
      '<i class="'+icon.icon+'"></i>'  }
  addTitleColumn: ->
    @localGrid.columns.push {
       field: 'title',
       caption: 'Title',
       size: '40%',
       resizable: true,
       sortable: true,
       render:(title) ->
         '<div anime-id="'+title.animeId+'" id="details">'+title.title+'</a>'
    }
  addScoreColumn: ->
    @localGrid.columns.push { field: 'score', caption: 'Score', size: '10%',resizable: true, sortable: true }
  addProgressColumn: ->
    @localGrid.columns.push { field: 'progress', caption: 'Progress', size: '40%',resizable: true, sortable: true}
  addSeasonColumn: ->
    @localGrid.columns.push { field: 'season', caption: 'Season', size: '120px',resizable: true, sortable: true  }


  getGrid: () ->
    @localGrid
  componentDidMount: ->




module.exports = AnimeListMixin
