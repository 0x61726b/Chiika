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

GlobalSetup               = require './global-setup'
path                      = require 'path'
_                         = require 'lodash'
Logger                    = require './../src/main_process/logger'
APIManager                = require './../src/main_process/api-manager'
SettingsManager           = require './../src/main_process/settings-manager'
Utility                   = require './../src/main_process/utility'
rimraf                    = require 'rimraf'
fs                        = require 'fs-extra'
chai                      = require 'chai'
expect                    = chai.expect



describe 'Script Compiler and API Manager', ->
  setup = new GlobalSetup()
  utility = new Utility()

  scriptsPath = path.join(__dirname,'..','scripts')


  #
  # Api Manager depends on global chiika object
  global.chiika = {
    utility: utility
    runningTests: true
    scriptsPaths: [path.join(__dirname,"scripts")]
    getAppHome: ->
      setup.getAppHome()
    getDbHome: ->
      setup.getDbHome()
  }
  chiika.logger = new Logger("verbose").logger

  describe "Active scripts and disabled scripts", ->
    apiManager = null
    settings   = null

    beforeEach =>
      apiManager = new APIManager()
      settings   = new SettingsManager()

      apiManager.scriptsDirs = [ path.join(__dirname,'scripts') ]

      apiManager.clearScripts()
      setup.removeAppData()

    this.timeout(5000)

    getScriptCountSync = ->
      count = 0
      for scriptDir in apiManager.scriptsDirs
        files = fs.readdirSync scriptDir
        count += files.length
      count

    after =>
      new Promise (resolve) =>
        apiManager.clearCache().then =>
          apiManager = null
          settings = null
          resolve()


    it 'getScriptByName returns undefined for non-existent scripts', ->
      settings.initialize().then =>
        apiManager.preCompile().then =>
          expect(apiManager.getScriptByName('chitoge')).to.equal(undefined)


    it 'inactive scripts will not be used', ->
      scriptCount = getScriptCountSync()
      settings.initialize().then =>
        apiManager.preCompile().then =>
          activeScripts = apiManager.activeScripts
          activeScripts.length.should.be.equal(1)

    it 'scripts with underscore will be discarded', () ->
      scriptCount = getScriptCountSync()
      settings.initialize().then =>
        apiManager.preCompile().then =>
          scripts = apiManager.compiledScripts
          activeScripts = apiManager.activeScripts

          scripts.length.should.be.equal(scriptCount - 1)
