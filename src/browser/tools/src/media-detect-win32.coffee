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
  spawn: ->
    str = JSON.stringify(mediaPlayerList)
    child = cp.fork("#{__dirname}/../../../media-detect-win32-process-helper.js",[str])

    child.on 'close',(code,signal) ->
      application.logDebug "Media detector process exited.This shouldn't happen."


module.exports = MediaDetect
