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


describe 'Application Window Control', ->
  setup = new GlobalSetup()
  setup.setupTimeout(this)

  beforeEach () =>
    setup.removeAppData()

  runApp = =>
    new Promise (resolve) =>
      setup.startApplication({
        args: [path.join(__dirname, '..')]})
      .then (startedApp) =>
          resolve(startedApp)

  stopApp = (app) =>
    setup.stopApplication(app)

  #
  describe 'No AppData First Launch',->
    this.timeout(30000)
    #
    # Loading window + login window
    #
    xit 'Should launch login window', () =>
        runApp().then (app) =>
          app.client
          .waitUntilWindowLoaded()
          .getWindowCount().should.eventually.equal(1)
          .windowByIndex(0)
          .browserWindow.getTitle().should.eventually.be.equal('login')
          .browserWindow.isVisible().should.eventually.be.true
          .then =>
            stopApp(app)

  #
  describe 'Data exists but there is no user',->
    this.timeout(30000)
    #
    # Loading window + login window
    #
    xit 'Should launch login window', () =>
      setup.copyTestData('data_without_user').then =>
        runApp().then (app) =>
          app.client
          .waitUntilWindowLoaded()
          .getWindowCount().should.eventually.equal(1)
          .windowByIndex(0)
          .browserWindow.getTitle().should.eventually.be.equal('login')
          .browserWindow.isVisible().should.eventually.be.true
          .then =>
            stopApp(app)

  describe 'Data exists and there is at least one user', ->
    this.timeout(30000)

    it 'Should launch main window', ->
      setup.copyTestData('data_with_user').then =>
        runApp().then (app) =>
          app.client
          .waitUntilWindowLoaded()
          .getWindowCount().should.eventually.equal(1)
          .then =>
            stopApp(app)
            #setup.prettyPrintMainProcessLogs(app.client)



        #  app.client.getWindowCount().should.eventually.equal(2)
        #  .pause(2000)
        #  .then =>
        #    app.client.getMainProcessLogs().then (logs) =>
        #      _.forEach logs, (v,k) =>
        #        console.log v
       # .browserWindow.isMinimized().should.eventually.be.false
       # .browserWindow.isDevToolsOpened().should.eventually.be.false
       # .browserWindow.isVisible().should.eventually.be.true
       # .browserWindow.isFocused().should.eventually.be.true
       # .browserWindow.getBounds().should.eventually.have.property('width').and.be.above(0)
       # .browserWindow.getBounds().should.eventually.have.property('height').and.be.above(0)
