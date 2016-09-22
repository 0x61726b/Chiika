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

path            = require 'path'

DbUsers         = require './db-users'
DbCustom        = require './db-custom'
DbUI            = require './db-ui'
DbView          = require './db-view'

{Emitter}       = require 'event-kit'

_find           = require 'lodash/collection/find'
_when           = require 'when'

module.exports = class DatabaseManager
  usersDb: null
  emitter: null
  promises: []
  instances: []
  constructor: ->
    @emitter = new Emitter
    global.dbManager = this



    #Preload databases
    @usersDb      = new DbUsers { @promises }
    @customDb     = new DbCustom { @promises }
    @uiDb         = new DbUI { @promises }

  onLoad: (callback) ->
    console.log @promises
    _when.all(@promises)

  # @todo Make it so that this returns same instance with same view name
  createViewDb: (viewName) ->
    instance = _find @instances, { viewName: viewName }
    if instance?
      chiika.logger.info("[magenta](Database-Manager) Returning existing database instance for view #{viewName}")
      return instance
    else
      chiika.logger.info("[magenta](Database-Manager) Loading new database instance for view #{viewName}")
      dbView = new DbView { viewName: viewName }
      @instances.push { viewName: viewName,instance: dbView }
      return dbView

  emit: (message) ->
    @emitter.emit message


  on: (message,args...) ->
    @emitter.on message,args...
