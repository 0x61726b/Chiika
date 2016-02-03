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
#---------------------------------------------------------------------------

class SearchManager
  activeTabs:{
    animeList:''
    mangaList:''
  },
  animeGrids:[
    "gridWatchingList",
    "gridPlantoWatchList",
    "gridCompletedList",
    "gridOnHoldList",
    "gridDroppedList"
  ],
  animeStatusIndices:[
    1,
    6,
    2,
    3,
    4
  ]
  animeListJsObjects:null
  mangaGrids:[
    "gridMangaReadingList",
    "gridPlantoReadList",
    "gridMangaCompletedList",
    "gridMangaOnHoldList",
    "gridMangaDroppedList"
  ]
  activeRoute:0
  activePath:""
  constructor: ->
    @animeListJsObjects = new Map()
    console.log "constructor"

  updateState:(activeRoute,path) ->
    @activeRoute = activeRoute
    @activePath = path
    console.log "Updating Search Manager Route " + @activeRoute + " Path: " + @activePath
  updateAnimelistState:(index) ->
    @activeTabs.animeList = index

  updateAnimelistStateIndex:(index) ->
    @activeTabs.animeList = @animeGrids[index]

  updateMangalistState:(index) ->
    @activeTabs.mangaList = index

  updateMangalistStateIndex:(index) ->
    @activeTabs.mangaList = @animeGrids[index]

  determineGridName:() ->
    gridName = ''
    if @activeRoute == 1 #animeList
        gridName = @animeGrids[@animeGrids.indexOf(@activeTabs.animeList)]
    if @activeRoute == 2
        gridName = @mangaGrids[@mangaGrids.indexOf(@activeTabs.mangaList)]
    gridName
  startSearching: () ->
    $("#gridSearch").on 'input', () =>
        if @activeRoute == 1 || @activeRoute == 2 #animeList or #mangaList
          gridName = @determineGridName()
          w2ui[gridName].search('title',$("#gridSearch").val())

  refreshGrid: () ->
    if @activeRoute == 1 || @activeRoute == 2 #animeList or mangaList
      gridName = @determineGridName()
      console.log "Refreshing grid: " + gridName
      if @activeRoute == 1
        console.log "Id is " + @animeGrids.indexOf(gridName)
        @animeListJsObjects.get(gridName).refreshDataSource()
        w2ui[gridName].refresh()





search = new SearchManager()
module.exports = search
