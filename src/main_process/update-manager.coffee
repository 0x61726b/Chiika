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

{autoUpdater}           = require 'electron'

_forEach                = require 'lodash.foreach'
_assign                 = require 'lodash.assign'
_when                   = require 'when'
_find                   = require 'lodash/collection/find'
_indexOf                = require 'lodash/array/indexOf'
string                  = require 'string'

module.exports = class UpdateManager
  constructor: ->
    autoUpdater.setFeedURL("https://chiika.herokuapp.com/download/latest")

    @handleEvents()

  checkForUpdates: ->
    autoUpdater.checkForUpdates()

  handleEvents: ->
    autoUpdater.on 'update-available', () =>
      console.log "Update available"
      chiika.emitter.emit 'update-available'

    autoUpdater.on 'update-downloaded', () =>
      console.log "Update downloaded"
      chiika.emitter.emit 'update-downloaded'

    autoUpdater.on 'error', (e) =>
      console.log "errror #{e}"
      chiika.emitter.emit 'update-error',e

    autoUpdater.on 'checking-for-update', () =>
      console.log "Checking for update"
      chiika.emitter.emit 'checking-for-update'

    autoUpdater.on 'update-not-available', () =>
      console.log "Update not available"
      chiika.emitter.emit 'update-not-available'
