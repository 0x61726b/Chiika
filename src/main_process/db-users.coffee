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

IDb                     = require './db-interface'
_find                   = require 'lodash/collection/find'
_indexOf                = require 'lodash/array/indexOf'
_forEach                = require 'lodash.foreach'
_when                   = require('when')

{InvalidParameterException} = require './exceptions'

module.exports = class DbUsers extends IDb
  constructor: (params={}) ->
    @name = 'Users'
    defer = _when.defer()

    params.promises.push defer.promise
    super { dbName: @name, promises:params.promises }

    onAll = (data) =>
      @users = data
      chiika.logger.debug("[yellow](Database) #{@name} loaded. Data Count #{@users.length} ")
      chiika.logger.info("[yellow](Database) #{@name} has been succesfully loaded.")

    loadDatabase = =>
      @all(onAll).then(-> defer.resolve())

    if @isReady()
      loadDatabase()
    else
      @on 'load', =>
        loadDatabase()


  #
  #
  #
  getDefaultUser: (owner) ->
    match = _find @users,(o) -> o.owner == owner

    if match?
      match
    else
      chiika.logger.warn("Default user does not exist.")
      return null


  getUser: (userName) ->
    match = _find @users,{ userName: userName }
    if match?
      return match
    else
      chiika.logger.warn("The user #{userName} you are trying to access doesn't exist.")
    #console.log data

  #
  # Adds user into the database.
  # Will check if the parameter use already exists in the database
  # If it exists it will cancel the operation.
  # @param [Object] user User object
  # @option user [String] userName Name of the user
  # @option user [String] password Password of the user
  # @option user [Boolean] isPrimary When set, this user will be primary.
  # @todo Add parameter validation
  addUser: (user,callback) ->
    @insertRecord user,=>
      @users.push user
      callback? user

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
      callback?()


    #Call the base class's update method, which will talk to the actual db object
    @updateRecords user,onUpdateComplete,1

  #
  # Removes user
  # @param [Object] user
  # @options object [String] userName
  # @param [Object] callback Function which will be called upon update
  # @todo Add parameter validation
  removeUser: (user,callback) ->
    onRemove = =>
      @reload().then =>
        callback?()
    @remove 'userName',user,onRemove

  #
  #
  #
  remove: (key,entry,callback) ->
    @removeRecord(key,entry,callback)


  reload: ->
    new Promise (resolve) =>
      onAll = (data) =>
        @users = data
        chiika.logger.debug("[yellow](Database) #{@name} loaded. Data Count #{@users.length} ")
        chiika.logger.info("[yellow](Database) #{@name} has been succesfully loaded.")
      loadDatabase = =>
        @all(onAll).then =>
          resolve()

      if @isReady()
        loadDatabase()
      else
        @on 'load', =>
          loadDatabase()
