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
_assign                             = require 'lodash.assign'
CardViews                           = require './cards'

module.exports = class NotificationManager
  error: (message) ->
    chiika.notification({ title: 'Error!', type: 'error', message: message })

  dialog: (title,message,confirmText,confirm) ->
    chiika.notification({ title:title, type: 'dialog', message: message, confirmText: confirmText,confirm: confirm })

  info: (title,message,params) ->
    swal = { title:title, type: 'info', message: message }
    _assign swal,params
    chiika.notification(swal)

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

  browserExtensionWarning: ->
    @info("Streaming","In order to make everything smooth,
    <ul>
      <li>If chrome is open right now, restart it or reload chiika-chrome extension.</li>
      <li>we should advise that you turn off 'Stream Detection' when using this option.
      See <a id='streaming-warning-docs' href='#'>here</a> for more info!</li>
    </ul>", { html: true })
    $("#streaming-warning-docs").click (e) =>
      e.preventDefault()
      chiika.openShellUrl('https://github.com/arkenthera/Chiika/docs/streaming.md')


  linuxOsxStreamingWarning: ->
    @info("Streaming on Linux/OSX", "In order for detection to work, we advise you to download our
    <a id='streaming-warning-firefox' href='#'>firefox</a> or
    <a id='streaming-warning-chrome' href='#'>chrome</a> extensions.", { html: true })

    $("#streaming-warning-chrome").click (e) =>
      e.preventDefault()
      chiika.openShellUrl('https://github.com/arkenthera/Chiika/docs/streaming.md')

    $("#streaming-warning-firefox").click (e) =>
      e.preventDefault()
      chiika.openShellUrl('https://github.com/arkenthera/Chiika/docs/streaming.md')
