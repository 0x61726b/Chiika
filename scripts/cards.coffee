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
moment        = scriptRequire 'moment'

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

  # Will be called by Chiika with the API object
  # you can do whatever you want with this object
  # See the documentation for this object's methods,properties etc.
  constructor: (chiika) ->
    @chiika = chiika

  # This method is controls the communication between app and script
  # If you change this method things will break
  #
  on: (event,args...) ->
    @chiika.on @name,event,args...

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
      CardListItem: {
        redirectTitle: @chiika.settingsManager.appOptions.DefaultRssSource
        displayCategory: true
        display: 'description'
        alt: 'description'
        cardTitle: 'News'
        order: 1
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
        viewName: 'myanimelist_animelist'
        order: 0
      }

    @chiika.viewManager.addView currentlyWatchingCard

  createStatisticsCard: ->
    statisticsCard =
      name: "cards_statistics"
      owner: @name
      displayName: 'Statistics'
      displayType: 'CardStatistics'
      noUpdate: true
      CardStatistics: {
        order: 1
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
        order:2
      }

    @chiika.viewManager.addView upcomingCard


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
      news = @chiika.viewManager.getViewByName('cards_news')
      upcoming = @chiika.viewManager.getViewByName('cards_upcoming')
      statistics = @chiika.viewManager.getViewByName('cards_statistics')

      if news? && news.getData().length == 0
        @chiika.requestViewUpdate('cards_news',@name)

      if upcoming?
        @chiika.requestViewUpdate('cards_upcoming',@name)

    @on 'post-init', (init) =>
      init.return()
      # @chiika.requestViewUpdate 'cards_randomAnime',@name, (response) =>
      #   @randomAnimeLayout = response.layout
      #   init.return()

    # This method will be called if there are no UI elements in the database
    # or the user wants to refresh the views
    # @todo Implement reset
    @on 'reconstruct-ui', (update) =>
      @chiika.logger.script("[yellow](#{@name}) reconstruct-ui")

      @createNewsCard()
      @createUpcomingAnimeCard()
      @createStatisticsCard()

    @on 'get-view-data', (args) =>
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


      else if args.view.name == 'cards_currentlyWatching'
        if @currentlyWatchingLayout?
          args.return({ data: @currentlyWatchingLayout, CardFullEntry: { dataSourceName: 'cards_currentlyWatching' } })

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

        if upcoming? && upcoming.getData().length > 0
          args.return(upcoming.getData())

    @on 'view-update', (update) =>
      if update.view.name == 'cards_upcoming'
        # Calculate upcoming anime
        dataSource = [
          { id:'123', color:'indigo',time: '20:00', day:'TUE', title: 'NEW GAME'},
          { id:'128',color:'indigo',time: '20:00', day:'TUE', title: 'NEW GAME'},
          { id:'127',color:'indigo',time: '20:00', day:'TUE', title: 'NEW GAME'},
          { id:'126',color:'indigo',time: '20:00', day:'TUE', title: 'NEW GAME'},
          { id:'12',color:'indigo',time: '20:00', day:'TUE', title: 'NEW GAME'},
          { id:'124',color:'indigo',time: '20:00', day:'TUE', title: 'NEW GAME'}
        ]

        update.view.setDataArray(dataSource).then (args) =>
          update.return()

      else if update.view.name == 'cards_news'
        feedSource = update.params.source
        url        = ""

        if !feedSource?
          feedSource = @chiika.settingsManager.appOptions.DefaultRssSource

        @getFeed feedSource,(feed) =>
          update.view.setData(feed.feed, 'provider').then (args) =>
            update.return()
      else if update.view.name == 'cards_torrents'
        feedSource = "Nyaa"
        @getFeed feedSource,(feed) =>
          update.view.setData(feed.feed, 'provider').then (args) =>
            update.return()
      else if update.view.name == 'cards_currentlyWatching'
        animelistView   = @chiika.viewManager.getViewByName('myanimelist_animelist')

        if animelistView?
          listLength = animelistView.getData().length

          if listLength > 0
            random = Math.floor(Math.random() * listLength)
            @randomAnime = animelistView.getData()[random]
            @chiika.logger.info("Selected random anime #{@randomAnime.mal_id}")

            onAnimeDetailsLayout = (response) =>
              update.return(response)
            @chiika.emit 'details-layout', { viewName: 'myanimelist_animelist', id: @randomAnime.mal_id, return: onAnimeDetailsLayout }

      else if update.view.name == 'cards_statistics'
        update.return()

    @on 'system-event', (event) =>
      if event.name == 'shortcut-pressed'
        if event.params.action == 'test'
          @createCurrentlyWatchingCard()
          @chiika.requestViewUpdate 'cards_currentlyWatching',@name, (response) =>
            @currentlyWatchingLayout = response.layout

        if event.params.action == 'test2'
          @chiika.viewManager.removeView 'cards_currentlyWatching'
          statistics = @chiika.viewManager.getViewByName('cards_statistics')

          if statistics? && statistics.getData().length > 0
            statisticsData = statistics.getData()[0]

            statisticsData.items[0].count++

            statistics.setData(statisticsData,'lastSaved').then (args) =>
              @requestViewRefresh()


  requestViewRefresh: ->
    @chiika.sendMessageToWindow 'main','refresh-data'
