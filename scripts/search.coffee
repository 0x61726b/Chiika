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
    @chiika.on @name,event,args...

  animeSearchResultLayout: (entry,listEntry) ->
    layout =
      id: entry.mal_id
      image: entry.animeImage
      averageScore: entry.animeScoreAverage
      entryType: entry.animeType
      type:'Anime'
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
      layout.status = "Not In List"
    return layout

  mangaSearchResultLayout: (entry,listEntry) ->
    layout =
      id: entry.mal_id
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

      if searchSource.split(',').length > 0
        searchSource = searchSource.split(',')


      if searchMode == 'list-remote'
        if searchType == 'anime-manga'
          sourceViewAnime = @chiika.viewManager.getViewByName(searchSource[0])
          sourceViewManga = @chiika.viewManager.getViewByName(searchSource[1])

          sourceDataAnime = []
          if sourceViewAnime?
            sourceDataAnime = sourceViewAnime.getData()

          sourceDataManga = []
          if sourceViewManga?
            sourceDataManga = sourceViewManga.getData()


          waitForAnime = _when.defer()
          waitForManga = _when.defer()

          combineResults = []

          async = []
          async.push waitForManga.promise
          async.push waitForAnime.promise

          _when.all(async).then =>
            params.return(combineResults)

          onAnimeSearch = (response) =>
            results = []
            _forEach response, (entry) =>
              findInAnimelist = _find sourceDataAnime,(o) -> o.mal_id == entry.mal_id
              layout = @animeSearchResultLayout(entry,findInAnimelist)
              layout.sourceView = searchSource[0]
              results.push layout

            combineResults.push x for x in results
            waitForAnime.resolve(results)


          onMangaSearch = (response) =>
            results = []
            _forEach response, (entry) =>
              findInMangalist = _find sourceDataManga,(o) -> o.mal_id == entry.mal_id
              layout = @mangaSearchResultLayout(entry,findInMangalist)
              layout.sourceView = searchSource[1]
              results.push layout

            combineResults.push x for x in results
            waitForManga.resolve(results)
          # Create search request
          @chiika.emit 'make-search', { calling: sourceViewAnime.owner, title: searchString, type: 'anime',return: onAnimeSearch }
          @chiika.emit 'make-search', { calling: sourceViewManga.owner, title: searchString, type: 'manga',return: onMangaSearch }


        else if searchType == 'anime'
          sourceViewAnime = @chiika.viewManager.getViewByName(searchSource[0])
          sourceDataAnime = []
          if sourceViewAnime?
            sourceDataAnime = sourceViewAnime.getData()

            onAnimeSearch = (response) =>
              results = []
              _forEach response, (entry) =>
                findInAnimelist = _find sourceDataAnime,(o) -> o.mal_id == entry.mal_id
                layout = @animeSearchResultLayout(entry,findInAnimelist)
                layout.sourceView = searchSource[0]
                results.push layout
              params.return(results)
            @chiika.emit 'make-search', { calling: sourceViewAnime.owner, title: searchString, type: 'anime',return: onAnimeSearch }

        else if searchType == 'manga'
          sourceView = @chiika.viewManager.getViewByName(searchSource[1])
          sourceData = []
          if sourceView?
            sourceData = sourceView.getData()

            onSearch = (response) =>
              results = []
              _forEach response, (entry) =>
                findInMangalist = _find sourceData,(o) -> o.mal_id == entry.mal_id
                layout = @mangaSearchResultLayout(entry,findInMangalist)
                layout.sourceView = searchSource[0]
                results.push layout
              params.return(results)
            @chiika.emit 'make-search', { calling: sourceView.owner, title: searchString, type: 'manga',return: onSearch }

      else if searchMode == 'list'
        sourceViewAnime = @chiika.viewManager.getViewByName(searchSource[0])
        sourceViewManga = @chiika.viewManager.getViewByName(searchSource[1])

        sourceDataAnime = []
        if sourceViewAnime?
          sourceDataAnime = sourceViewAnime.getData()

        sourceDataManga = []
        if sourceViewManga?
          sourceDataManga = sourceViewManga.getData()

        combine = []
        animeResults = []
        mangaResults = []
        if sourceDataManga.length > 0
          findByTitle = _filter sourceDataManga, (o) => string(@recognition.clear(o.mangaTitle)).contains(searchString)

          _forEach findByTitle, (entry) =>
            combine.push @mangaSearchResultLayout(entry,entry)
            mangaResults.push @mangaSearchResultLayout(entry,entry)

        if sourceDataAnime.length > 0
          findByTitle = _filter sourceDataAnime, (o) => string(@recognition.clear(o.animeTitle)).contains(searchString)

          _forEach findByTitle, (entry) =>
            combine.push @animeSearchResultLayout(entry,entry)
            animeResults.push @animeSearchResultLayout(entry,entry)

        if searchType == 'anime-manga'
          params.return(combine)

        if searchType == 'anime'
          params.return(animeResults)
        if searchType == 'manga'
          params.return(mangaResults)
