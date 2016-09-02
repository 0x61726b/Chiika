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
{Emitter}                                 = require 'event-kit'
{ipcRenderer,remote,shell}                = require 'electron'
remote                                    = require('electron').remote
{Menu,MenuItem}                           = require('electron').remote

_when                                     = require 'when'
Logger                                    = require './main_process/logger'
_find                                     = require 'lodash/collection/find'
_indexOf                                  = require 'lodash/array/indexOf'
_forEach                                  = require 'lodash.foreach'

module.exports = class ListManager
  deleteFromList: (callback) ->
    chiika.notificationManager.deleteFromListConfirmation =>
      chiika.toastLoading('Deleting..','infinite')
      onDeleteReturn = (params) =>
        if params.args.success
          chiika.toastSuccess('Deleted!',2000)
          callback(params.args)
        else
          chiika.toastError("Could not delete. #{params.args.response}",2000)
      @listAction('delete-entry', null, onDeleteReturn)


  listAction: (action,params,callback) ->
    chiika.ipc.sendMessage 'list-action', { action: action, params: params, return: callback }

    chiika.ipc.receive "list-action-response-#{action}",(event,args) =>
      callback(args)

      chiika.ipc.disposeListeners("list-action-response-#{action}")
