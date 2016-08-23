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


mdPath = process.cwd() + '/vendor/media-detect-helpers/MediaDetect'
anitomyPath = process.cwd() + '/vendor/anitomy-node/AnitomyNode'


class Win32MediaDetect
  md: null
  detectedPlayers: []
  constructor: ->
    @mediaPlayers = JSON.parse((process.argv[2]))

    @disableBrowserDetection = true

    try
      @md = require(mdPath)
      @anitomy = require(anitomyPath)
    catch error
      obj = {}
      Error.captureStackTrace(obj)
      process.send(obj.stack)
      throw "Media Detect Win32 child process has crashed."

    @md = @md.MediaDetect()
    @anitomy = new @anitomy.Root()

    try
      crazyLoop = =>
        @lookForMediaPlayers()
      interval = setInterval(crazyLoop,1000)

      process.on 'exit', ->
        process.send('kill')
        clearInterval(interval)

      process.on 'uncaughtException', (error) ->
        process.send('error')
        process.send(error.stack)

    catch error
      obj = {}
      Error.captureStackTrace(obj)
      process.send(obj.stack)
      process.send(error.message)


  lookForMediaPlayers: ->
    currentWindows = @md.GetCurrentWindows() # Native method
    _forEach @mediaPlayers, (mediaPlayer) =>
      findMp = _filter currentWindows.PlayerArray, (o) -> o.windowClass == mediaPlayer.class

      if findMp.length > 0
        _forEach findMp, (mv) =>
          findExecutableName = _find mediaPlayer.executables, (m) -> m == mv.processName

          if findExecutableName?
            if mediaPlayer.browser?
              priority = 0
              _assign mv, { browser: mediaPlayer }
            else
              priority = 1
              _assign mv, { mediaPlayer: mediaPlayer }

            _assign mv, { priority: priority,date: moment().valueOf() }

            checkIfMpWasRunningLastTick = _find @detectedPlayers, { processName: mv.processName }

            if checkIfMpWasRunningLastTick? && checkIfMpWasRunningLastTick.windowTitle != mv.windowTitle
              _remove @detectedPlayers, { windowClass: mediaPlayer.class }
              checkIfMpWasRunningLastTick= null

            if !checkIfMpWasRunningLastTick?
              skip = false

              if mediaPlayer.browser? && @disableBrowserDetection
                skip = true

              if !skip
                @detectedPlayers.push mv

              @detectedPlayers.sort (a,b) =>
                if a.priority == b.priority
                  return b.date - a.date
                b.priority - a.priority
      else
        lookForMp = _find @detectedPlayers, (o) -> o.windowClass == mediaPlayer.class
        _remove @detectedPlayers, (o) -> o.windowClass == mediaPlayer.class

        @detectedPlayers.sort (a,b) =>
          if a.priority == b.priority
            return moment.utc(b.date.timeStamp).diff(moment.utc(a.date.timeStamp))
          return b.priority - a.priority

    if @detectedPlayers.length > 0
      mostRecent = @detectedPlayers[0]

      if mostRecent.priority == 1
        videoFile = @md.GetVideoFileOpenByPlayer({ pid: mostRecent.PID })
        if videoFile?
          videoFileName = videoFile.substring(string(videoFile).lastIndexOf('\\') + 1)

          AnitomyParse = @anitomy.Parse(videoFileName) # Native

          state = { status: 'md-running-video', player: mostRecent, videoFile: videoFile, anitomy: AnitomyParse }
          process.send(state)
        else
          process.send({ status: 'md-video-not-video-file'})
    else
      process.send({ status: 'md-no-video'})


Win32Media = new Win32MediaDetect()
