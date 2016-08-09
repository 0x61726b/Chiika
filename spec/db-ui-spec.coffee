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
#
# mkdirp              = require 'mkdirp'
# rimraf              = require 'rimraf'
# _                   = require 'lodash'
# _when               = require 'when'
#
# DbUI = require process.cwd() + '/src/main_process/db-ui'
#
# Logger          = require process.cwd() + '/src/main_process/logger'
#
# global.chiika = {
#   logger: new Logger("verbose").logger
#   getAppHome: ->
#     process.cwd() + "/testOutput"
#   getDbHome: ->
#     process.cwd() + "/testOutput"
# }
#
#
# createTestOutputFolder = ->
#   defer = _when.defer()
#   mkdirp chiika.getDbHome(), ->
#     defer.resolve()
#
#   defer.promise
#
# removeTestOutputFolder = ->
#   defer = _when.defer()
#
#   rimraf chiika.getDbHome(), ->
#     defer.resolve()
#
#   defer.promise
#
# describe 'UI Database addUIItem', ->
#   dbUI = null
#
#   loadDatabase = ->
#     new Promise (resolve) =>
#       if dbUI?
#         resolve()
#         return
#       promises = []
#
#       dbUI = new DbUI { promises: promises }
#       createTestOutputFolder().then =>
#         _when.all(promises).then =>
#           console.log "UI loaded"
#           resolve()
#
#   beforeEach (done) =>
#     loadDatabase().then =>
#       done()
#       baka = 42
#
#   afterEach (done) =>
#     removeTestOutputFolder().then =>
#       dbUI = null
#       done()
#       baka = 42
#
#   onComplete = (done) ->
#     done()
#     baka = 42
#
#   it 'Get UI item Sync', (done) ->
#     dbUI.addOrUpdate { name: 'animeList', displayName: 'Anime List', displayType: 'TabGridView', TabGridView: {} }, (error) ->
#       if error
#         throw error
  #
  #     uiItem = dbUI.getUIItemSync('animeList')
  #
  #     expect(uiItem.name).toBe('animeList')
  #     done()
  #     baka = 42
  #
  # it 'Get UI items ASync', (done) ->
  #   dbUI.addOrUpdate { name: 'animeList', displayName: 'Anime List', displayType: 'TabGridView', TabGridView: {} }, (error) ->
  #     if error
  #       throw error
  #
  #     animeList = dbUI.getUIItemSync 'animeList'
  #     expect(animeList.name).toBe('animeList')
  #     done()
  #     baka = 42
  #
  #
  # it 'Adding and querying a UI item Sync', (done) ->
  #     dbUI.addOrUpdate { name: 'test',displayName:'Test Display',displayType:'TabGridView', someArray: [], TabGridView: { baka: 'nano', chitoge:'best',girl:'rem',greaterThan: 'emilia' } }, (error) ->
  #       if error
  #         throw error
  #       item = dbUI.getUIItemSync 'test'
  #       expect(typeof item).toBe('object')
  #       expect(_.size(item)).toBe(5)
  #       expect(item.name).toBe('test')
  #       expect(item.someArray.length).toBe(0)
  #       onComplete(done)
  #
  # #addUIItem should return an error.
  # it 'Trying to add item without a name key', (done) ->
  #   dbUI.addOrUpdate { hue: 'hue',huheuhue:'huehuehe',memes: true }, (error) ->
  #     if error
  #       onComplete(done)
  #
  # it 'Trying to add an item without item[displayType] property', (done) ->
  #   #No TabGridView property should fail
  #   dbUI.addOrUpdate { name: 'animeList', displayName: 'Anime List', displayType: 'TabGridView' }, (error) ->
  #     if error
  #       onComplete(done)
  # #
  # it 'Trying to call addOrUpdate on the same UI item twice first should add then update it', (done) ->
  #   dbUI.addOrUpdate { name: 'animeList', displayName: 'Anime List', displayType: 'TabGridView', TabGridView: {} }, (error) ->
  #     if error
  #       throw error
  #
  #     item = dbUI.getUIItemSync 'animeList'
  #     expect(_.size(item)).toBe(4)
  #     expect(item.name).toBe('animeList')
  #     expect(item.displayName).toBe('Anime List')
  #
  #     #Update the item
  #     item.displayName = 'Updated Anime List'
  #     item.newProperty = "FeelsAmazingMan"
  #
  #     dbUI.addOrUpdate item, (error) ->
  #       if error
  #         throw error
  #
  #       newItem = dbUI.getUIItemSync 'animeList'
  #       expect(_.size(item)).toBe(5)
  #       expect(item.name).toBe('animeList')
  #       expect(item.displayName).toBe('Updated Anime List')
  #
  #       onComplete(done)
