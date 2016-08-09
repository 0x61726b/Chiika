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


describe 'Login window tests', ->
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
  describe 'Open login window',->
    this.timeout(30000)

    setupLogin = (app) ->
      app.client.addCommand 'setUserName', ->
        @execute =>
          document.getElementById('email').value = "chiika_dummyac"


      app.client.addCommand 'setPassword', (test) ->
        @execute =>
          document.getElementById('password').value = "chiika_dummy"


      app.client.addCommand 'setWrongUserName', ->
        @execute =>
          document.getElementById('email').value = "chitogebestgirl"

    beforeEach () =>
      setup.removeAppData().then =>
        setup.startApplication({
          args: [setup.chiikaPath()],
          DEV_MODE:false,
          RUNNING_TESTS: false
        })
        .then (startedApp) =>
            app = startedApp
            setupLogin(app)

    afterEach =>
      setup.stopApplication(app)


    it 'type correct user name and password, click verify', () =>
      app.client.waitUntilWindowLoaded()
         .windowByIndex(0)
         .browserWindow.focus()
         .browserWindow.getTitle().should.eventually.be.equal('login')
         .browserWindow.isFocused().should.eventually.be.true
         .pause(3000)
         .setUserName()
         .setPassword()
         .click("#log-btn")
         .pause(5000)
         .isExisting("input#email.highlightgreen").should.eventually.be.true
         .isExisting("input#password.highlightgreen").should.eventually.be.true

    it 'type wrong user name and password, click verify', () =>
      app.client.waitUntilWindowLoaded()
         .windowByIndex(0)
         .browserWindow.focus()
         .browserWindow.getTitle().should.eventually.be.equal('login')
         .browserWindow.isFocused().should.eventually.be.true
         .pause(3000)
         .setWrongUserName()
         .setPassword()
         .click("#log-btn")
         .pause(5000)
         .isExisting("input#email.highlightgreen").should.eventually.be.false
         .isExisting("input#password.highlightgreen").should.eventually.be.false
         .isExisting("input#email.highlightred").should.eventually.be.true
         .isExisting("input#password.highlightred").should.eventually.be.true
