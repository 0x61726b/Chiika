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

_         = require 'lodash'

module.exports = class UIItem
  name: null
  displayName: null
  dataSource: []
  db: null
  displayType: null
  needUpdate: false
  children: []
  constructor: (params={}) ->
    { @name, @displayName,@displayType } = params

  addChild: (child) ->
    if child?
      @children.push child

  setDatabaseInterface: (db) ->
    @db = db

  update: ->
    chiika.logger.info("Updating UIItem #{@name}")
    if @needUpdate
      chiika.chiikaApi.emit 'view-update',this
      @needUpdate = false


  setDataSource: (data) ->
    if _.isUndefined data
      chiika.logger.warn("[magenta](#{@name}) - Undefined data source!")
    if !_.isArray data
      chiika.logger.error("[magenta](#{@name}) - Non-array data source!")
      return

    chiika.logger.verbose("Setting data source for UI item #{@name}. Data Array Length: #{data.length}")
    @dataSource = data
