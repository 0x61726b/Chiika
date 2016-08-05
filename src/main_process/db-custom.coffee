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

IDb     = require './db-interface'
{InvalidParameterException} = require './exceptions'
_       = require 'lodash'
_when   = require 'when'


#
# Database that will keep user-defined custom stuff.
#
module.exports = class DbCustom extends IDb
  constructor: (params={}) ->
    @name = 'Custom'
    defer = _when.defer()

    params.promises.push defer.promise
    super { dbName: @name, promises:params.promises }

    onAll = (data) =>
      @keys = data
      chiika.logger.debug("[yellow](Database) #{@name} loaded. Data Count #{@keys.length} ")
      chiika.logger.info("[yellow](Database) #{@name} has been succesfully loaded.")

    loadDatabase = =>
      @all(onAll).then(-> defer.resolve())

    if @isReady()
      loadDatabase()
    else
      @on 'load', =>
        loadDatabase()


  getKey: (name) ->
    match = _.find @keys,{ name: name }
    if _.isUndefined match
      chiika.logger.warn("The key #{name} you are trying to access doesn't exist.")
      undefined
    else
      match

  #
  # Adds a key into the database.
  # Will check if the parameter use already exists in the database
  # If it exists it will cancel the operation.
  # Example Usage
  #   @example addKey { name: 'mykey', value: { myvalue:'15', myArray:[1,2,3]}}
  # @param [Object] user Object
  # @option object [String] name
  # @option object [String] value
  # @param [Object] callback Function which will be called upon insert
  # @todo Add parameter validation
  addKey: (object,callback) ->
    onInsertOrUpdate = (insert,update) =>
      if insert? # Insert
        @keys.push object
      if update?
        findItem = _.find @keys, (o) -> o.name == object.name
        index = _.indexOf @keys,findItem
        if findItem?
          @keys.splice(index,1,findItem)
        else
          chiika.logger.error("There was an update op but the local array doesn't have the entry.")
      callback?()

    onInsertComplete = (result) =>
      if result.exists
        @updateRecords object,=>
          onInsertOrUpdate?(null,true)
      else
        onInsertOrUpdate?(true,null)

    @insertRecord object,onInsertComplete

  #
  # Updates a row or rows where key==value
  # The 'name' value is the key and it must match in database
  # Example Usage
  #   @example updateKeys { name: 'mykey', value: { myvalue:'15', myArray:[1,2,3]}}
  #
  # @param [Object] user Object
  # @option object [String] name
  # @option object [String] value
  # @param [Object] callback Function which will be called upon insert
  # @todo Add parameter validation
  updateKeys: (object,callback) ->
    if !_.isUndefined callback
      @updateRecords object,callback
    else
      @updateRecords object,->

  #
  # Removes a key
  # @param [Object] object The object which will get inserted to the database
  # @options object [String] Key
  # @param [Object] callback Function which will be called upon update
  # @todo Add parameter validation
  removeKey: (object,callback) ->
    @removeRecords object,callback
