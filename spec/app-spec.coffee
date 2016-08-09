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


describe 'General app tests', ->
  setup = new GlobalSetup()
  setup.setupTimeout(this)

  app = null

  #afterEach =>
    #setup.prettyPrintMainProcessLogs(app.client)

  after =>
    app = null


  #
  # Two windows are loading, and login.
  #
  describe 'Dev mode is true,but running in CI environment',->
    before () =>
      setup.removeAppData().then =>
        setup.startApplication({
          args: [setup.chiikaPath()],
          DEV_MODE:true,
          RUNNING_TESTS: true
        })
        .then (startedApp) =>
            app = startedApp

    after =>
      setup.stopApplication(app)

    it 'Dev tools should not open', () =>
      app.client.getWindowCount().should.eventually.equal(2)
      .browserWindow.isDevToolsOpened().should.eventually.be.false


  #
  # Two windows are loading, and login.
  #
  describe 'Dev Mode is false',->
    before () =>
      setup.removeAppData().then =>
        setup.startApplication({
          args: [setup.chiikaPath()],
          DEV_MODE:false,
          RUNNING_TESTS: false
        })
        .then (startedApp) =>
            app = startedApp

    after =>
      setup.stopApplication(app)

    it 'Dev tools should not open', () =>
      app.client.getWindowCount().should.eventually.equal(2)
      .browserWindow.isDevToolsOpened().should.eventually.be.false

  #
  # Two windows are loading, and login.
  #
  describe 'Dev mode is true',->
    before () =>
      setup.removeAppData().then =>
        setup.startApplication({
          args: [setup.chiikaPath()],
          DEV_MODE:true,
          RUNNING_TESTS: false
        })
        .then (startedApp) =>
            app = startedApp

    after =>
      setup.stopApplication(app)

    #
    # 2 + 2
    #
    it 'Dev tools should open', () =>
      app.client.getWindowCount().should.eventually.equal(4).pause(500)
      .browserWindow.isDevToolsOpened().should.eventually.be.true
