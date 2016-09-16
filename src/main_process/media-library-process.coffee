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

_forEach                = require 'lodash.foreach'
_assign                 = require 'lodash.assign'
_find                   = require 'lodash/collection/find'
_filter                 = require 'lodash/collection/filter'
_remove                 = require 'lodash/array/remove'
_when                   = require 'when'
moment                  = require 'moment'
string                  = require 'string'
path                    = require 'path'
fs                      = require 'fs'
MediaRecognition        = require './media-recognition'

AnitomyNode             = require '../vendor/anitomy-node/AnitomyNode'

process.on 'exit', ->
  process.send "Exit"

process.on 'uncaughtException', (error) ->
  process.send error

elapsedTime = (start,text) ->
  precision = 3
  elapsed = process.hrtime(start)[1] / 1000000
  process.send(process.hrtime(start)[0] + " s, " + elapsed.toFixed(precision) + " ms - " + text)
  start = process.hrtime()

class LibraryScanner
  constructor: ->
    @libraryPaths = JSON.parse(process.argv[2])
    @fileTypes = ['.mkv','.mp4']
    @videoFiles = []
    @anitomy = new AnitomyNode.Root()

    @recognition = new MediaRecognition()

    process.on 'message', (message) =>
      if message.message == 'set-anime-list'
        @libraryOwnerMap = JSON.parse(message.animelist)

        process.send "Media Process library length #{@libraryOwnerMap.length}"
        @start = process.hrtime()
        @init()

  #
  #
  #
  init: ->
    @run().then => @tryRecognize()

  run: ->
    new Promise (resolve) =>
      _forEach @libraryPaths, (library) =>
        @recognition.getVideoFilesFromFolder library,@fileTypes, (files) =>
          @videoFiles.push x for x in files
          process.send "#{library} has #{files.length} video file"
          resolve()

  #
  #
  #
  tryRecognize: ->
    progress = 0
    counter = 0
    recognizedCount = 0
    recognizedList = []
    unRecognizedList = []

    # recognized = @recognize('[HorribleSubs] Boku Dake ga Inai Machi - 01 [720p].mkv')
    # process.send recognized

    _forEach @videoFiles, (videoFile) =>
      seperate = videoFile.split(path.sep)
      videoName = seperate[seperate.length - 1]
      try
        parse =  @anitomy.Parse videoName

        title = parse.AnimeTitle.toLowerCase()

        libRecognizeResults = @recognition.doRecognize(title,@libraryOwnerMap)

        recognized = false
        _forEach libRecognizeResults, (libRecognize) =>
          if libRecognize.recognize.recognized
            recognized = true
            return false

        if recognized
          recognizedList.push { parse: parse,results:libRecognizeResults,videoFile: videoFile }
        else
          unRecognizedList.push { parse: parse,results:libRecognizeResults, videoFile: videoFile }
      catch error
        process.send error.stack
        process.send error.message

      progress = (counter / @videoFiles.length) * 100
      @updateProgress(progress)

    elapsedTime(@start,'recognition')
    process.send "Recognized: #{recognizedList.length}"
    process.send "Not Recognized: #{unRecognizedList.length}"

    process.send { message: 'media-recognized', list: recognizedList }
    process.send { message: 'media-not-recognized', list: unRecognizedList }


  #
  #
  #
  updateProgress: (progress) ->
    #




libraryScanner = new LibraryScanner()
