Application = require('spectron').Application
assert = require('assert')
chai = require('chai')
chaiAsPromised = require('chai-as-promised')
path = require('path')

global.before =>
  chai.should()
  chai.use(chaiAsPromised)

module.exports = class Setup
  getElectronPath: ->
    electronPath = path.join(__dirname, '..', 'node_modules', '.bin', 'electron')
    if (process.platform == 'win32')
      electronPath += '.cmd'
    electronPath

  setupTimeout: (test) ->
    if (process.env.CI)
      test.timeout(30000)
    else
      test.timeout(10000)

  startApplication: (options) ->
    options.path = @getElectronPath()
    if (process.env.CI?)
      options.startTimeout = 30000
    else
      options.startTimeout = 10000
    console.log options
    app = new Application(options)
    app.start().then =>
      assert.equal(app.isRunning(), true)
      chaiAsPromised.transferPromiseness = app.transferPromiseness
      app

  stopApplication:(app) ->
    if (!app || !app.isRunning())
      return

    app.stop().then =>
      assert.equal(app.isRunning(), false)
