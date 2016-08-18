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


describe 'Renderer process general tests', ->
  setup = new GlobalSetup()
  setup.setupTimeout(this)

  beforeEach (done) =>
    setup.removeAppData().then =>
      done()
    return


  runApp = =>
    new Promise (resolve) =>
      setup.startApplication({
        args: [setup.chiikaPath()],
        DEV_MODE:false,
        RUNNING_TESTS: true
      })
      .then (startedApp) =>
        resolve(startedApp)

  stopApp = (app) =>
    setup.stopApplication(app)

  describe 'Tab Grid View', ->
    this.timeout(100000)

    it 'When browsing tabs, it should remember scroll position and scrollback', ->
      setup.copyTestData('data_with_user').then =>
        runApp().then (app) =>
          app.client
          .waitUntilWindowLoaded()
          .windowByIndex(0)
          .browserWindow.focus()
          .pause(2000)
          .browserWindow.getTitle().should.eventually.be.equal('Home')
          .click(".side-menu-link[href='#myanimelist_animelist']")
          .pause(500)
          .then =>
            setup.prettyPrintMainProcessLogs(app.client)
          # .click("li[role='tab']:last-child")
          # .pause(500)
          # .electron.ipcRenderer.send('spectron.',{ message: 'scrollgrid', windowName: 'main', params: { scrollAmount: 500 } })
          # .pause(1000)
          # .click("li[role='tab']:first-child")
          # .pause(500)
          # .click("li[role='tab']:last-child")
          # .pause(500)
          # .isExisting("scrollPosition[value='500']").should.eventually.be.true
          # .pause(2000)
          # .then =>
          #   stopApp(app)

    xit 'When returning to TabGridView, it should remember which tab was previously open', ->
      setup.copyTestData('data_with_user').then =>
        runApp().then (app) =>
          app.client
          .waitUntilWindowLoaded()
          .windowByIndex(0)
          .browserWindow.focus()
          .pause(2000)
          .browserWindow.getTitle().should.eventually.be.equal('Home')
          .click(".side-menu-link[href='#myanimelist_animelist']")
          .pause(500)
          .browserWindow.getTitle().should.eventually.be.equal('myanimelist_animelist#0')
          .click("li[role='tab']:last-child")
          .pause(500)
          .browserWindow.getTitle().should.eventually.be.equal('myanimelist_animelist#4')
          .click(".side-menu-link[href='#Home']")
          .pause(500)
          .click(".side-menu-link[href='#myanimelist_animelist']")
          .browserWindow.getTitle().should.eventually.be.equal('myanimelist_animelist#4')
          .click(".side-menu-link[href='#myanimelist_mangalist']")
          .pause(500)
          .browserWindow.getTitle().should.eventually.be.equal('myanimelist_mangalist#0')
          .click("li[role='tab']:last-child")
          .browserWindow.getTitle().should.eventually.be.equal('myanimelist_mangalist#4')
          .click(".side-menu-link[href='#myanimelist_animelist']")
          .pause(500)
          .browserWindow.getTitle().should.eventually.be.equal('myanimelist_animelist#4')
          .click(".side-menu-link[href='#myanimelist_mangalist']")
          .pause(500)
          .browserWindow.getTitle().should.eventually.be.equal('myanimelist_mangalist#4')
          .click(".side-menu-link[href='#myanimelist_animelist']")
          .pause(500)
          .browserWindow.getTitle().should.eventually.be.equal('myanimelist_animelist#4')
          .then =>
            stopApp(app)
  #
  describe 'Side Menu',->

    xit 'clicking at side menu should navigate', ->
      setup.copyTestData('data_with_user').then =>
        runApp().then (app) =>
          app.client
          .waitUntilWindowLoaded()
          .windowByIndex(0)
          .browserWindow.focus()
          .pause(2000)
          .click(".side-menu-link[href='#myanimelist_animelist']")
          .pause(500)
          .browserWindow.getTitle().should.eventually.be.equal('myanimelist_animelist#0')
          .click(".side-menu-link[href='#myanimelist_mangalist']")
          .pause(500)
          .browserWindow.getTitle().should.eventually.be.equal('myanimelist_mangalist#0')
          .then =>
            stopApp(app)
    #
    #
    #
    xit 'should have 3 menu items', () =>
      setup.copyTestData('data_with_user').then =>
        runApp().then (app) =>
          app.client
          .waitUntilWindowLoaded()
          .pause(2000)
          .windowByIndex(0)
          .browserWindow.focus()
          .isExisting(".side-menu-link[href='#Home'].active").should.eventually.be.true
          .isExisting(".side-menu-link[href='#myanimelist_animelist'].active").should.eventually.be.false
          .isExisting(".side-menu-link[href='#myanimelist_mangalist'].active").should.eventually.be.false
          .then =>
            stopApp(app)
    #
    #
    #
    xit 'should have active class when clicked at a menu item', () =>
      setup.copyTestData('data_with_user').then =>
        runApp().then (app) =>
          app.client
          .waitUntilWindowLoaded()
          .pause(2000)
          .windowByIndex(0)
          .browserWindow.focus()
          .isExisting(".side-menu-link[href='#Home'].active").should.eventually.be.true
          .click(".side-menu-link[href='#myanimelist_animelist']")
          .pause(1000)
          .isExisting(".side-menu-link[href='#Home'].active").should.eventually.be.false
          .isExisting(".side-menu-link[href='#myanimelist_animelist'].active").should.eventually.be.true
          .then =>
            stopApp(app)
