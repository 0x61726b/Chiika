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
#Date: 12.2.2016
#authors: arkenthera
#Description:
#----------------------------------------------------------------------------
electron = require 'electron'
ipc = electron.ipcRenderer
remote = require 'remote'

{Disposable} = require 'event-kit'

module.exports =
  class ApplicationDelegate
    requestAnimeDetails:(id) ->
      ipc.send 'request-anime-details',id

    requestRefreshAnimeDetails:(id) ->
      ipc.send 'request-anime-refresh',id

    handleEvents: ->
      ipc.on 'db-update-animelist', (event,arg) ->
        chiika.dbAnimelist = arg
        chiika.routeManager.refreshGrid()

      ipc.on 'db-update-mangalist', (event,arg) ->
        chiika.dbMangalist = arg

        chiika.routeManager.refreshGrid()

      ipc.on 'db-update-userinfo', (event,arg) ->
        chiika.localUserInfo = arg
        chiika.setSidebarInfo()

      ipc.on 'db-update-app-options', (event,arg) ->
        chiika.appOptions = arg #Fix
        chiika.setSidebarInfo()

      ipc.on 'set-api-busy', (event,arg) ->
        chiika.setApiBusy arg

      ipc.on 'db-update-image-downloaded', (event,arg) ->
        chiika.chiika.onRequestComplete 'refreshImage'

      ipc.on 'db-update-user-image-downloaded', (event,arg) ->
        chiika.setSidebarInfo()

      ipc.on 'db-update-anime', (event,arg) ->
        chiika.chiika.dbUpdateAnime arg
        chiika.chiika.onRequestComplete 'refreshMinorInfo'

      ipc.on 'chiika-fs-ready',(event,arg) ->
        chiika.debug "Chiika-Fs is ready"
        chiika.setApiBusy false

        new Disposable =>
          ipc.removeListener 'chiika-fs-ready'



      ipc.on 'request-anime-details', (event,arg) ->
        chiika.chiika.notifyRequestListeners()
        console.log "kehkeh"
      ipc.on 'set-status-bar-text', (event,arg) ->
        chiika.setStatusText(arg.message,arg.fadeOut)
