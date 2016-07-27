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
  constructor: (params={}) ->
    @name = 'View_' + params.viewName
    defer = _when.defer()
    @promise = defer.promise

    super { dbName: @name,params}

    onAll = (data) =>
      @views = data
      chiika.logger.debug("[yellow](Database) #{@name} loaded. Data Count #{@views.length} ")
      chiika.logger.info("[yellow](Database) #{@name} has been succesfully loaded.")

      defer.resolve()

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
    if !@isReady()
      @on 'load', =>
        @insertRecord data,=>
          if !_.isUndefined callback
            callback user
    else
      @insertRecord data,=>
        if !_.isUndefined callback
          callback user
    #@insertRecordWithKey user,callback

  #
  # Updates the user
  # @param [Object] user User object
  # @param [Object] user User object
  # @option user [String] userName Name of the user
  # @option user [String] password Password of the user
  # @option user [Boolean] isPrimary When set, this user will be primary.
  # @param [Object] callback Function which will be called upon update
  # @todo Add parameter validation
  updateUser: (user,callback) ->
    #Callback of update operation
    onUpdateComplete = (result) ->
      if !_.isUndefined callback
        callback()


    #Call the base class's update method, which will talk to the actual db object
    @updateRecords user,onUpdateComplete,1

  #
  # Removes user
  # @param [Object] user
  # @options object [String] userName
  # @param [Object] callback Function which will be called upon update
  # @todo Add parameter validation
  removeUser: (user,callback) ->
    onUpdateComplete = (result) ->
      if !_.isUndefined callback
        callback()



    @removeRecords user,onUpdateComplete,1
