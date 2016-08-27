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

  scanFolder: (folder,callback) ->
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
            cachedEntry = { parse: parse,recognize:recognize, videoFile: videoFile }
            cache.push cachedEntry
        @recognition.cacheInBulk(detectCache,cache)
        callback?(cache)

  scanFolderNot: (folder,entry,callback) ->
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

          cachedEntry = { parse: parse,recognize:{ entry: entry }, videoFile: videoFile }
          cache.push cachedEntry
        @recognition.cacheInBulk(detectCache,cache)
        callback?(cache)



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

      @scanFolder folder, (cache) =>
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
          @recognition.cacheInBulk(detectCache,results)

    @on 'system-event', (event) =>
      @chiika.logger.script("[yellow](#{@name}) system-event - #{event.name}")
      
      if event.name == 'md-detect' or (event.name == 'shortcut-pressed' and event.params.action == 'test')
        @tryRecognize(event.params)

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

      if event.name == 'md-update'
        layout = event.params
        console.log layout

      if event.name == 'md-pick'
        entry = event.params.entry
        layout = event.params.layout
        parse = layout.parse
        videoFile = layout.videoFile

        findEntry = _find layout.suggestions, (o) -> o.entry.mal_id == entry

        if findEntry?
          onValues = (args) =>
            if args.list
              homeFolder = path.join(videoFile,'..')
              @scanFolderNot homeFolder, findEntry.entry,(result) =>
                console.log "Scanazad #{homeFolder}"
                @tryRecognize({ parse: parse, videoFile: videoFile, cache: result })

            else
              onAdded = =>
                # Try to recognize again
                animelistView   = @chiika.viewManager.getViewByName('myanimelist_animelist')
                animeExtraView   = @chiika.viewManager.getViewByName('myanimelist_animeextra')
                if animelistView?
                  animelist = animelistView.getData()
                  animelist.push findEntry.entry # Hackz
                  animeextra = []
                  if animeExtraView?
                    animeextra = animeExtraView.getData()

                  recognize = @recognition.recognize(findEntry.entry.animeTitle,animelist,animeextra)

                  if recognize.recognized
                    layout = { title: findEntry.entry.animeTitle, episode: layout.episode,image: findEntry.entry.animeImage, imageLink: "myanimelist.net/anime/#{findEntry.entry.mal_id}" }
                    @chiika.sendMessageToWindow 'notification','notf-bar-recognized', layout

                    @chiika.emit 'create-card', { name: 'cards_currentlyWatching' }

                    # Save this file to cache
                    # detectCache = @chiika.viewManager.getViewByName('anime_detect_cache')
                    #
                    # @recognition.cache(detectCache,recognize,anitomy,videoFile)

                    @chiika.requestViewUpdate 'cards_currentlyWatching','cards', null, { entry: recognize.entry,parse: parse }


              @chiika.emit 'add-anime', { calling: 'myanimelist', entry:findEntry.entry, status:"1", return: onAdded }
          @chiika.emit 'get-anime-values', { calling: 'myanimelist', entry:findEntry.entry, return: onValues }

  #
  #
  #
  tryRecognize: (params) ->
    anitomy = params.parse
    videoFile = params.videoFile
    cacheList = params.cace

    title = anitomy.AnimeTitle
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

      recognized = recognize.recognized

      if !recognized
        # Check cache
        detectCache = @chiika.viewManager.getViewByName('anime_detect_cache')

        cache = {}
        if cacheList?
          cache = cacheList
        else if detectCache?
          cache = detectCache.getData()


        found = false
        cacheEntry = null
        _forEach cache, (c) =>
          files = c.files

          findFile = _find files, (o) -> o.file == videoFile

          if findFile?
            found = true
            cacheEntry = c
            return false

        if cacheEntry?
          findEntry = _find animelist, (o) -> o.mal_id == cacheEntry.id

          if findEntry?
            recognize.recognized = true
            recognize.entry = findEntry




      if recognize.recognized
        if recognize.entry?
          @chiika.createNotificationWindow 200,() =>
            layout = { title: anitomy.AnimeTitle, episode: anitomy.EpisodeNumber,image: recognize.entry.animeImage, imageLink: "myanimelist.net/anime/#{recognize.entry.mal_id}" }
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

        @chiika.createNotificationWindow 250, =>
          layout = { title: anitomy.AnimeTitle, episode: anitomy.EpisodeNumber, suggestions: recognize.suggestions,videoFile: videoFile, parse: anitomy }
          @chiika.sendMessageToWindow 'notification','notf-bar-not-recognized', layout

        onSearch = (results) =>
          suggestions = []
          if results.length > 0
            _forEach results, (entry) =>
              weight = @recognition.predict(entry,title)
              recognize.suggestions.push { weight: weight, entry: entry }

          recognize.suggestions.sort (a,b) =>
            if a.weight > b.weight
              return -1
            else
              return 1
            return 0
          # @chiika.requestViewUpdate 'cards_notRecognized','cards', null, { result: recognize,parse: anitomy }
          layout = { title: anitomy.AnimeTitle, episode: anitomy.EpisodeNumber, suggestions: recognize.suggestions,videoFile: recognize.videoFile }
          @chiika.sendMessageToWindow 'notification','notf-bar-not-recognized', layout


        # Create a search
        @chiika.emit 'make-search', { calling: 'myanimelist', title: anitomy.AnimeTitle,return: onSearch }
