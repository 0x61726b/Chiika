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
View    = require './view'

{InvalidOperationException,InvalidParameterException} = require './exceptions'


module.exports = class TabView extends View
  constructor: (params={}) ->
    super params

  loadData: (data) ->
    @dataSource = data

  getData: ->
    data = []

    _.forEach @dataSource, (tab) =>
      _.forEach tab.data, (entry) =>
        data.push entry
    data

  getRawData: ->
    @dataSource

  #
  # Update a single element in any of the tabs
  #
  setDataSingle: (data,key) ->
    new Promise (resolve) =>
      if _.isUndefined data
        throw new InvalidParameterException("You didn't specify data to be added.")

      chiika.logger.info("Setting data for #{@name}")

      _.forEach @dataSource, (tab) =>
        # if tab.name == updatedTab
        onSaved = ->
          resolve()
        chiika.logger.info("Updating tab data #{tab.name}")
        @db.save(tab,onSaved)

      # updated = false
      # updatedTab = ""
      #
      # _.forEach @dataSource, (tab) =>
      #   find = _.find tab.data, (o) -> o[key] == data[key]
      #   index = _.indexOf tab.data, find
      #
      #   if index != -1
      #     tab.data.splice(index,1,data)
      #     chiika.logger.info("Existing row found for #{@name} at #{tab.name} - #{index}")
      #     updated = true
      #     updatedTab = tab.name
      #     return false
      #
      #
      # if updated


  #
  #
  #
  # @param {Array} data
  # @return
  setData: (data) ->
    new Promise (resolve) =>
      if _.isUndefined data
        throw new InvalidParameterException("You didn't specify data to be added.")

      @dataSource = []
      async = []
      _.forEach data, (v,k) =>
        @dataSource.push v

        deferSave = _when.defer()
        async.push deferSave.promise
        onSaved = ->
          deferSave.resolve()

        @db.save(v,onSaved)
      _when.all(async).then(resolve)
