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

module.exports =
  LaunchOnStartup: false
  DisableBubbleNotifications: false
  RefreshUponLaunch: true
  UseAlternateListView : false
  RememberWindowSizeAndPosition: true
  DisableBubbleNotifications: false

  # Tray
  MinimizeToTray: true
  CloseToTray: true
  LaunchMinimized: false
  NoTransparentWindows: false

  #Detection
  DisableAnimeRecognition: false
  EnableBrowserDetection: false

  LibraryPaths: [
    'E:/Anime'
  ]
  #Grid
  FilterGridImmediately: true

  #Tabs
  RememberSortingPreference: true
  RememberScrollTabPosition: true

  #Window
  WindowProperties:
    width: 800
    height: 600
    x:0
    y:0
    center: true

  #RSS
  DefaultRssSource: 'ANN'
  RSSSources: ['ANN','MAL']

  #Keys
  Keys:[
    { action: 'test', key: 'Shift+O' },
    { action: 'test2', key: 'Shift+P' },
    { action: 'test3', key: 'Shift+H'}
  ]
