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
_when     = require 'when'
UIItem    = require './ui-item'

{InvalidOperationException,InvalidParameterException} = require './exceptions'


module.exports = class SubView extends UIItem
  constructor: (params={}) ->
    super params

  load: ->
    new Promise (resolve) =>
      onAll = (data) =>
        L = data.length

        if L == 0
          @needUpdate = true
        else
          @setDataSource(data)

        resolve()
      @db.all(onAll)

  getData: ->
    @dataSource

  #
  # Add a single row to the subview
  #
  # @param {Array} data
  # @return
  setData: (data,key) ->
    new Promise (resolve) =>
      if _.isUndefined data
        throw new InvalidParameterException("You didn't specify data to be added.")

      chiika.logger.info("Adding a new row for #{@name}")

      find = _.find @dataSource, (o) -> o[key] == data[key]
      index = _.indexOf @dataSource, find

      if find?
        @dataSource.splice(index,1,data)
      else
        @dataSource.push data

      onSaved = ->
        resolve()
      @db.save data, onSaved
