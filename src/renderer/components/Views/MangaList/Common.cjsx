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
#Date: 27.1.2016
#authors: arkenthera
#Description:
#----------------------------------------------------------------------------
React = require 'react'
Search = require './../../RouteManager'

Grid = {
    name   : '',
    reorderColumns:true,
    columns: [
        { field: 'title', caption: 'Title', size: '50%',resizable: true, sortable: true  },
        { field: 'score', caption: 'Score', size: '15%',resizable: true, sortable: true,
        render:(score) ->
          if score.score == 0
            '<div>-</div>'
          else
            '<div>'+score.score+'</div>'  },
        { field: 'chapters', caption: 'Chapters', size: '15%',resizable: true, sortable: true },
        { field: 'volumes', caption: 'Volumes', size: '20%',resizable: true, sortable: true  },
    ],
    records: [
    ],
    menu: [
        { id: 1, text: 'Free', icon: 'fa fa-hashtag' },
        { id: 2, text: 'Stuff', icon: 'fa fa-camera' },
        { id: 4, text: 'Here', icon: 'fa fa-minus' },
        { id: 5, text: 'Maybe', icon: 'fa fa-minus' },
        { id: 6, text: 'Edit', icon: 'fa fa-minus' },
        { id: 7, text: 'Css', icon: 'fa fa-minus' }
    ],
    onMenuClick: (event) ->
      console.log event

}

MangaListMixin =
  componentWillMount: ->
    @list = []
  setGridName: (grid) ->
    Grid.name = grid
    Search.updateMangalistState grid
  setList: (l) ->
    @list = l
    Grid.records = @list
  getGrid: () ->
    Grid
  componentWillUnmount: ->


module.exports = MangaListMixin
