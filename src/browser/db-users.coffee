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
_       = require 'lodash'
{InvalidParameterException} = require './exceptions'

module.exports = class DbUsers extends IDb
  constructor: (params={}) ->
    @name = 'Users'
    super { dbName: @name, promises:params.promises }


  getUser: (userName,callback) ->
    onAll = (data) ->
      user = null
      _.forEach data, (v,k) =>
        _.forOwn v, (vv,kk) =>
          if kk == userName
            user = v
            return false
      if user?
        user = user[userName]
        callback user

    @all(onAll)
  #
  # Adds user into the database.
  # Will check if the parameter use already exists in the database
  # If it exists it will cancel the operation.
  # @param [Object] user User object
  # @option user [String] userName Name of the user
  # @option user [String] password Password of the user
  # @option user [Boolean] isPrimary When set, this user will be primary.
  addUser: (user,callback) ->
    #Check if this user exists
    # onRetrieveDb = (data) =>
    #   userExists = false
    #   _.forEach data,(v,k) =>
    #     if v.userName == user.userName
    #       userExists = true
    #
    #   if userExists
    #     chiika.logger.warn "The user ( #{user.userName} )you're trying to add already exists."
    #   else
    #     @insertRecord user,=>
    #       callback user

    @insertRecordWithoutKey user,=>
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
  updateUser: (user,callback) ->
    #Callback of update operation
    onUpdateComplete = (result) ->
      callback()


    #Call the base class's update method, which will talk to the actual db object
    @updateRecords user,onUpdateComplete,1

  removeUser: (user,callback) ->
    onUpdateComplete = (result) ->
      callback()



    @removeRecords user,onUpdateComplete,1
