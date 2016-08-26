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
string        = scriptRequire 'string'
AnitomyNode   = require "#{mainProcessHome}/../../vendor/anitomy-node/AnitomyNode"
Recognition   = require "#{mainProcessHome}/media-recognition"

module.exports = class Media
  name: "media"
  displayDescription: "Media"
  isService: false
  isActive: true
  order: 3

  # Will be called by Chiika with the API object
  # you can do whatever you want with this object
  # See the documentation for this object's methods,properties etc.
  constructor: (chiika) ->
    @chiika = chiika

    @recognition = new Recognition()
    @anitomy = new AnitomyNode.Root()

  # This method is controls the communication between app and script
  # If you change this method things will break
  #
  on: (event,args...) ->
    @chiika.on @name,event,args...


  # After the constructor run() method will be called immediately after.
  # Use this method to do what you will
  #
  run: (chiika) ->
    #This is the first event called here to let user do some initializing
    @on 'initialize',=>


    @on 'post-init', (init) =>
      init.defer.resolve()

    @on 'set-folders-for-entry', (args) =>
      id = args.params.id
      folders = args.params.folders

      detectCache = @chiika.viewManager.getViewByName('anime_detect_cache')

      @chiika.logger.verbose("Setting folders for #{id}. Folder length #{folders.length}")

      if detectCache?
        cache = detectCache.getData()

        findInCache = _find cache, (o) => o.id == id

        if findInCache?
          findInCache.knownPaths = folders
        else
          findInCache = { id: id, knownPaths: folders, files: []}

        detectCache.setData(findInCache, 'id')
        @chiika.openExternal(folders[0])



    @on 'scan-folder', (args) =>
      folder = args.folder
      id = args.id

      @chiika.logger.info("Scanning folder #{folder}")

      detectCache = @chiika.viewManager.getViewByName('anime_detect_cache')
      animelistView = @chiika.viewManager.getViewByName('myanimelist_animelist')
      animeExtraView = @chiika.viewManager.getViewByName('myanimelist_animeextra')

      if animelistView?
        animelist = animelistView.getData()
        animeextra = animeExtraView.getData()

        @recognition.getVideoFilesFromFolder folder,['.mkv','.mp4'], (files) =>
          cache = []
          _forEach files, (videoFile) =>
            seperate = videoFile.split(path.sep)
            videoName = seperate[seperate.length - 1]
            parse =  @anitomy.Parse videoName
            title = parse.AnimeTitle
            recognize = @recognition.recognize(title,animelist,animeextra)

            if recognize.recognized && recognize.entry?
              # Save this file to cache
              cachedEntry = @recognition.cache(detectCache,recognize,parse,videoFile)
              cache.push cachedEntry
          args.return(cache)


    @on 'scan-library', () =>
      libraryPaths = [
        'E:/Anime'
      ]
      animelistView = @chiika.viewManager.getViewByName('myanimelist_animelist')
      animeExtraView = @chiika.viewManager.getViewByName('myanimelist_animeextra')

      if animelistView?
        animelist = animelistView.getData()

        animeextra = animeExtraView.getData()

        @chiika.media.runLibraryProcess libraryPaths,animelist,animeextra, (results) =>
          detectCache = @chiika.viewManager.getViewByName('anime_detect_cache')
          detectCache.clear().then =>
            @recognition.cacheInBulk(detectCache,results)

    @on 'system-event', (event) =>
      if event.name == 'md-detect' or (event.name == 'shortcut-pressed' and event.params.action == 'test')
        if event.params.action?
          # anitomy = event.params
          videoFile = 'E:/Anime/[CoalGuys] K-ON! Movie (720p) [D09FC86B].mkv'
          anitomy = { AnimeTitle: 'K-ON! Movie', ReleaseGroup: 'FFF', FileName: "[CoalGuys] K-ON! Movie (720p) [D09FC86B]", EpisodeNumber: '01' }
        else
          anitomy = event.params.anitomy
          videoFile = event.params.videoFile


        title = anitomy.AnimeTitle.toLowerCase()
        group = anitomy.ReleaseGroup

        # Search title in local list
        animelistView   = @chiika.viewManager.getViewByName('myanimelist_animelist')
        animeExtraView   = @chiika.viewManager.getViewByName('myanimelist_animeextra')
        if animelistView?
          animelist = animelistView.getData()
          animeextra = []
          if animeExtraView?
            animeextra = animeExtraView.getData()

          recognize = @recognition.recognize(title,animelist,animeextra)

          if recognize.recognized
            if recognize.entry?
              @chiika.createNotificationWindow =>
                layout = { title: anitomy.AnimeTitle, episode: anitomy.EpisodeNumber,image: recognize.entry.animeImage }
                @chiika.sendMessageToWindow 'notification','notf-bar-recognized', layout

              @chiika.emit 'create-card', { name: 'cards_currentlyWatching' }

              # Save this file to cache
              detectCache = @chiika.viewManager.getViewByName('anime_detect_cache')

              @recognition.cache(detectCache,recognize,anitomy,videoFile)

              @chiika.requestViewUpdate 'cards_currentlyWatching','cards', null, { entry: recognize.entry,parse: anitomy }
          else
            # Not recognized
            #@chiika.emit 'create-card', { name: 'cards_notRecognized' }
            #@chiika.requestViewUpdate 'cards_notRecognized','cards', null, { result: recognize,parse: anitomy }

            @chiika.createNotificationWindow =>
              layout = { title: anitomy.AnimeTitle, episode: anitomy.EpisodeNumber, suggestions: recognize.suggestions }
              @chiika.sendMessageToWindow 'notification','notf-bar-not-recognized', layout

            # onSearch = (results) =>
            #   suggestions = []
            #   if results.length > 0
            #     _forEach results, (entry) =>
            #       weight = @recognition.predict(entry,title)
            #       recognize.suggestions.push { weight: weight, entry: entry }
            #
            #   recognize.suggestions.sort (a,b) =>
            #     if a.weight > b.weight
            #       return -1
            #     else
            #       return 1
            #     return 0
            #   @chiika.requestViewUpdate 'cards_notRecognized','cards', null, { result: recognize,parse: anitomy }


            # Create a search
            #@chiika.emit 'make-search', { calling: 'myanimelist', title: anitomy.AnimeTitle,return: onSearch }

            #@chiika.sendMessageToWindow('main','get-ui-data-by-name-response',{ name: 'cards_currentlyWatching', item: @chiika.ui.getUIItem('cards_currentlyWatching') } )
      if event.name == 'md-close' or (event.name == 'shortcut-pressed' and event.params.action == 'test2')
        view = @chiika.viewManager.getViewByName('cards_currentlyWatching')

        @chiika.closeNotificationWindow()
        
        if view?
          @chiika.sendMessageToWindow('main','get-ui-data-by-name-response',{ name: 'cards_currentlyWatching', item: null } )
          @chiika.viewManager.removeView 'cards_currentlyWatching'

        view = @chiika.viewManager.getViewByName('cards_notRecognized')
        if view?
          @chiika.sendMessageToWindow('main','get-ui-data-by-name-response',{ name: 'cards_notRecognized', item: null } )
          @chiika.viewManager.removeView 'cards_notRecognized'
