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

MediaPlayerList = [
  { name: "MPC" , class: "MediaPlayerClassicW", executables: ['mpc-hc', 'mpc-hc64'] },
  { name: "BSPlayer" , class: "BSPlayer", executables: ['bsplayer'] },
  { name: "Google Chrome" , class: "Chrome_WidgetWin_1", browser:0, executables: ['chrome'] },
  { name: "Mozilla Firefox" , class: "MozillaWindowClass", browser: 1, executables: ['firefox'] }
]

module.exports = MediaPlayerList
