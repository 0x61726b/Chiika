app = require 'app'
Menu = require 'menu'
MenuItem = require 'menu-item'
Chiika = require("./../../../../chiika-node")
path = require('path');
fs = require('fs');
lib  = path.join(path.dirname(fs.realpathSync(Chiika.path)), '../');

root = new Chiika.Root({
      userName:"arkenthera",
      pass:"123456789",
      debugMode:true,
      appMode:true,
      modulePath:lib
    });


request = new Chiika.Request();
database = new Chiika.Database();

# request.verifyUser(-> console.log "success"
# -> console.log "error"
# )




template = [{
  label: 'Requests'
  submenu: [{
    label: 'Verify'
    click: () ->
      request.VerifyUser(-> console.log "success"
      -> console.log "error"
      )
  },
  {
    label: 'Get MyAnimeList'
    click: () ->
      request.GetMyAnimelist(-> console.log "success"
      -> console.log "error"
      )
  },
  {
    label: 'Get MyMangaList'
    click: () ->
      request.GetMyMangalist(-> console.log "success"
      -> console.log "error"
      )
  },
  {
    label: 'Quit'
    accelerator: 'Command+Q'
    click: () -> app.quit()
  }]
}]

appMenu = Menu.buildFromTemplate(template)

module.exports = appMenu
