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
Search = require './../../Search'
cn = require './../../../ChiikaNode'
Grid = {
    name   : '',
    reorderColumns:true,
    columns: [
      { field: 'icon', caption: '',attr: "align=center", size: '40px',render:(icon) ->
        '<i class="fa fa-desktop" style="color:'+icon.icon+'"></i>'  },
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
    onClick: (event) ->
      false
    onDblClick: (event) ->
      window.location = "#Anime/" + Grid.records[event.recid].animeId
}

AnimeListMixin =
  componentWillMount: ->
    @list = []
  setGridName: (grid) ->
    Grid.name = grid
    Search.updateAnimelistState grid
  setList: (l) ->
    @list = l
    Grid.records = @list
  getGrid: () ->
    Grid
  componentWillUnmount: ->


module.exports = AnimeListMixin
