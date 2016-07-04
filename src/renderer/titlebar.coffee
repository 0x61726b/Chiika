Titlebar = require 'arkenthera-titlebar'


remote = require 'remote'
BrowserWindow = remote.BrowserWindow;
app = remote.app;

class ChiikaTitlebar
  titlebar:null
  appendTitlebar: ->
    @titlebar = new Titlebar()
    @titlebar.appendTo(document.getElementById('titleBar'))

    @titlebar.on 'close', () ->
      remote.getCurrentWindow().close()
    @titlebar.on 'minimize', () ->
      remote.getCurrentWindow().minimize()
    @titlebar.on 'maximize', () ->
      remote.getCurrentWindow().maximize()



module.exports = ChiikaTitlebar
