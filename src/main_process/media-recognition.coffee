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

path                    = require 'path'
fs                      = require 'fs'

_forEach                = require 'lodash/collection/forEach'
_assign                 = require 'lodash.assign'
_find                   = require 'lodash/collection/find'
_filter                 = require 'lodash/collection/filter'
_remove                 = require 'lodash/array/remove'
_indexOf                = require 'lodash/array/indexOf'
dir                     = require 'node-dir'

string                  = require 'string'

module.exports = class MyAnimelistRecognition
  predict: (entry,title) ->
    animeTitle = entry.animeTitle
    animeEnglish = entry.animeEnglish
    synonyms = entry.animeSynonyms

    weight = 0

    if string(animeTitle).toLowerCase().contains(title) or string(animeTitle).toLowerCase().contains(title.toLowerCase())
      weight += 10

    if extra? && string(extra.animeEnglish).toLowerCase().contains(title)
      weight += 5

    _forEach synonyms, (syn) ->
      syn = syn.trim().toLowerCase()

      if string(syn).toLowerCase().contains(title)
        weight += 7

    words = title.split(' ')

    _forEach words, (word) =>
      if string(animeTitle).toLowerCase().contains(word)
        weight += 2

      _forEach synonyms, (syn) =>
        syn = syn.trim()

        if string(syn).toLowerCase().contains(word)
          weight += 2

    weight



  #
  #
  #
  cache: (detectCache,recognize,parse,videoFile,owner) ->
    cache = @doCache(detectCache.getData(),recognize,parse,videoFile)
    detectCache.setData(cache,"id")
    cache


  #
  #
  #
  doCache: (cached,entry) ->
    parseResult = entry.parse
    results = entry.results

    videoFile = entry.videoFile

    title = @clear(parseResult.AnimeTitle)

    if title.length > 0
      findInCache = _find cached,(o) -> o.title == title
      if !findInCache?
        cacheEntry = {}
        cacheEntry.title = title
        cacheEntry.files = []
        cacheEntry.owners = []
        _forEach results, (r) =>
          cacheEntry.owners.push { name: r.owner }

        cacheEntry.folder = ""

        cacheEntry.files.push { episode: parseResult.EpisodeNumber, file: videoFile }
        cached.push cacheEntry
      else
        # Check same episode exists
        files = findInCache.files

        findEpi = _find files, (o) => o.episode == parseResult.EpisodeNumber
        if !findEpi?
          findInCache.files.push { episode: parseResult.EpisodeNumber, file: videoFile }

        # Check if same owner is there
        owners = findInCache.owners

        _forEach results, (r) =>
          findOwner = _find owners, (o) => o.name == r.owner

          #If not , insert
          if !findOwner?
            owners.push r.owner

        # Add a folder for 'open-folder' stuff
        # At this point, a file exists,use its parent folder
        findInCache.folder = path.join(videoFile,'..')


  #
  #
  #
  cacheInBulk: (detectCache,list) ->
    cached = detectCache.getData()
    _forEach list,(entry) =>
      @doCache(cached,entry)

    detectCache.setDataArray(cached)

  #
  #
  #
  clear: (title) ->
    title = title.toLowerCase()
    title = title.trim()
    title = title.replace(/[^\w\s]/gi, '')
    title = title.split(':').join('')
    title = title.split(' ').join('') # Lets go

    title

  doRecognize: (title,library) ->
    results = []
    tryRecognize = @recognize(title,library)

    owner = ""
    if tryRecognize.recognized
      # get entry
      entries = tryRecognize.entries
      _forEach entries, (entry) =>
        owner = entry.owner
        results.push { owner: owner, recognize: tryRecognize }
    results

  doRecognizeLib: (title,library) ->
    results = []
    tryRecognize = @recognizeLib(title,library)

    owner = ""
    if tryRecognize.recognized
      # get entry
      entries = tryRecognize.entries
      _forEach entries, (entry) =>
        owner = entry.owner
        results.push { owner: owner, recognize: tryRecognize }
    results

  recognizeLib: (title,animelist) ->
    title = @clear(title)

    if chiika? && chiika.logger?
      chiika.logger.debug("Trying to recognize title #{title}")
    # Find the title in anime list
    findInAnimelist = _filter animelist, (o) => (@clear(o.animeTitle) == title)


    result = { entries: [] }
    suggestions = []

    if findInAnimelist.length > 0
      result = { recognized: true, entries: findInAnimelist,suggestions: suggestions }
    else
      recognized = false
      result.recognized = recognized
      result.suggestions = suggestions

    return result
  #
  #
  #
  recognize: (title,animelist) ->
    title = @clear(title)

    if chiika? && chiika.logger?
      chiika.logger.debug("Trying to recognize title #{title}")
    # Find the title in anime list
    findInAnimelist = _filter animelist, (o) => (@clear(o.animeTitle) == title)


    result = { entries: [] }
    suggestions = []

    if findInAnimelist.length > 0
      result = { recognized: true, entries: findInAnimelist,suggestions: suggestions }
    else
      recognized = false
      result.recognized = recognized
      result.suggestions = suggestions
      _forEach animelist, (anime) =>

        animeTitle = @clear(anime.animeTitle)
        # MAL has synoynms
        if anime.animeSynonyms?
          synonyms = anime.animeSynonyms.split(';')

          _forEach synonyms, (syn) =>
            syn = @clear(syn)
            if syn == title
              recognized = true
              result.recognized = recognized
              result.entries.push anime
              return false

        if recognized
          return false


        if !recognized
          # Generate suggestions
          weight = 0

          if string(animeTitle).contains(title) or string(animeTitle).contains(title)
            weight += 10

          if anime.animeSynonyms?
            _forEach synonyms, (syn) =>
              syn = @clear(syn)

              if string(syn).contains(title)
                weight += 7


          words = title.split(' ')

          _forEach words, (word) =>
            if string(@clear(animeTitle)).contains(word)
              weight += 2

            if anime.animeSynonyms?
              _forEach synonyms, (syn) =>
                syn = @clear(syn)

                if string(syn).contains(word)
                  weight += 2

          if weight > 0
            suggestions.push { weight: weight, entry: anime }

            if weight > 10
              return false



      if !recognized
        suggestions.sort (a,b) =>
          if a.weight > b.weight
            return -1
          else
            return 1
          return 0
        result.suggestions = suggestions
        result.recognized = false
    if chiika? && chiika.logger?
      chiika.logger.debug("Recognition returned #{result.recognized} with suggestion count #{result.suggestions.length}")
    return result

  #
  #
  #
  getVideoFilesFromFolder: (folder,fileTypes,callback) ->
    videoFiles = []
    dir.files folder, (err,files) =>
      if err
        throw err

      mkv = _filter files, (o) => o.indexOf(fileTypes[0]) > -1
      mp4 = _filter files, (o) => o.indexOf(fileTypes[1]) > -1

      videoFiles.push x for x in mkv
      videoFiles.push x for x in mp4

      callback?(videoFiles)
