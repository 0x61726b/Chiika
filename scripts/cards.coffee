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
_pick         = scriptRequire 'lodash/object/pick'
_find         = scriptRequire 'lodash/collection/find'
_indexOf      = scriptRequire 'lodash/array/indexOf'
moment        = scriptRequire 'moment'
momentTz      = scriptRequire 'moment-timezone'
_when         = scriptRequire 'when'

ANNSource = "http://www.animenewsnetwork.com/newsroom/rss.xml"
ANN       = "http://www.animenewsnetwork.com/"

MALSource = "http://myanimelist.net/rss/news.xml"
MAL       = "http://myanimelist.net"

NyaaSource = "http://www.nyaa.se/?page=rss&cats=1_37&filter=2"
Nyaa       = "http://www.nyaa.se"


module.exports = class CardViews
  name: "cards"
  displayDescription: "Cards"
  isService: false
  isActive: true

  continueWatchingEntryCount: 8

  order: 2

  currentlyWatchingOrder:0
  continueWatchingOrder:1
  upcomingOrder: 2
  statisticsOrder: 3
  newsOrder:4

  # Will be called by Chiika with the API object
  # you can do whatever you want with this object
  # See the documentation for this object's methods,properties etc.
  constructor: (chiika) ->
    @chiika = chiika

  # This method is controls the communication between app and script
  # If you change this method things will break
  #
  on: (event,args...) ->
    try
      @chiika.on @name,event,args...
    catch error
      console.log error
      throw error

  # Creates a 'view'
  # A view is something which will appear at the side menu which you can navigate to
  # See the documentation for view types
  # This is a 'tabView', the most traditional thing in this app
  #
  createNewsCard: () ->
    newsCard =
      name: "cards_news"
      owner: @name
      displayName: 'News'
      displayType: 'CardListItem'
      defaultDataSource: @chiika.settingsManager.appOptions.DefaultRssSource
      noUpdate: true
      CardListItem: {
        redirectTitle: @chiika.settingsManager.appOptions.DefaultRssSource
        displayCategory: true
        enabled: true
        display: 'description'
        alt: 'description'
        cardTitle: 'News'
        order: @newsOrder
      }
    source = @chiika.settingsManager.appOptions.DefaultRssSource

    if source == 'ANN'
      redirect = ANN
    else if source == 'MAL'
      redirect = MAL
    newsCard.CardListItem.redirect = redirect


    @chiika.viewManager.addView newsCard

  createTorrentsCards: ->
    torrentsCard =
      name: "cards_torrents"
      owner: @name
      displayName: 'Nyaa - Latest Releases'
      displayType: 'CardListItem'
      defaultDataSource: 'Nyaa'
      CardListItem: {
        redirect: Nyaa
        redirectTitle: 'Nyaa'
        displayCategory: true
        display: 'title'
        alt: 'description'
        cardTitle: 'Nyaa - Latest Releases'
        order: 1
      }

    @chiika.viewManager.addView torrentsCard

  createCurrentlyWatchingCard: ->
    currentlyWatchingCard =
      name: "cards_currentlyWatching"
      owner: @name
      displayName: 'Currently Watching'
      displayType: 'CardFullEntry'
      noUpdate: true
      dynamic: true
      CardFullEntry: {
        enabled: true
        viewName: 'myanimelist_animelist'
        order: @currentlyWatchingOrder
      }

    @chiika.viewManager.addView currentlyWatchingCard

  createNotRecognizedWatchingCard: ->
    notRecognizedCard =
      name: "cards_notRecognized"
      owner: @name
      displayName: 'Not Recognized'
      displayType: 'CardItemNotRecognized'
      noUpdate: true
      dynamic: true
      CardItemNotRecognized: {
        enabled: true
        viewName: 'myanimelist_animelist'
        order: @currentlyWatchingOrder
      }

    @chiika.viewManager.addView notRecognizedCard

  createStatisticsCard: ->
    statisticsCard =
      name: "cards_statistics"
      owner: @name
      displayName: 'Statistics'
      displayType: 'CardStatistics'
      CardStatistics: {
        enabled: true
        order: @statisticsOrder
        view: 'myanimelist_animelist'
      }

    @chiika.viewManager.addView statisticsCard

  createUpcomingAnimeCard: ->
    upcomingCard =
      name: "cards_upcoming"
      owner: @name
      displayName: 'Upcoming'
      displayType: 'CardListItemUpcoming'
      noUpdate: true
      CardListItemUpcoming: {
        enabled: true
        order:@upcomingOrder
      }

    @chiika.viewManager.addView upcomingCard

  createContinueWatchingCard: ->
    continueWatchingCard =
      name: "cards_continueWatching"
      owner: @name
      displayName: 'Continue Watching'
      displayType: 'CardItemContinueWatching'
      noUpdate: true
      CardItemContinueWatching: {
        enabled: true
        order:@continueWatchingOrder
        view: 'myanimelist_animelist'
      }

    @chiika.viewManager.addView continueWatchingCard


  getRssFeed: (url,callback) ->
    onGetFeed = (error,response,body) =>
      if error?
        callback( { success: false } )
        throw error

      if response.statusCode != 200
        callback( { success: false } )
        return

      @chiika.parser.parseXml(body)
                    .then (result) =>
                      callback( { success: true, feed: result } )

    @chiika.makeGetRequest url,null, onGetFeed

  getFeed: (feedSource,callback) ->
    url = ""
    if feedSource == 'ANN'
      url = ANNSource
    else if feedSource == 'MAL'
      url = MALSource
    else if feedSource == 'Nyaa'
      url = NyaaSource

    @getRssFeed url, (result) =>
      if result.success
        feed  = result.feed
        rssProvider = feed.rss.channel.title
        desc  = feed.rss.channel.description


        items = []
        _forEach feed.rss.channel.item, (item) =>
          guid = item.guid
          link = item.link
          title = item.title
          description = item.description
          category = item.category

          items.push { title: title, link: link, description: description, category: category }
        callback({ success: result.success, feed:{ provider: feedSource, items: items }})



  # After the constructor run() method will be called immediately after.
  # Use this method to do what you will
  #
  run: (chiika) ->
    #This is the first event called here to let user do some initializing
    @on 'initialize',=>


    @on 'post-init', (init) =>
      news = @chiika.viewManager.getViewByName('cards_news')
      upcoming = @chiika.viewManager.getViewByName('cards_upcoming')
      statistics = @chiika.viewManager.getViewByName('cards_statistics')

      async = []


      waitForUpcoming = _when.defer()
      async.push waitForUpcoming.promise

      _when.all(async).then(init.defer.resolve)



      if news? && news.getData().length == 0
        @chiika.requestViewUpdate 'cards_news',@name, (response) =>
          @chiika.requestViewDataUpdate('cards','cards_news')

      if upcoming?
        @chiika.requestViewUpdate 'cards_upcoming',@name, (response) =>
          waitForUpcoming.resolve()
      else
        waitForUpcoming.resolve()
      # @chiika.requestViewUpdate 'cards_randomAnime',@name, (response) =>
      #   @randomAnimeLayout = response.layout
      #   init.return()

    # This method will be called if there are no UI elements in the database
    # or the user wants to refresh the views
    # @todo Implement reset
    @on 'reconstruct-ui', (update) =>
      @chiika.logger.script("[yellow](#{@name}) reconstruct-ui")

      @createNewsCard()
      # @createUpcomingAnimeCard()
      # @createStatisticsCard()
      # @createContinueWatchingCard()

      detectionCache =
        name: "anime_detect_cache"
        owner: @name
        displayName: 'subview'
        displayType: 'subview'
        noUpdate: true
        subview:{}

      @chiika.viewManager.addView detectionCache

    @on 'create-card', (card) =>
      if card.name == 'cards_currentlyWatching'
        @createCurrentlyWatchingCard()

      else if card.name == 'cards_notRecognized'
        @createNotRecognizedWatchingCard()

    @on 'media-action', (action) =>
      @chiika.logger.script("[yellow](#{@name}) media-action #{action.action}")

      params = action.params
      actionName = action.action

      if actionName == 'play-next-episode'
        detectCache = @chiika.viewManager.getViewByName('anime_detect_cache')

        findEpisode = =>
          episodeFound = false
          if detectCache?
            cache = detectCache.getData()

            findEntry = _find cache, (o) -> o.id == params.id

            if findEntry?
              knownPaths = findEntry.knownPaths
              files = findEntry.files
              _forEach files, (file) =>
                if parseInt(file.episode) == parseInt(params.nextEpisode)
                  @chiika.openExternal(file.file)
                  episodeFound = true
                  return false
          episodeFound

        findFolder = =>
          if detectCache?
            cache = detectCache.getData()

            findEntry = _find cache, (o) -> o.id == params.id

            if findEntry?
              return findEntry.knownPaths
            else
              return null
          return null

        folders = findFolder()
        if !folders?
          @chiika.logger.info("No known folders for #{params.id}")
          action.return({ state: 'not-found'})
        else
          if !findEpisode()
            # Scan folder
            onReturn = (results) =>
              console.log "Scanazad #{folders[0]}"

              # Try again
              if !findEpisode()
                action.return( { state: 'episode-not-found'})

            @chiika.emit 'scan-folder', { id: params.id, folder: folders[0], return: onReturn }

      else if actionName == 'open-folder'
        @chiika.logger.script("[yellow](#{@name}) open-folder")

        animeTitle = params.title

        @chiika.emit 'open-folder', { calling: 'media', title: animeTitle, return: action.return }

        # if detectCache?
        #   cache = detectCache.getData()
        #
        #   findEntry = _find cache, (o) -> o.title == animeTitle
        #
        #   if findEntry?
        #     knownPaths = findEntry.knownPaths
        #     @chiika.openExternal(knownPaths[0])
        #
        #     @chiika.logger.info("Opening folder #{knownPaths}")
        #   else
        #     @chiika.logger.info("No known folders for #{params.id}")
        #     action.return({ state: 'not-found'})



    @on 'get-view-data', (args) =>
      @chiika.logger.script("[yellow](#{@name}) get-view-data #{args.view.name}")
      if args.view.name == 'cards_news'
        dataSource = {}
        source = @chiika.settingsManager.appOptions.DefaultRssSource
        redirect = "http://www.chiika.moe"
        _forEach args.data, (data) =>
          if data.provider == source
            if source == 'ANN'
              redirect = ANN
            else if source == 'MAL'
              redirect = MAL

            dataSource = data
        args.return({ data: dataSource, CardListItem: { redirect: redirect, redirectTitle: source } })


      else if args.view.name == 'cards_continueWatching'
        historyAnime = @chiika.viewManager.getViewByName('myanimelist_animelist_history')
        animeView = @chiika.viewManager.getViewByName('myanimelist_animelist')
        animeExtraView = @chiika.viewManager.getViewByName('myanimelist_animeextra')

        if historyAnime?
          animeHistory = historyAnime.getData()
          animelist    = animeView.getData()


          cntWatchingLayouts = []
          _forEach animeHistory, (history) =>
            id = history.id
            ep     = history.episode

            animeEntry = _find animelist, (o) -> o.id == id

            if animeEntry?
              onReturn = (anime) =>
                exists = _find cntWatchingLayouts, (p) -> p.id == id
                index  = _indexOf cntWatchingLayouts,exists

                if parseInt(anime.watchedEpisodes) == parseInt(anime.totalEpisodes)
                  return
                if exists?
                  if history.updated > exists.time
                    exists = { id: id,time: history.updated,layout: anime }
                    cntWatchingLayouts.splice(index,1,exists)
                else
                  cntWatchingLayouts.push { id: id,time: history.updated,layout: anime }

              @chiika.emit 'get-anime-values', { calling: 'myanimelist',entry: animeEntry,return: onReturn }

          cntWatchingLayouts.sort (a,b) =>
            if a.time > b.time
              return -1
            else
              return 1
            return 0

          args.return(cntWatchingLayouts)


      else if args.view.name == 'cards_currentlyWatching'
        dataSource = args.view.dataSource
        if dataSource?
          cardTitle = "#{dataSource.parse.AnimeTitle} - Episode: #{dataSource.parse.EpisodeNumber}"
          args.return({ title: cardTitle, layout: dataSource.layout })

      else if args.view.name == 'cards_statistics'
        historyAnime = @chiika.viewManager.getViewByName('myanimelist_animelist_history')
        historyManga = @chiika.viewManager.getViewByName('myanimelist_mangalist_history')

        episodes = 0
        chapters = 0
        volumes = 0


        if historyAnime?
          animeHistory = historyAnime.getData()

          thisweek = moment().week()

          _forEach animeHistory, (history) ->
            date = moment(history.updated)

            if date.isValid()
              week = date.week()

              if thisweek == week
                episodes++

        if historyManga?
          mangaHistory = historyManga.getData()

          _forEach mangaHistory, (history) ->
            date = moment(history.updated)

            if date.isValid()
              week = date.week()

              if thisweek == week && history.chapters?
                chapters++

              if thisweek == week && history.volumes?
                volumes++

        dataSource = [
          { title: 'Episodes Watched', count: episodes },
          { title: 'Chapters Read', count: chapters },
          { title: 'Volumes Read', count: volumes }
        ]
        args.return(dataSource)

      else if args.view.name == 'cards_upcoming'
        upcoming = @chiika.viewManager.getViewByName('cards_upcoming')
        animelistView = @chiika.viewManager.getViewByName('myanimelist_animelist')

        if upcoming? && upcoming.getData().length > 0
          animelist = animelistView.getData()
          upcomingData = upcoming.getData()

          watchingListData = []
          colors = ['red','green','indigo','blue','grey']
          colorCounter = 0
          _forEach upcomingData, (item) =>
            weeklyAirdate = item.weeklyAirdate
            id        = item.id
            airdate       = item.airdate
            simul         = item.simul
            simulDelay    = item.simuldelay

            findInAnimelist = _find animelist, (o) -> o.id == id

            if findInAnimelist? && findInAnimelist.animeUserStatus == "1"
              watchingListData.push { color: colors[colorCounter],title: item.title, weeklyAirdate: weeklyAirdate,day: weeklyAirdate.rd_weekday, time: weeklyAirdate.rd_time}
              colorCounter++

            if colorCounter > 4
              colorCounter = 0

          watchingListData.sort (a,b) =>
            if b.weeklyAirdate.weekday_sort > a.weeklyAirdate.weekday_sort
              return -1
            else
              return 1
            return 0




          args.return(watchingListData)

      else if args.view.name == 'cards_notRecognized'
        dataSource = args.view.dataSource
        if dataSource?
          cardTitle = "Not recognized #{dataSource.parse.AnimeTitle} - Episode: #{dataSource.parse.EpisodeNumber}"

          args.return({ title: cardTitle, values: dataSource.values })

    @on 'view-update', (update) =>
      @chiika.logger.script("[yellow](#{@name}) view-update - #{update.view.name}")


      if update.view.name == 'cards_upcoming'
        calendarView = @chiika.viewManager.getViewByName('calendar_senpai')
        if calendarView?
          calendarData = calendarView.getData()
          if calendarData.length > 0
            userTimezone = momentTz.tz(momentTz.tz.guess())
            utcOffset = momentTz.parseZone(userTimezone).utcOffset() * 60# In seconds

            calendarItems = calendarData[0].senpai.items

            commonCalendarItems = []
            _forEach calendarItems, (item) ->
              airdates = item.airdates
              userTimezoneAirdate = airdates[utcOffset]

              if userTimezoneAirdate?
                cItem =
                  weeklyAirdate: userTimezoneAirdate
                  title: item.name
                  id: item.MALID
                  ann_id: item.ANNID
                  airdate: item.airdate
                  simul: item.simulcast
                  simdelay: item.simulcast_delay

                commonCalendarItems.push cItem
            update.view.clear().then =>
              update.view.setDataArray(commonCalendarItems).then (args) =>
                @chiika.requestViewDataUpdate('cards','cards_upcoming')
                @chiika.requestUIDataUpdate('cards_upcoming')

                update.return()

      else if update.view.name == 'cards_news'
        feedSource = update.params.source
        url        = ""

        if !feedSource?
          feedSource = @chiika.settingsManager.appOptions.DefaultRssSource

        @getFeed feedSource,(feed) =>
          update.view.setData(feed.feed, 'provider').then (args) =>
            @chiika.requestViewDataUpdate('cards','cards_news')
            update.return()


      else if update.view.name == 'cards_torrents'
        feedSource = "Nyaa"
        @getFeed feedSource,(feed) =>
          update.view.setData(feed.feed, 'provider').then (args) =>
            update.return()


      else if update.view.name == 'cards_currentlyWatching'

        onAnimeDetailsLayout = (response) =>
          update.view.dataSource = { parse: update.params.parse, layout: response.layout }
          @chiika.requestViewDataUpdate('cards','cards_currentlyWatching')
          @chiika.requestUIDataUpdate('cards_currentlyWatching')

        @chiika.emit 'details-layout', { viewName: 'myanimelist_animelist', id: update.params.entry.id, return: onAnimeDetailsLayout }

      else if update.view.name == 'cards_notRecognized'
        recognizeResult = update.params.result
        parseResult     = update.params.parse

        animeValues = []
        _forEach recognizeResult.suggestions, (suggestion) =>
          onReturn = (result) =>
            animeValues.push result
          @chiika.emit 'get-anime-values', { calling: 'myanimelist',entry: suggestion.entry,return: onReturn }


        update.view.dataSource = { parse: parseResult, values: animeValues }
        @chiika.requestViewDataUpdate('cards','cards_notRecognized')
        @chiika.requestUIDataUpdate('cards_notRecognized')


      else if update.view.name == 'cards_statistics'
        update.return()

  requestViewRefresh: ->
    throw "Nope"
