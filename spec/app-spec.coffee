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

# describe 'app', ->
#
#   it 'test', (done) ->
#     this.timeout(0)
#
#     Application = require process.cwd() + '/src/main_process/chiika'
#
#     app = new Application()
#     app.appDelegate.onAppReady().then =>
#       app.dbManager.onLoad =>
#         app.run()
#         setTimeout(done,2000)
#
#     test = 42

Application = require('spectron').Application
assert = require('assert')

describe 'application launch',->
  @timeout(10000)

  beforeEach =>
    @app = new Application { path: process.cwd() + "/.serve/main_process/chiika.js"}

    @app.start()

  afterEach =>
    if @app && @app.isRunning()
      @app.stop()

  it 'shows an initial window', ->
    @app.client.getWindowCount().then (count) =>
      assert.equal(count, 1)
