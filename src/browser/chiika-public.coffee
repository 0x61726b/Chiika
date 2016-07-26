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
{Emitter} = require 'event-kit'

module.exports = class ChiikaPublicApi
  emitter: null
  constructor: (params={})->
    @emitter             = new Emitter
    {@logger, @db}       = params
    @users               = @db.usersDb
    @custom              = @db.customDb
  on: (message,args...) ->
    @emitter.on message,args...
  emit: (message) ->
    @emitter.emit message
