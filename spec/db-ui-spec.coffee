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

mkdirp              = require 'mkdirp'
rimraf              = require 'rimraf'
_                   = require 'lodash'
_when               = require 'when'

DbUI = require process.cwd() + '/src/main_process/db-ui'

Logger          = require process.cwd() + '/src/main_process/logger'

global.chiika = {
  logger: new Logger("verbose").logger
  getAppHome: ->
    process.cwd() + "/testOutput"
  getDbHome: ->
    process.cwd() + "/testOutput"
}


createTestOutputFolder = ->
  defer = _when.defer()
  mkdirp chiika.getDbHome(), ->
    defer.resolve()

  defer.promise

removeTestOutputFolder = ->
  defer = _when.defer()

  rimraf chiika.getDbHome(), ->
    defer.resolve()

  defer.promise


describe 'UI Database addUIItem', ->
  promises = []

  dbUI = new DbUI { promises: promises }

  it 'addItem getUIItem', (done) ->
    createTestOutputFolder().then =>
      dbUI.addUIItem { name: 'test', someArray: [], someCrazyUiParams: { baka: 'nano', chitoge:'best',girl:'rem',greaterThan: 'emilia' } }, ->


        dbUI.getUIItem 'test', (item) ->
          expect(typeof item).toBe('object')
          expect(item.name).toBe('test')
          expect(item.someArray.length).toBe(0)
          done()
