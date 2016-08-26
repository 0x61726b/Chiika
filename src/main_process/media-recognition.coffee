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

_forEach                = require 'lodash.foreach'
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
  cache: (detectCache,recognize,parse,videoFile) ->
    cache = @doCache(detectCache.getData(),recognize,parse,videoFile)
    detectCache.setData(cache,'id')
    cache


  #
  #
  #
  doCache: (cacheData,recognize,parse,videoFile) ->
    findInCache = _find cacheData, (o) => o.id == recognize.entry.mal_id
    if findInCache?
      oneLevelBack = path.join(videoFile,'..')

      pathExists = _find findInCache.knownPaths, (o) -> o == oneLevelBack
      knownPathIndex = _indexOf findInCache.knownPaths,pathExists
      if pathExists?
        findInCache.knownPaths.splice(knownPathIndex,1,oneLevelBack)
      else
        findInCache.knownPaths.push path.join(videoFile,'..')

      fileExists = _find findInCache.files, (o) -> o.file == videoFile
      fileIndex = _indexOf findInCache.files,fileExists

      if fileExists?
        findInCache.files.splice(fileIndex,1,{ file:videoFile, episode: parse.EpisodeNumber })
      else
        findInCache.files.push { file:videoFile, episode: parse.EpisodeNumber }
    else
      findInCache =
        id: recognize.entry.mal_id
        knownPaths: [
          path.join(videoFile,'..')
        ]
        files: [
          { file:videoFile, episode: parse.EpisodeNumber }
        ]
    findInCache

  #
  #
  #
  cacheInBulk: (detectCache,list) ->
    cacheEntries = detectCache.getData()
    _forEach list,(entry) =>
      cacheEntries.push @doCache(cacheEntries,entry.recognize,entry.parse,entry.videoFile)


    clearEntries = []
    for i in [0...cacheEntries.length]
      cache = cacheEntries[i]
      find = _find clearEntries, (o) -> o.id == cache.id

      if !find?
        clearEntries.push cache

    detectCache.setDataArray(clearEntries)

  #
  #
  #
  clear: (title) ->
    title = title.toLowerCase()
    title = title.trim()
    title = title.replace(/[^\w\s]/gi, '')

    title

  recognize: (title,animelist,animeextra) ->
    title = @clear(title)

    if chiika? && chiika.logger?
      chiika.logger.debug("Trying to recognize title #{title}")
    # Find the title in anime list
    findInAnimelist = _find animelist, (o) => (@clear(o.animeTitle) == title)

    result = {  }
    suggestions = []

    if findInAnimelist?
      result = { recognized: true, entry: findInAnimelist,suggestions: suggestions }
    else
      recognized = false
      result.recognized = recognized
      result.suggestions = suggestions
      _forEach animelist, (anime) =>
        extra = _find animeextra, (o) -> o.mal_id == anime.mal_id

        synonyms = anime.animeSynonyms.split(';')
        animeTitle = @clear(anime.animeTitle)

        _forEach synonyms, (syn) =>
          syn = @clear(syn)
          if syn == title
            recognized = true
            result.recognized = recognized
            result.entry = anime
            return false

        if recognized
          return false


        if !recognized
          # Generate suggestions
          weight = 0

          if string(animeTitle).contains(title) or string(animeTitle).contains(title)
            weight += 10

          if extra? && string(@clear(extra.animeEnglish)).contains(title)
            weight += 5

          _forEach synonyms, (syn) =>
            syn = @clear(syn)

            if string(syn).contains(title)
              weight += 7


          words = title.split(' ')

          _forEach words, (word) =>
            if string(@clear(animeTitle)).contains(word)
              weight += 2

            _forEach synonyms, (syn) =>
              syn = @clear(syn)

              if string(syn).contains(word)
                weight += 2

          if weight > 0
            suggestions.push { weight: weight, entry: anime, extra: extra }

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
