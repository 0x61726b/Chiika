app = require 'app'
Menu = require 'menu'
MenuItem = require 'menu-item'

template = [{
  label: 'Electron App'
  submenu: [{
    label: 'Quit'
    accelerator: 'Command+Q'
    click: () -> app.quit()
  }]
}]

appMenu = Menu.buildFromTemplate(template)

module.exports = appMenu
