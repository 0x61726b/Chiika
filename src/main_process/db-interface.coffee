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
NoSQL     = require 'nosql'
path      = require 'path'
_forOwn   = require 'lodash/object/forOwn'
_forEach  = require 'lodash/collection/forEach'
_isArray  = require 'lodash.isarray'
_assign   = require 'lodash.assign'
_when     = require 'when'
colors    = require 'colors'
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
    if promises?
      defer = _when.defer()
      @promise = defer.promise
      promises.push @promise

    @dbPhysicalPath = path.join(chiika.getDbHome(),@dbName + ".nosql")
    @nosql = NoSQL.load(path.join(chiika.getDbHome(),@dbName + ".nosql"))
    chiika.logger.debug "IDb::constructor {dbName:#{@dbName}}"
    chiika.logger.debug "Idb::constructor {dbPhysicalPath:#{@dbPhysicalPath}}"

    @on 'load', ->
      if promises?
        defer.resolve()


  ##
  # Returns the whole database
  # @param {callback} callback callback that will receive the database object
  # @return
  all: (callback) ->
    new Promise (resolve) =>
      chiika.logger.debug("IDb::all")
      map = (doc) ->
        doc

      icall = (err,selected) ->
        if err
          throw err
        callback selected
        resolve selected
      @nosql.all map,icall

  clearDb: (callback) ->
    @nosql.clear(callback)

  ##
  # Returns one row of database where key == value
  # @param {String} key Key
  # @param {String} value Value
  # @param {Object} callback Callback
  # @return
  one: (key,value,callback) ->
    new Promise (resolve) =>
      chiika.logger.debug("IDb::one")

      map = (doc) ->
        if doc[key] == value
          return doc
      onOne = (err,doc) ->
        if err
          throw err
          chiika.logger.error err
        chiika.logger.debug("Idb::onOne")
        resolve(doc)
        #callback doc
      @nosql.one(map,onOne)

  ##
  # Internal insert record method
  internalInsertRecord: (record,callback) ->
    onInsert = (err,count) ->
      if err
        throw err
      callback( { count: count })
      chiika.logger.debug("Idb::onInsertComplete #{count}")
    @nosql.insert record, onInsert,'IDb::insertRecord'

    chiika.logger.debug("IDb::internalInsertRecord")

  #When inserting this method checks for if one of the recrods contains 'key=value'
  # @param {Object} record
  # @param {Object} callback Callback
  # @todo Test array insert
  # @return
  insertRecord: (record,callback) ->
    chiika.logger.debug("Idb::insertRecord")

    keys = Object.keys(record)
    key = keys[0]

    #Check if the value exists
    onKeyExistsCheck = (exists) =>
      if !exists.exists
        @internalInsertRecord record,(rows) =>
          chiika.logger.debug("[magenta](#{@name}) - Added new record #{key}:#{record[key]}")
          callback { exists: exists.exists }
      else
        chiika.logger.debug("[magenta](#{@name}) - Key-value already exists #{key}:#{record[key]}. No need to insert, if you meant to update, use update method.")
        callback { exists: exists.exists }
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
    updateFnc = (doc) =>
      keys = Object.keys(doc)
      keysRecord = Object.keys(record)
      key = Object.keys(doc)[0]

      if key == Object.keys(record)[0] && record[key] == doc[key]
        # _forOwn record,(v,k) =>
        #   doc[k] = v

        # Behold the most advanced updating algorithm ahead
        #doc = record
        # Ok the above doesnt work obviously
        _assign doc,record

        affectedRows++
      doc


    updateCallback = (err,count) =>
      if err
        chiika.logger.error err
        throw err

      if count > 0
        chiika.logger.verbose("[magenta](#{@name}) - Updated - #{count} ")
      callback { rows: count }

    @nosql.update(updateFnc, updateCallback,'IDb::updateRecord')

    #@nosql.update()
    #@nosql.update( updateCallback, callback, 'IDb::updateRecord')
    chiika.logger.debug("IDb::updateRecord")


  #
  # Remove records. Removes rows where key=value and record = [values]
  # Example Usage:
  #   @example removeRecords [ { userName: 'arkenthera' }]
  #   @example revemoRecords [ { name: 'mykey' }]
  # @param record
  # @return
  removeRecord: (key,record,callback) ->
    chiika.logger.debug("IDb::removeRecord")

    #Called for every row
    removeFnc = (doc) ->
      if doc[key] == record[key]
        return true
      return false

    removeCallback = (err,count) ->
      chiika.logger.verbose("[magenta](#{@name}) - Removed keys - #{count}")
      callback?({ count: count })

    @nosql.remove removeFnc,removeCallback,"Remove records"



  #
  # Does a where operation ( where key==value ) then returns the selected rows
  # @param {Object} key The object which holds the key and value
  # @param {Object} callback Callback
  # @return
  checkIfKeyValueExists: (key,callback) ->
    onAll = (data) =>
      exists = false

      _forEach data, (v,k) =>
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
