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
_when         = scriptRequire 'when'
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
    try
      @chiika.on @name,event,args...
    catch error
      console.log error
      throw error

  animeSearchResultLayout: (entry,listEntry) ->
    layout =
      id: entry.id
      image: entry.animeImage
      averageScore: entry.animeScoreAverage
      entryType: entry.animeType
      type:'Anime'
      episodes: "#{entry.animeTotalEpisodes} EPs"
      title: entry.animeTitle
      airing: entry.animeSeriesStatus
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
      layout.status = "Not In List"
    return layout

  mangaSearchResultLayout: (entry,listEntry) ->
    layout =
      id: entry.id
      image: entry.mangaImage
      averageScore: entry.mangaScoreAverage
      entryType: entry.mangaType
      type:'Manga'
      episodes: "15"
      title: entry.mangaTitle
      airing: entry.mangaStatus
    if listEntry?
      userStatusText = ""
      if listEntry.mangaUserStatus == "1"
        userStatusText = "Reading"
      else if listEntry.mangaUserStatus == "2"
        userStatusText = "Completed"
      else if listEntry.mangaUserStatus == "3"
        userStatusText = "On Hold"
      else if listEntry.mangaUserStatus == "4"
        userStatusText = "Dropped"
      else if listEntry.mangaUserStatus == "6"
        userStatusText = "Plan to Read"
      layout.status = userStatusText
    else
      layout.status = "Not In List"
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

      services = @chiika.getServices()

      if searchType == 'anime-manga'
        viewsToSearch = []
        _forEach searchSource, (service) =>
          if service.useInSearch
            viewsToSearch.push x for x in service.views

        sourceViewAnime = @chiika.viewManager.getViewByName(viewsToSearch[0])
        sourceViewManga = @chiika.viewManager.getViewByName(viewsToSearch[1])

        if sourceViewAnime? && sourceViewManga?
          sourceDataAnime = sourceViewAnime.getData()
          sourceDataManga = sourceViewManga.getData()

          combineResults = []

          searchAnime = (resolve) =>
            onAnimeSearch = (response) =>
              results = []
              _forEach response, (entry) =>
                findInAnimelist = _find sourceDataAnime,(o) -> o.id == entry.id
                layout = @animeSearchResultLayout(entry,findInAnimelist)
                layout.sourceView = viewsToSearch[0]
                results.push layout

              resolve(results)
            @chiika.emit 'make-search', { calling: sourceViewAnime.owner, title: searchString, type: 'anime',return: onAnimeSearch }

          searchManga = (resolve) =>
            onMangaSearch = (response) =>
              results = []
              _forEach response, (entry) =>
                findInMangalist = _find sourceDataManga,(o) -> o.id == entry.id
                layout = @mangaSearchResultLayout(entry,findInMangalist)
                layout.sourceView = viewsToSearch[1]
                results.push layout

              resolve(results)
            @chiika.emit 'make-search', { calling: sourceViewManga.owner, title: searchString, type: 'manga',return: onMangaSearch }

          doSearchAnime = _when.promise(searchAnime)
          doSearchManga = _when.promise(searchManga)

          doSearch = _when.join(doSearchAnime,doSearchManga).then (values) =>
            combineResults.push x for x in values[0]
            combineResults.push x for x in values[1]
            params.return(combineResults)

      else if searchType == 'anime'
        viewsToSearch = []
        _forEach services, (service) =>
          if service.useInSearch && service.name == searchSource
            viewsToSearch.push x for x in service.views

        sourceViewAnime = @chiika.viewManager.getViewByName(viewsToSearch[0])

        searchAnime = (resolve) =>
          onAnimeSearch = (response) =>
            results = []
            sourceDataAnime = []

            success = response.success
            if success
              if sourceViewAnime?
                sourceDataAnime = sourceViewAnime.getData()
              _forEach response.results, (entry) =>
                if sourceDataAnime.length > 0
                  findInAnimelist = _find sourceDataAnime,(o) -> o.id == entry.id
                layout = @animeSearchResultLayout(entry,findInAnimelist)
                layout.sourceView = viewsToSearch[0]
                results.push layout
              resolve({ success: success, results: results })
            else
              resolve({ success: success, error: response.error })

          @chiika.emit 'make-search', { calling: searchSource, title: searchString, type: 'anime',return: onAnimeSearch }

        _when.promise(searchAnime).then (results) =>
          if results.success
            params.return({ success: results.success, results: results.results })
          else
            errorMessage = ""
            errorCode = results.error
            if errorCode == "no-user"
              errorMessage = "This service doesn't allow searching without a user.Please login before trying to search."

            if errorCode == "request"
              errorMessage = "Search request has failed. Either there is no connection or the service is down."
            console.log results

            params.return({ success: results.success, error: errorMessage})



      else if searchType == 'manga'
        viewsToSearch = []
        _forEach services, (service) =>
          if service.useInSearch && service.name == searchSource
            viewsToSearch.push x for x in service.views

        sourceView = @chiika.viewManager.getViewByName(viewsToSearch[1])

        searchManga = (resolve) =>
          onAnimeSearch = (response) =>
            results = []
            sourceData = []

            success = response.success
            if success
              if sourceView?
                sourceData = sourceView.getData()
              _forEach response.results, (entry) =>
                if sourceData.length > 0
                  findInList = _find sourceData,(o) -> o.id == entry.id
                layout = @mangaSearchResultLayout(entry,findInList)
                layout.sourceView = viewsToSearch[1]
                results.push layout
              resolve({ success: success, results: results })
            else
              resolve({ success: success, error: response.error })

          @chiika.emit 'make-search', { calling: searchSource, title: searchString, type: 'manga',return: onAnimeSearch }

        _when.promise(searchManga).then (results) =>
          if results.success
            params.return({ success: results.success, results: results.results })
          else
            errorMessage = ""
            errorCode = results.error
            if errorCode == "no-user"
              errorMessage = "This service doesn't allow searching without a user.Please login before trying to search."

            if errorCode == "request"
              errorMessage = "Search request has failed. Either there is no connection or the service is down."
            console.log results

            params.return({ success: results.success, error: errorMessage})
