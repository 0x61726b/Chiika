app = require 'app'
Menu = require 'menu'
MenuItem = require 'menu-item'
BrowserWindow = require 'browser-window'

electron = require 'electron'
ipcMain = electron.ipcMain


template = [{
      label: 'Chiika'
      submenu:[{
          label: 'Reload'
          accelerator: 'CmdOrCtrl+R'
          click: () ->
             BrowserWindow.getFocusedWindow().reload()
             #console.log Root
      },
      {
          label: 'Quit'
          accelerator: 'CmdOrCtrl+Q'
          click: () -> app.quit()
      }]
  },{
  label: 'Requests'
  submenu: [{
          label: 'Verify'
          click: () ->
            BrowserWindow.getFocusedWindow().webContents.send 'browserPing','requestVerify'
          },
          {
          label: 'Get MyAnimeList'
          click: () ->
            BrowserWindow.getFocusedWindow().webContents.send 'browserPing','requestMyAnimelist'
          },
          {
            label: 'Get MyMangaList'
            click: () ->
              BrowserWindow.getFocusedWindow().webContents.send 'browserPing','requestMyMangalist'
          }]
        },
        {
            label: 'Database'
            submenu:[{
              label: 'Animelist'
              click: () ->
                BrowserWindow.getFocusedWindow().webContents.send 'browserPing','databaseAnimelist'
              },
              {
                label: 'Mangalist'
                click: () ->
                  BrowserWindow.getFocusedWindow().webContents.send 'browserPing','databaseMangalist'
              },
              {
                label: 'UserInfo'
                click: () ->
                  BrowserWindow.getFocusedWindow().webContents.send 'browserPing','databaseUserInfo'
              }]
}]

appMenu = Menu.buildFromTemplate(template)

module.exports = appMenu
