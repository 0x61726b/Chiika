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


localShortcut                   = require 'electron-localshortcut'
_forEach                        = require 'lodash.foreach'


module.exports = class ShortcutManager
  registered: false

  register: (window) ->
    if !@registered
      config = chiika.settingsManager.readConfigFile('Chiika')

      @registered = true
      _forEach config.Keys, (key) =>
        chiika.logger.info("Registering shortcut #{key.action} - #{key.key}")

        localShortcut.register window,key.key,=>
          @onShortcut key

  onShortcut: (key) ->
    chiika.emitter.emit 'shortcut-pressed', key

  unregister: (window,key) =>
    chiika.logger.info("Unregistering shortcut #{key.action} - #{key.key}")
    localShortcut.unregister(window,key.key)

  unregisterAll: (window) ->
    chiika.logger.info("Unregistering all shortcuts")
    localShortcut.unregisterAll(window)
