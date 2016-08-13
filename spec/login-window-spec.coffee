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


describe.skip 'Login window tests', ->
  setup = new GlobalSetup()
  setup.setupTimeout(this)

  app = null

  #afterEach =>
    #setup.prettyPrintMainProcessLogs(app.client)

  after =>
    app = null

  setupLogin = (app) ->
    app.client.addCommand 'setLogin', (userName,password) ->
      this.electron.ipcRenderer.send('spectron.',{ message: 'set-login', windowName: 'login', params: { userName: userName, password: password} })


  #
  # Two windows are loading, and login.
  #
  describe 'Open login window',->
    this.timeout(30000)


    beforeEach () =>
      setup.removeAppData().then =>
        setup.startApplication({
          args: [setup.chiikaPath()]
        })
        .then (startedApp) =>
            app = startedApp
            setupLogin(app)

    afterEach =>
      setup.stopApplication(app)

    it 'login and expect continue button to be disabled after 3 secs it will be re enabled', () =>
      app.client.waitUntilWindowLoaded()
         .windowByIndex(0)
         .browserWindow.focus()
         .browserWindow.getTitle().should.eventually.be.equal('login')
         .browserWindow.isFocused().should.eventually.be.true
         .setLogin('chiika_dummyac','chiika_dummy')
         .pause(1000)
         .click("#log-btn")
         .pause(1000)
         .isExisting("input#continue.is-disabled").should.eventually.be.true
         .pause(5000)
         .isExisting("input#continue.is-disabled").should.eventually.be.false

    xit 'type empty user name and empty password, expect red/green highlight', () =>
      app.client.waitUntilWindowLoaded()
         .windowByIndex(0)
         .browserWindow.focus()
         .browserWindow.getTitle().should.eventually.be.equal('login')
         .browserWindow.isFocused().should.eventually.be.true
         .setLogin('','')
         .pause(1000)
         .click("#log-btn")
         .isExisting("input#userName.highlightred").should.eventually.be.true
         .isExisting("input#password.highlightred").should.eventually.be.true
         .setLogin('chiika','')
         .pause(1000)
         .click("#log-btn")
         .isExisting("input#userName.highlightred").should.eventually.be.false
         .isExisting("input#password.highlightred").should.eventually.be.true
         .setLogin('','chiika')
         .pause(1000)
         .click("#log-btn")
         .isExisting("input#userName.highlightred").should.eventually.be.true
         .isExisting("input#password.highlightred").should.eventually.be.false




    xit 'type correct user name and password, click verify', () =>
      app.client.waitUntilWindowLoaded()
         .windowByIndex(0)
         .browserWindow.focus()
         .browserWindow.getTitle().should.eventually.be.equal('login')
         .browserWindow.isFocused().should.eventually.be.true
         .setLogin('chiika_dummyac','chiika_dummy')
         .pause(1000)
         .click("#log-btn")
         .pause(5000)
         .isExisting("input#userName.highlightgreen").should.eventually.be.true
         .isExisting("input#password.highlightgreen").should.eventually.be.true


    xit 'type wrong user name and password, click verify', () =>
      app.client.waitUntilWindowLoaded()
         .windowByIndex(0)
         .browserWindow.focus()
         .browserWindow.getTitle().should.eventually.be.equal('login')
         .browserWindow.isFocused().should.eventually.be.true
         .setLogin('chitogebestgirl','getdestroyedkosaki')
         .pause(1000)
         .click("#log-btn")
         .pause(5000)
         .isExisting("input#userName.highlightgreen").should.eventually.be.false
         .isExisting("input#password.highlightgreen").should.eventually.be.false
         .isExisting("input#userName.highlightred").should.eventually.be.true
         .isExisting("input#password.highlightred").should.eventually.be.true
