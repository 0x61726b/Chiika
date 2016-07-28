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



#
# Database that will keep user-defined custom stuff.
#
module.exports = class DbCustom extends IDb
  constructor: (params={}) ->
    @name = 'Custom'
    super { dbName: @name, promises:params.promises }



  getKey: (value,callback) ->
    onOne = (data) ->
      callback data.value
    @one 'name',value,onOne

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
    entries    = [] # Object to be added

    onInsertComplete = (err,count)->
      chiika.logger.verbose "Key added"
      callback()

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
    @updateRecords object,callback

  #
  # Removes a key
  # @param [Object] object The object which will get inserted to the database
  # @options object [String] Key
  # @param [Object] callback Function which will be called upon update
  # @todo Add parameter validation
  removeKey: (object,callback) ->
    @removeRecords object,callback
