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
AnitomyNode   = require "#{mainProcessHome}/../../vendor/anitomy-node/AnitomyNode"

NyaaSource = "http://www.nyaa.se/?page=rss&cats=1_37&filter=2"

module.exports = class Torrents
  name: "torrent"
  displayDescription: "Torrents"
  isService: false
  isActive: true
  order: 99

  feedView: 'torrents_feeds'

  # Will be called by Chiika with the API object
  # you can do whatever you want with this object
  # See the documentation for this object's methods,properties etc.
  constructor: (chiika) ->
    @chiika = chiika

    @recognition = new Recognition()
    @anitomy = new AnitomyNode.Root()

  libraryDataByOwner: ->
    services = @chiika.getServices()

    libraryDataByOwner = []

    views = []
    _forEach services, (service) =>
      views.push { viewName: service.animeView, owner: service.name }

    _forEach views, (viewOwnerMap) =>
      view = @chiika.viewManager.getViewByName(viewOwnerMap.viewName)

      if view?
        viewData = view.getData()

        if viewData.length > 0
          libraryDataByOwner.push { owner: viewOwnerMap.owner, library: viewData }

    libraryDataByOwner

  # This method is controls the communication between app and script
  # If you change this method things will break
  #
  on: (event,args...) ->
    try
      @chiika.on @name,event,args...
    catch error
      console.log error
      throw error

  #
  #
  #
  getRssFeed: (url,callback) ->
    onGetFeed = (error,response,body) =>
      if error?
        callback( { success: false } )
        throw error

      if response.statusCode != 200
        callback( { success: false } )
        return

      callback( { success: true, data: body } )

    @chiika.makeGetRequest url,null, onGetFeed

  updateFeed: (name,callback) ->
    feedSources = @chiika.settingsManager.getOption('FeedSources')

    _forEach feedSources, (feed) =>
      if feed.name == name
        feedUrl = feed.feed
        feedType = feed.type

        if feedType == 'xml'
          @getRssFeed feedUrl, (result) =>
            if result.success
              @chiika.parser.parseXml(result.data)
                            .then (result) =>
                              view = @chiika.viewManager.getViewByName(@feedView)

                              if view?
                                rssFeed = { name: name, feed: result.rss.channel.item }
                                view.setData(rssFeed,'name').then () =>
                                  callback?()

  applyFilters: (feed) ->
    filters = @chiika.settingsManager.getOption('Filters')
    conditions = @chiika.settingsManager.getOption('FilterConditions')

    filtered = []

    _forEach feed, (feed) =>
      title = feed.title
      category = feed.category
      link = feed.link
      guid = feed.guid
      pubDate = feed.pubDate
      desc = feed.description

      # Get video size
      indexOfMib = desc.indexOf 'MiB'
      indexOfSizeStart = desc.indexOf 'download(s) -'

      size = desc.substring indexOfSizeStart + 13, indexOfMib

      parseTitle = @anitomy.Parse title

      filterResult = @applyFilter(parseTitle,filters[0])

      filteredItem =
        filterResult: filterResult
        animeTitle: parseTitle.AnimeTitle
        category: category
        link: link
        desc: desc
        episode: parseTitle.EpisodeNumber
        video: parseTitle.VideoTerm
        group: parseTitle.ReleaseGroup
        size: size
      filtered.push filteredItem


    filtered



  applyFilter: (anitomyParse,filter) ->
    conditions = @chiika.settingsManager.getOption('FilterConditions')

    filterConditions = filter.conditions
    matchType        = filter.matchType
    matchAction      = filter.matchAction

    conditionOutputs = []

    _forEach filterConditions, (condition) =>
      conditionName = condition.name
      operator      = condition.operator
      value         = condition.value

      # Find in condition def list
      condDef = _find conditions, (o) -> o.name == conditionName

      if condDef?
        condType = condDef.type

        if condType == 'anime-user-status'
          result = @applyAnimeUserStatusFilter(anitomyParse,operator,value)

          if result
            conditionOutputs.push { condition: condition, result: result }

          console.log "#{condType} #{anitomyParse.AnimeTitle} #{operator} #{value} #{result}"



    pass = false
    if matchType == 'all'
      # If one condition fails, fail everything
      _forEach conditionOutputs, (co) =>
        if !co.result
          pass = false
          return false
    else if matchType == 'any'
      # If one condition passes, it passed
      _forEach conditionOutputs, (co) =>
        if co.result
          pass = true
          return false

    filterResult = { pass: pass, action: matchAction }
    return filterResult



  applyAnimeUserStatusFilter: (anitomyParse,operator,value) ->
    animeTitle = anitomyParse.AnimeTitle

    keep = false

    _forEach @libraryData,(lib) =>
      libraryData = lib.library
      owner       = lib.owner

      # Find title in the list
      findInList = _find libraryData,(o) => @recognition.clear(o.animeTitle) == @recognition.clear(animeTitle)

      if findInList?
        # Get Anime values
        onAnimeValues = (values) =>
          userStatusText = values.userStatusText

          if operator == 'is'
            if userStatusText == value
              keep = true
              return keep
            else
              return keep
        @chiika.emit 'get-anime-values', { calling: owner, entry: findInList, return: onAnimeValues}

    return keep

  run: () ->
    @on 'initialize', =>
      @libraryData = @libraryDataByOwner()

    @on 'post-init', (init) =>
      @chiika.logger.script("[yellow](#{@name}) post-init")

      init.defer.resolve()
      # _forEach feedSources, (feed) =>
      #   @updateFeed(feed.name, -> init.defer.resolve())
    @on 'reconstruct-ui', =>
      @chiika.logger.script("[yellow](#{@name}) reconstruct-ui")
      feedCache =
        name: @feedView
        owner: @name
        displayName: 'subview'
        displayType: 'subview'
        subview:{}

      @chiika.viewManager.addView feedCache

    @on 'view-update', (update) =>
      @chiika.logger.script("[yellow](#{@name}) view-update #{update.view.name}")
      viewName = update.view.name
      feedName = update.params.feedName
      feedSources = @chiika.settingsManager.getOption('FeedSources')

      if viewName == @feedView
        _forEach feedSources, (feed) =>
          if feed.name == feedName
            @updateFeed(feed.name,update.return)

    @on 'get-view-data', (args) =>
      viewName = args.view.name
      @chiika.logger.script("[yellow](#{@name}) get-view-data #{args.view.name}")

      if viewName == @feedView
        # Filter
        feedView = @chiika.viewManager.getViewByName(@feedView)

        if feedView?
          feedData = feedView.getData()

          if feedData.length > 0

            defaultFeedName = "Nyaa1"
            defaultFeed = _find feedData, (o) -> o.name == defaultFeedName

            args.return @applyFilters(defaultFeed.feed)
