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
ContextMenu = require './ContextMenu'
fs = require 'fs'


Grid = {
    name   : '',
    reorderColumns:true,
    columns: [


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
  contextMenu:null
  fileFuncMap:[
    { column: 'typeWithIcon',fnc: 'addTypeWithIconColumn' },
    { column: 'title',fnc: 'addTitleColumn' },
    { column: 'score',fnc: 'addScoreColumn' },
    { column: 'progress',fnc: 'addProgressColumn' },
    { column: 'season',fnc: 'addSeasonColumn' },
    { column: 'typeWithText',fnc: 'addTypeWithTextColumn' },
    { column: 'typeWithIconColors',fnc: 'addTypeWithIconColors' },
    { column: 'airingStatusText',fnc: 'addAiringStatusText' },
  ]
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
  componentWillMount: ->
    @list = []
    @props.columns.sort( (a,b) ->
      x = a.order
      y = b.order
      return !((x < y) ? -1 : ((x > y) ? 1 : 0)))
    console.log @props.columns

    for col in @props.columns
      func = $.grep(@fileFuncMap, (e) -> return e.column == col.name)
      if func != undefined
        this[func[0].fnc]()
  componentWillUnmount: ->
    columnDataPath = cn.chiikaNode.rootOptions.modulePath+'Data/column.json'
    stream = fs.createWriteStream(columnDataPath)
    columnData = []

    for col,index in w2ui[@localGrid.name].columns
      columnData.push { column: { name: col.field, order: index }}
    console.log JSON.stringify columnData


    stream.once 'open', (fd) =>
      stream.write JSON.stringify columnData
      stream.end('')

    @localGrid.columns = []

  setGridName: (grid) ->
    @localGrid.name = grid
    Search.updateAnimelistState grid
    Search.animeListJsObjects.set grid,this
    @gridName = grid
  setList: (l) ->
    @list = l
    @localGrid.records = @list
  removeColumn: (name) ->
    _ = require 'lodash'
    _.remove w2ui[@localGrid.name].columns, { field: name }
    w2ui[@localGrid.name].refresh()
  refresh: ->
    w2ui[@localGrid.name].refresh()
    w2ui[@localGrid.name].columns = @localGrid.columns
  addTypeWithIconColors: ->
    @localGrid.columns.push { field: 'typeWithIconColors',  caption: '',attr: "align=center", hidden:true,size: '40px',render:(icon) ->
      '<i class="'+icon.icon+'" style="color:'+icon.airingStatusColor+'"></i>' }
  addTypeWithTextColumn: ->
    @localGrid.columns.push { field: 'typeWithText', caption: 'Type', size: '120px',resizable: true, sortable: true  },
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
  addAiringStatusTextColumn: ->
    @localGrid.columns.push { field: 'airingStatusText', caption: 'Type', size: '120px',resizable: true, sortable: true,hidden:true  },
  addScoreColumn: ->
    @localGrid.columns.push { field: 'score', caption: 'Score', size: '10%',resizable: true, sortable: true }
  addProgressColumn: ->
    @localGrid.columns.push { field: 'progress', caption: 'Progress', size: '40%',resizable: true, sortable: true}
  addSeasonColumn: ->
    @localGrid.columns.push { field: 'season', caption: 'Season', size: '120px',resizable: true, sortable: true  }


  getGrid: () ->
    @localGrid
  componentDidMount: ->
    activeMap = []

    for val in @localGrid.columns
      obj = {}
      obj.key = val.field
      obj.value = true
      activeMap.push obj

    console.log activeMap
    @contextMenu = new ContextMenu this,@localGrid.name,activeMap




module.exports = AnimeListMixin
