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

helpers = require './global-setup'
path    = require 'path'

describe = global.describe
it = global.it
beforeEach = global.beforeEach
afterEach = global.afterEach

describe 'application launch', ->
  setup = new helpers()
  setup.setupTimeout(this)

  app = null

  beforeEach () =>
    console.log "Electron path #{setup.getElectronPath()}"
    setup.startApplication({
      args: [path.join(__dirname, '..')]})
    .then (startedApp) =>
        app = startedApp

  afterEach =>
    setup.stopApplication(app)



   it 'opens chiika', () =>
      app.client.waitUntilWindowLoaded()
      .browserWindow.focus()
      .getWindowCount().should.eventually.equal(1)
      .browserWindow.isMinimized().should.eventually.be.false
      .browserWindow.isDevToolsOpened().should.eventually.be.false
      .browserWindow.isVisible().should.eventually.be.true
      .browserWindow.isFocused().should.eventually.be.true
      .browserWindow.getBounds().should.eventually.have.property('width').and.be.above(0)
      .browserWindow.getBounds().should.eventually.have.property('height').and.be.above(0)
