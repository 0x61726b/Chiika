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


_isArray  = require 'lodash.isarray'
_when     = require 'when'

module.exports = class View
  name: null
  displayName: null
  db: null
  displayType: null
  needUpdate: false
  noUpdate: false
  defaultDataSource: ""
  dataSource: []
  processedDataSource: []
  constructor: (params={}) ->
    { @name, @displayName,@displayType,@owner, @dataSource, @category,@noUpdate,@defaultDataSource } = params

    @needUpdate = false
    @dataSource = []


  setDatabaseInterface: (db) ->
    @db = db

  update: ->
    chiika.logger.info("Updating view #{@name}")

    defer = _when.defer()
    if @needUpdate
      if @owner?
        chiika.chiikaApi.requestViewUpdate(this.name,@owner, () => defer.resolve())
      else
        chiika.logger.error("Can't update a view without owner! #{@name}")
        defer.resolve( { success: false })
      @needUpdate = false
    else
      defer.resolve({ success: true })
    defer.promise



  setDataSource: (data) ->
    if !data?
      chiika.logger.warn("[magenta](#{@name}) - Undefined data source!")
    if !_isArray data
      chiika.logger.error("[magenta](#{@name}) - Non-array data source!")
      return

    chiika.logger.verbose("Setting data source for view #{@name}. Data Array Length: #{data.length}")
    @dataSource = data
