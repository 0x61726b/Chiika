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
NoSQL     = require 'NoSQL'
path      = require 'path'
_         = require 'lodash'
_when     = require 'when'
{Emitter} = require 'event-kit'
{InvalidParameterException} = require './exceptions'

module.exports = class IDb
  nosql: null
  promise: null

  # Constructor
  # @param {Object} parameters
  # @option params {String} dbName name of the database
  # @option params {Object} promises The promise array. The purpose of this is each db will call a resolve when they're loaded, thus usable.
  # @return
  constructor: (params={}) ->
    { @dbName, promises } = params
    defer = _when.defer()
    @promise = defer.promise
    promises.push @promise

    @dbPhysicalPath = path.join(application.getAppHome(),"Data","dbs",@dbName + ".nosql")
    @nosql = NoSQL.load(path.join(application.getAppHome(),"Data","dbs",@dbName + ".nosql"))
    chiika.logger.debug "IDb::constructor {dbName:#{@dbName}}"
    chiika.logger.debug "Idb::constructor {dbPhysicalPath:#{@dbPhysicalPath}}"

    @on 'load', -> defer.resolve()


  ##
  # Returns the whole database
  # @param {callback} callback callback that will receive the database object
  # @return
  all: (callback) ->
    chiika.logger.debug("IDb::all")
    map = (doc) ->
      doc

    icall = (err,selected) ->
      if err
        throw err
      callback selected
    @nosql.all map,icall


  one: (key,value,callback) ->
    chiika.logger.debug("IDb::one")

    map = (doc) ->
      if doc[key] == value
        return doc
    onOne = (err,doc) ->
      if err
        throw err
      chiika.logger.debug("Idb::onOne")
      callback doc
    @nosql.one(map,onOne)

  ##
  # Internal insert record method
  _insertRecord: (record,callback) ->
    onInsert = (err,count) ->
      if err
        throw err
      chiika.logger.debug("Idb::onInsertComplete #{count}")
      callback(err,count)
    @nosql.insert record, callback,'IDb::insertRecord'

    chiika.logger.debug("IDb::_insertRecord")

  # Insert a single record
  # No duplicate check
  # beware using this
  insertRecord: (record,callback) ->
    chiika.logger.debug("IDb::insertRecord")

    @_insertRecord record,callback

  #When inserting this method checks for if one of the recrods contains 'key' with the same value from record.key , it will cancel the insert op.
  # @param {Object} record
  # @option record [String] userName
  # @option record [String] password
  # @option record [Boolean] isPrimary
  # @option key [String] key String must be a property of record
  # @return
  insertRecordWithKey: (record,callback) ->
    chiika.logger.debug("IDb::insertRecordWithKey")

    if _.isArray record
      _.forEach record, (v,k) =>
        keys = Object.keys(v)
        key = keys[0]

        onKeyExistsCheck = (exists) =>
          if !exists.exists
            @_insertRecord v,callback
          else
            chiika.logger.verbose("Key already exists '#{key}' . No need to insert, if you meant to update, use update method.")
        @checkIfKeyExists v,onKeyExistsCheck


    else
      keys = Object.keys(record)
      key = keys[0]

      onKeyExistsCheck = (exists) =>
        if !exists.exists
          @_insertRecord record,callback
        else
          chiika.logger.verbose("Key already exists '#{key}' . No need to insert, if you meant to update, use update method.")
      @checkIfKeyExists record,onKeyExistsCheck





  insertRecordWithoutKey: (record,callback) ->
    chiika.logger.debug("Idb::insertRecordWithoutKey")

    if _.isArray record
      _.forEach record, (v,k) =>
        keys = Object.keys(v)
        key = keys[0]

        #Check if the value exists
        onKeyExistsCheck = (exists) =>
          if !exists.exists
            console.log "Doesnt exists"
          else
            console.log "Exists"
        @checkIfKeyValueExists(v,onKeyExistsCheck)
    else
      keys = Object.keys(record)
      key = keys[0]

      #Check if the value exists
      onKeyExistsCheck = (exists) =>
        if !exists.exists
          @_insertRecord record,callback
          chiika.logger.verbose("Added new record #{key}:#{record[key]}")
        else
          chiika.logger.verbose("Key-value already exists #{key}:#{record[key]}. No need to insert, if you meant to update, use update method.")
      @checkIfKeyValueExists(record,onKeyExistsCheck)




  #
  # Updates record/records
  # @param {Object} record Record Object
  # @param {String} key String that is a property that is significant to the object
  # @param {Object} callback Function that will be called when the update completes
  # @param [Integeer] mode There are 2 modes in the database structure. if the mode is 0 , all methods look for a structure like this key: { prop:propvalue },otherwise it will look for { key: value, prop: propvalue }
  # @return
  updateRecords: (record,callback) ->
    chiika.logger.debug("IDb::updateRecord")
    affectedRows = 0
    #This function runs for every row in database !!
    updateFnc = (doc) ->
      key = Object.keys(doc)[0]
      if _.isArray record
        #Find this 'doc' if its on the record array
        findObj = {}
        findObj[key] = doc[key]
        match = _.find record,findObj

        if !_.isUndefined match
          doc = match
          affectedRows++
          chiika.logger.verbose("Updated record with #{key}:#{doc[key]}")
      else
        if key == Object.keys(record)[0] && record[key] == doc[key]
          doc = record
          chiika.logger.verbose("Updated record with #{key}:#{doc[key]}")
      return doc

    updateCallback = =>
      if _.isArray record
        keyExistsCallback = (result) ->
          if !result.exists
            chiika.logger.warn("You are trying to update a key <#{result.key}> that's not in the database.")
        record.map( (key,i) => @checkIfKeyValueExists(key,keyExistsCallback) )

      callback { rows: affectedRows }

    @nosql.prepare(updateFnc, updateCallback, 'IDb::updateRecord')

    @nosql.update()
    #@nosql.update( updateCallback, callback, 'IDb::updateRecord')
    chiika.logger.debug("IDb::updateRecord")
  removeRecords: (record,callback) ->
    chiika.logger.debug("IDb::removeRecord")

    #Called for every row
    removeFnc = (doc) ->
      key = Object.keys(doc)[0]
      removeThisRecord = false
      if !_.isArray record
        throw new InvalidParameterException("You have to supply array of keys.")
      else
        _.forEach record, (o) ->
          firstKey = Object.keys(o)[0]
          if firstKey == key && o[key] == doc[key]
            removeThisRecord = true
            return false
      removeThisRecord

    removeCallback = (err,count) ->
      chiika.logger.verbose("Removed keys - #{count}")

    @nosql.remove removeFnc,removeCallback,"Remove records"
  checkIfKeyExists: (key,callback) ->
    onAll = (data) =>
      exists = false
      _.forEach data, (v,k) =>
        #Assume the first property is the key
        if Object.keys(v)[0] == Object.keys(key)[0]
          exists = true
          return false
      callback { exists: exists, key: Object.keys(key)[0] }
    @all(onAll)


  checkIfKeyValueExists: (key,callback) ->
    onAll = (data) =>
      exists = false

      _.forEach data, (v,k) =>
        firstKey = Object.keys(v)[0]
        if firstKey == Object.keys(key)[0] && v[firstKey] == key[firstKey]
          exists = true
          return false
      callback { exists: exists }
    @all(onAll)


  on: (event,args...) ->
    @nosql.on(event,args...)

  ##
  # Status of the database
  # @return {Boolean}
  isReady: ->
    @nosql.isReady
