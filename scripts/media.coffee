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



_forEach      = scriptRequire 'lodash/collection/forEach'
_pick         = scriptRequire 'lodash/object/pick'
_find         = scriptRequire 'lodash/collection/find'
_indexOf      = scriptRequire 'lodash/array/indexOf'
_assign       = scriptRequire 'lodash.assign'
moment        = scriptRequire 'moment'
string        = scriptRequire 'string'


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

    if process.platform == 'win32'
      AnitomyNode   = require "#{mainProcessHome}/../vendor/anitomy-node/AnitomyNode"
      Recognition   = require "#{mainProcessHome}/media-recognition"

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
          libraryDataByOwner.push { owner: viewOwnerMap.owner, library: viewData,viewName: viewOwnerMap.viewName }

    libraryDataByOwner

  scanFolder: (folder,title,callback) ->
    libraryDataByOwner = @libraryDataByOwner()

    results = []

    @recognition.getVideoFilesFromFolder folder, ['.mkv','.mp4'], (files) =>
      error = false
      errorMessage = "An error occured while recognizing entries for #{title}."
      _forEach files, (videoFile) =>
        seperate = videoFile.split(path.sep)
        videoName = seperate[seperate.length - 1]
        try
          parse =  @anitomy.Parse videoName
          parse.AnimeTitle = title
          episode = parse.EpisodeNumber
          if episode == ""
            error = true
            errorMessage = "Some of the video files are either badly named or Chiika could not identify them."

          libRecognizeResults = @recognition.doRecognize(title,libraryDataByOwner)
          results.push { parse: parse,results:libRecognizeResults,videoFile: videoFile }

      callback?({ results: results, success: !error, errorMessage: errorMessage})




  # This method is controls the communication between app and script
  # If you change this method things will break
  #
  on: (event,args...) ->
    try
      @chiika.on @name,event,args...
    catch error
      console.log error
      throw error



  # After the constructor run() method will be called immediately after.
  # Use this method to do what you will
  #
  run: (chiika) ->
    #This is the first event called here to let user do some initializing
    @on 'initialize',=>


    @on 'post-init', (init) =>
      init.defer.resolve()

    @on 'reconstruct-ui', (ui) =>
      libraryView =
        name: 'chiika_library'
        owner: @name
        displayName: ''
        displayType: 'none'
        noUpdate: true
      @chiika.viewManager.addView libraryView

    @on 'get-view-data', (args) =>
      if process.platform != 'win32'
        return
      @chiika.logger.script("[yellow](#{@name}) get-view-data #{args.view.name}")
      return
      if args.view.name == 'chiika_library'
        detectCache = @chiika.viewManager.getViewByName('anime_detect_cache')
        if detectCache?
          data = detectCache.getData()

          libraryDataByOwner = @libraryDataByOwner()

          libraryView = []
          episodeCount = 0

          _forEach data,(d) =>
            title = d.title

            entryFound = false
            animeEntry = null

            viewByOwner = []

            # Find in service data

            libraryDataByOwnerLength = libraryDataByOwner.length

            _forEach libraryDataByOwner, (lib) =>
              library = lib.library
              owner = lib.owner

              findInList = _find library, (o) => @recognition.clear(o.animeTitle) == title

              if findInList?
                viewByOwner.push { owner: owner, entry: findInList }

                if libraryDataByOwnerLength <= viewByOwner.length
                  return false

            if viewByOwner.length > 0
              episodeCount += d.files.length
              libraryView.push { entries: viewByOwner, files: d.files, owners: d.owners,title: title }





          stats =
            series: libraryView.length
            episodes: episodeCount
            notRecognized: 0
          args.return({ stats: stats, library: libraryView})


    @on 'play-episode', (args) =>
      @chiika.logger.script("[yellow](#{@name}) play-next-episode")

      title = args.params.title
      episode = args.params.episode

      title = @recognition.clear(title)
      detectCache = @chiika.viewManager.getViewByName('anime_detect_cache')

      if detectCache?
        cache = detectCache.getData()
        findEntry = _find cache, (o) -> o.title == title

        fileToPlay = ""
        if findEntry?
          _forEach findEntry.files, (f) =>
            if parseInt(f.episode) == parseInt(episode)
              fileToPlay = f.file
              return false

        if fileToPlay.length > 0
          @chiika.openExternal(fileToPlay)
        else
          args.return({state: 'episode-not-found'})

    @on 'set-folders-for-entry', (args) =>
      title = args.params.title
      folder = args.params.folder[0]
      detectCache = @chiika.viewManager.getViewByName('anime_detect_cache')

      @chiika.logger.verbose("Setting folders for #{title} -> #{folder}.")

      title = @recognition.clear(title)

      if detectCache?
        cache = detectCache.getData()
        findInCache = _find cache, (o) => o.title == title

        if findInCache?
          findInCache.folder = folder
        else
          findInCache = { title: title, folder: folder}

        @scanFolder folder,title, (args) =>
          if !args.success
            @chiika.showToast args.errorMessage, 8000, 'error'

            detectCache.setData(findInCache,'title')
          else
            @recognition.cacheInBulk(detectCache,args.results)

        @chiika.openExternal(folder)


    @on 'open-folder', (args) =>
      @chiika.logger.script("[yellow](#{@name}) open-folder")
      title = args.params.title

      title = @recognition.clear(title)
      detectCache = @chiika.viewManager.getViewByName('anime_detect_cache')

      if detectCache?
        cache = detectCache.getData()
        findEntry = _find cache, (o) -> o.title == title

        if findEntry?
          knownPaths = findEntry.folder
          @chiika.openExternal(knownPaths)

          @chiika.logger.info("Opening folder #{knownPaths}")
        else
          @chiika.logger.info("No known folders for #{title}")
          args.return({ state: 'not-found'})


    @on 'scan-library', (args) =>
      libraryPaths = @chiika.settingsManager.getOption('LibraryPaths')

      animeDbView = @chiika.viewManager.getViewByName('anime_db')
      animeDbData = animeDbView.getData()

      if animeDbData.length > 0
        @chiika.media.runLibraryProcess libraryPaths,animeDbData, (results) =>
          detectCache = @chiika.viewManager.getViewByName('anime_detect_cache')


          @recognition.cacheInBulk(detectCache,results)
          #
          #
          args.return({ recognizedFiles: results.length })
          #
          @chiika.requestViewDataUpdate('media','chiika_library')


    @on 'system-event', (event) =>
      @chiika.logger.script("[yellow](#{@name}) system-event - #{event.name}")

      if event.name == 'md-detect'
        @tryRecognize(event.params)

      if event.name == 'md-close'
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
        episode = layout.episode
        title = layout.title

        libraryData = @libraryDataByOwner()

        _forEach libraryData,(lib) =>
          library = lib.library
          owner = lib.owner
          viewName = lib.viewName

          # Find
          entry = _find library, (o) -> o.animeTitle == title

          if entry?
            listActionParams =
              viewName: viewName
              id: entry.id
              item:
                current: episode
            @chiika.emit 'list-action', { calling: owner, action: 'progress-update', params: listActionParams }

      if event.name == 'md-pick'
        entry = event.params.entry
        layout = event.params.layout
        parse = layout.parse
        videoFile = layout.videoFile

        findEntry = _find layout.suggestions, (o) -> o.entry.id == entry

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
                    layout = { title: findEntry.entry.animeTitle, episode: layout.episode,image: findEntry.entry.animeImage, imageLink: "myanimelist.net/anime/#{findEntry.entry.id}" }
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

    title = anitomy.AnimeTitle
    group = anitomy.ReleaseGroup

    # Search title in local list
    animeDbView   = @chiika.viewManager.getViewByName('anime_db')

    if animeDbView?
      animeDbData = animeDbView.getData()

      recognize = @recognition.recognize(title,animeDbData)
      recognized = recognize.recognized

      if !recognized
        # Check cache
        detectCache = @chiika.viewManager.getViewByName('anime_detect_cache')
        cache = detectCache.getData()


        _forEach cache, (c) =>
          files = c.files

          findInFiles = _find files, (o) => o.file == videoFile

          if findInFiles?
            recognized = true

            title = c.title
            recognize = @recognition.recognize(title,animelist)
            return false


      if recognized
        @chiika.createNotificationWindow 200,() =>
          layout = { title: anitomy.AnimeTitle, episode: anitomy.EpisodeNumber,image: recognize.entries[0].animeImage }
          @chiika.sendMessageToWindow 'notification','notf-bar-recognized', layout

        @chiika.emit 'create-card', { name: 'cards_currentlyWatching' }

        @chiika.requestViewUpdate 'cards_currentlyWatching','cards', null, { entry: recognize.entries[0],parse: anitomy }

      else
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
        @chiika.emit 'make-search', { calling: 'myanimelist', title: anitomy.AnimeTitle, type: 'anime',return: onSearch }
