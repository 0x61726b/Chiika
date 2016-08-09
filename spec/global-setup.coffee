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
{Application}           = require 'spectron'
assert                = require 'assert'
chai                  = require 'chai'
chaiAsPromised        = require 'chai-as-promised'
path                  = require 'path'
os                    = require 'os'
rimraf                = require 'rimraf'
_                     = require 'lodash'

global.before =>
  chai.should()
  chai.use(chaiAsPromised)

module.exports = class Setup
  getElectronPath: ->
    electronPath = path.join(__dirname, '..', 'node_modules','.bin','electron')
    if (process.platform == 'win32')
      electronPath += '.cmd'
    electronPath

  getDataPath: ->
    if process.env.CHHIKA_HOME?
      process.env.CHIIKA_HOME
    else
      osSpecificDir = process.env.APPDATA || (process.platform == 'darwin' ? process.env.HOME + 'Library/Preferences' : process.env.HOME + '.config')
      process.env.CHIIKA_HOME = path.join(osSpecificDir,"chiika","data")
      process.env.CHIIKA_HOME

  chiikaPath: ->
    path.join(__dirname, '..')


  removeAppData: ->
    new Promise (resolve) =>
      rimraf @getDataPath(), resolve

  setupTimeout: (test) ->
    if (process.env.CI)
      test.timeout(100000)
    else
      test.timeout(20000)

  startApplication: (options) ->
    options.path = @getElectronPath()


    options.env = Object.create(process.env)

    if (process.env.CI)
      options.env.CI_MODE = true
      options.startTimeout = 100000
    else
      options.startTimeout = 10000
      options.env.CI_MODE = false

    if options.DEV_MODE?
      options.env.DEV_MODE = options.DEV_MODE
    else
      options.env.DEV_MODE = true

    if options.RUNNING_TESTS?
      options.env.RUNNING_TESTS = options.RUNNING_TESTS
    else
      options.env.RUNNING_TESTS = true

    app = new Application(options)

    app.start().then =>
      console.log "Hello?"
      assert.equal(app.isRunning(), true)
      chaiAsPromised.transferPromiseness = app.transferPromiseness
      app

  prettyPrintMainProcessLogs: (client) ->
    client.getMainProcessLogs().then (logs) =>
      _.forEach logs, (v,k) =>
        console.log v

  prettyPrintRendererProcessLogs: (client) ->
    client.getRendererProcessLogs().then (logs) =>
      _.forEach logs, (v,k) =>
        console.log v

  stopApplication:(app) ->
    if (!app || !app.isRunning())
      return

    console.log "Stopping"
    app.stop()
