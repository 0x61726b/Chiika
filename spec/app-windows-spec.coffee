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

  beforeEach (done) =>
    setup.removeAppData().then =>
      done()
    return

  runApp = =>
    new Promise (resolve) =>
      setup.startApplication({
        args: [setup.chiikaPath()]
      .then (startedApp) =>
          resolve(startedApp)

  stopApp = (app) =>
    setup.stopApplication(app)

  #
  describe 'No AppData First Launch',->
    #
    # Loading window + login window
    #
    it 'Should launch login window', () =>
        runApp().then (app) =>
          app.client
          .waitUntilWindowLoaded()
          .then =>
            stopApp(app)

  #
  describe 'Data exists but there is no user',->
    #
    # Loading window + login window
    #
    it 'Should launch login window', () =>
      setup.copyTestData('data_without_user').then =>
        runApp().then (app) =>
          app.client
          .waitUntilWindowLoaded()
          .getWindowCount().should.eventually.equal(1)
          .browserWindow.getTitle().should.eventually.be.equal('login')
          .browserWindow.isVisible().should.eventually.be.true
          .then =>
            stopApp(app)

  describe 'Data exists and there is at least one user', ->

    it 'Should launch main window', ->
      setup.copyTestData('data_with_user').then =>
        runApp().then (app) =>
          app.client
          .waitUntilWindowLoaded()
          .getWindowCount().should.eventually.equal(1)
          .browserWindow.getTitle().should.eventually.be.equal('main')
          .then =>
            stopApp(app)
