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


_when                   = require 'when'
View                    = require './view'
_find                   = require 'lodash/collection/find'
_indexOf                = require 'lodash/array/indexOf'
_forEach                = require 'lodash.foreach'

{InvalidOperationException,InvalidParameterException} = require './exceptions'


module.exports = class SubView extends View
  constructor: (params={}) ->
    super params


  loadData: (data) ->
    @dataSource = []
    _forEach data, (v,k) =>
      @dataSource.push v


  reload: ->
    new Promise (resolve) =>
      @dataSource = []
      chiika.logger.info("Reloading database of subview #{@name}")
      @db.load().then (data) =>
        @loadData(data)
        chiika.logger.info("Reload success! #{@name}")
        resolve()

  getData: ->
    @dataSource

  setDataArray: (data) ->
    new Promise (resolve) =>
      if !data?
        throw new InvalidParameterException("You didn't specify data to be added.")

      chiika.logger.debug("Setting data for #{@name}")

      @dataSource = data

      for i in [0...@dataSource.length]
        if i == @dataSource.length - 1
          onSaved = (args) =>
            resolve(args)
          @db.save @dataSource[i], onSaved
        else
          @db.save @dataSource[i], null


  #
  # Add a single row to the subview
  #
  # @param {Array} data
  # @return
  setData: (data,key) ->
    new Promise (resolve) =>
      if !data?
        throw new InvalidParameterException("You didn't specify data to be added.")

      chiika.logger.debug("Setting data for #{@name}")

      find = _find @dataSource, (o) -> o[key] == data[key]
      index = _indexOf @dataSource, find

      if find?
        chiika.logger.debug("Existing row found for #{@name}")
        @dataSource.splice(index,1,data)
      else
        chiika.logger.debug("Adding new row for #{@name}")
        @dataSource.push data

      onSaved = (args) =>
        chiika.logger.debug("Save successful for #{@name}")
        resolve(args)
      @db.save data, onSaved
