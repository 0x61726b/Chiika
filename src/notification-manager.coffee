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

_find                               = require 'lodash/collection/find'
_indexOf                            = require 'lodash/array/indexOf'
_forEach                            = require 'lodash/collection/forEach'
CardViews                           = require './cards'

module.exports = class NotificationManager
  error: (message) ->
    chiika.notification({ title: 'Error!', type: 'error', message: message })

  dialog: (title,message,confirmText,confirm) ->
    chiika.notification({ title:title, type: 'dialog', message: message, confirmText: confirmText,confirm: confirm })

  prompt: (message,action) ->
    chiika.notification({ type: 'prompt', message: message, action: action })

  updateDialog: (callback) ->
    @dialog('Update is downloaded!','Are you sure to start the software update for Chiika? The app will be unavailable for a short while.','Update!',callback)

  episodeNotFound: (title,episode,callback) ->
    @dialog('Episode not found!',"We couldnt find episode number #{episode} for #{title}", 'Set Folder',callback)

  folderNotFound: (callback) ->
    @dialog('Not found in the library!',"Choose the location.", 'Set Folder',callback)

  deleteFromListConfirmation: (title,callback) ->
    @dialog('Are you sure?',"Delete #{title} from your library?", 'Delete',callback)
