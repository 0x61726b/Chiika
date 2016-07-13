#----------------------------------------------------------------------------
#Chiika
#
#This program is free software; you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation; either version 2 of the License, or
#(at your option) any later version.
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#Date: 9.6.2016
#authors: arkenthera
#Description:
#----------------------------------------------------------------------------

_ = require 'lodash'
_when = require 'when'
cp = require 'child_process'
psnode = require 'ps-node'
path = require 'path'
mediaPlayerList = require '../mediaPlayerList' #Temp

class MediaDetect
  currentPlayer: null,
  currentVideoFile: { EpisodeNumber: -1 }
  constructor: ->
    #@currentVideoFile = { EpisodeNumber: -1 }
  spawn: ->
    str = JSON.stringify(mediaPlayerList)
    child = cp.fork("#{__dirname}/../../../media-detect-win32-process-helper.js",[str])

    child.on 'close',(code,signal) ->
      application.logDebug "Media detector process exited.This shouldn't happen."

    child.on 'message', (m) =>
      if m.status == 'mp_found'
        application.emitter.emit 'mp-found',m.player
        @currentPlayer = m.player
        @currentVideoFile = { EpisodeNumber: -1 }

      if m.status == 'mp_running_video'
        if @currentVideoFile.AnimeTitle != m.result.AnimeTitle || @currentVideoFile.EpisodeNumber != m.result.EpisodeNumber
          application.emitter.emit 'mp-video-changed',m.result
          console.log "Detected Anime Changed: " + @currentVideoFile.AnimeTitle + " Ep: " + @currentVideoFile.EpisodeNumber
          console.log m.result.AnimeTitle + " Ep: " + m.result.EpisodeNumber
          @currentVideoFile = m.result

        application.emitter.emit 'mp-running-video',m.result
      if m.status == 'mp_closed'
        application.emitter.emit 'mp-closed'

        @currentVideoFile = { EpisodeNumber: -1 }
        @currentPlayer = null


module.exports = MediaDetect
