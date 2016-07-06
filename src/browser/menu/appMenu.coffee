app = require 'app'
Menu = require 'menu'
MenuItem = require 'menu-item'
BrowserWindow = require 'browser-window'

electron = require 'electron'
ipcMain = electron.ipcMain

Chiika = require './../Chiika'


template = [{
      label: 'Chiika'
      submenu:[{
          label: 'Reload'
          accelerator: 'CmdOrCtrl+X'
          click: () ->
             BrowserWindow.getFocusedWindow().reload()
             BrowserWindow.webContents.send('window-reload')
             console.log "Is this working"
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
            Chiika.RequestVerifyUser()
          },
          {
          label: 'Get MyAnimeList'
          click: () ->
            Chiika.RequestMyAnimelist()
          },
          {
            label: 'Get MyMangaList'
            click: () ->
              Chiika.RequestMyMangalist()
          },
                    {
                      label: 'Anime Scrape'
                      click: () ->
                        Chiika.RequestAnimeScrape(31414)
                    }]
        },
        {
            label: 'Database'
            submenu:[{
              label: 'Animelist'
              click: () ->
                console.log "Anime Array Len:" + Chiika.getMyAnimelist()['AnimeArray'].length
              },
              {
                label: 'Mangalist'
                click: () ->
                  console.log "Manga Array Len:" + Chiika.getMyMangalist()['MangaArray'].length #Fix me
              },
              {
                label: 'UserInfo'
                click: () ->
                  console.log Chiika.getUserInfo()
              }]
}]

appMenu = Menu.buildFromTemplate(template)

module.exports = appMenu
