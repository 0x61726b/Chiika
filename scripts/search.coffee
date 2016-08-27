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

path          = require 'path'
fs            = require 'fs'


_forEach      = scriptRequire 'lodash.forEach'
_find         = scriptRequire 'lodash/collection/find'
_indexOf      = scriptRequire 'lodash/array/indexOf'
_filter       = scriptRequire 'lodash/collection/filter'
moment        = scriptRequire 'moment'
string        = scriptRequire 'string'
Recognition   = require "#{mainProcessHome}/media-recognition"

module.exports = class Search
  name: "search"
  displayDescription: "Search"
  isService: false
  isActive: true
  order: 4

  # Will be called by Chiika with the API object
  # you can do whatever you want with this object
  # See the documentation for this object's methods,properties etc.
  constructor: (chiika) ->
    @chiika = chiika
    @recognition = new Recognition()

  # This method is controls the communication between app and script
  # If you change this method things will break
  #
  on: (event,args...) ->
    @chiika.on @name,event,args...

  searchResultLayout: (entry,listEntry) ->
    layout =
      id: entry.mal_id
      image: entry.animeImage
      averageScore: entry.animeScoreAverage
      type: entry.animeType
      episodes: "#{entry.animeTotalEpisodes} EPs"
      title: entry.animeTitle
      airing: entry.animeStatus
    if listEntry?
      userStatusText = ""
      if listEntry.animeUserStatus == "1"
        userStatusText = "Watching"
      else if listEntry.animeUserStatus == "2"
        userStatusText = "Completed"
      else if listEntry.animeUserStatus == "3"
        userStatusText = "On Hold"
      else if listEntry.animeUserStatus == "4"
        userStatusText = "Dropped"
      else if listEntry.animeUserStatus == "6"
        userStatusText = "Plan to Watch"
      layout.status = userStatusText
    else
      layout.status = "Add to List"
    return layout



  # After the constructor run() method will be called immediately after.
  # Use this method to do what you will
  #
  run: (chiika) ->
    #This is the first event called here to let user do some initializing
    @on 'initialize',=>


    @on 'post-init', (init) =>
      init.defer.resolve()

    @on 'search', (params) =>
      @chiika.logger.script("[yellow](#{@name}) search")
      console.log params

      searchString = @recognition.clear(params.searchString)
      searchType   = params.searchType
      searchSource = params.searchSource
      searchMode   = params.searchMode

      sourceView = @chiika.viewManager.getViewByName(searchSource)

      sourceData = []
      if sourceView?
        sourceData = sourceView.getData()

      if searchMode == 'list-remote'
        onSearch = (response) =>
          results = []
          _forEach response, (entry) =>
            findInAnimelist = _find sourceData,(o) -> o.mal_id == entry.mal_id
            results.push @searchResultLayout(entry,findInAnimelist)
          params.return(results)
        # Create search request
        @chiika.emit 'make-search', { calling: sourceView.owner, title: searchString, return: onSearch }
      else if searchMode == 'list'
        if sourceData.length > 0
          findByTitle = _filter sourceData, (o) => string(@recognition.clear(o.animeTitle)).contains(searchString)

          results = []
          _forEach findByTitle, (entry) =>
            results.push @searchResultLayout(entry)
          params.return(results)
