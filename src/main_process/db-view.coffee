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

IDb           = require './db-interface'
_             = require 'lodash'
_when         = require('when')

{InvalidParameterException} = require './exceptions'

module.exports = class DbView extends IDb
  viewData: []

  constructor: (params={}) ->
    @name = 'View_' + params.viewName
    defer = _when.defer()
    @promise = defer.promise

    super { dbName: @name,params}

    onAll = (data) =>
      @viewData = data
      chiika.logger.debug("[yellow](Database) #{@name} loaded. Data Count #{@viewData.length} ")
      chiika.logger.info("[yellow](Database) #{@name} has been succesfully loaded.")

      defer.resolve()

    loadDatabase = =>
      @all(onAll)


    if @isReady()
      loadDatabase()
    else
      @on 'load', =>
        loadDatabase()


  load: ->
    new Promise (resolve) =>
      onAll = (data) =>
        @viewData = data
        resolve(data)

      loadDatabase = =>
        @all(onAll)


      if @isReady()
        loadDatabase()
      else
        @on 'load', =>
          loadDatabase()

  #
  # Adds user into the database.
  # Will check if the parameter use already exists in the database
  # If it exists it will cancel the operation.
  # @param [Object] user User object
  # @option user [String] userName Name of the user
  # @option user [String] password Password of the user
  # @option user [Boolean] isPrimary When set, this user will be primary.
  # @todo Add parameter validation
  save: (data,callback) ->
    saveData = (data) =>
      @insertRecord data, (result) =>
        #If it exists already,it won't insert, so update
        if result.exists
          @updateRecords data, (args) =>
            if !_.isUndefined callback
              callback?(args)
        else
          callback?( {rows: 1 })


    if !@isReady()
      @on 'load', =>
        saveData(data)
    else
      saveData(data)
    #@insertRecordWithKey user,callback
