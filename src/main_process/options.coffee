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

  Theme: 'Dark'

  # Tray
  MinimizeToTray: true
  CloseToTray: false
  LaunchMinimized: false
  NoTransparentWindows: false

  #Detection
  EnableMediaPlayerDetection: false
  EnableBrowserDetection: false
  EnableNotificationsForBrowserDetection: true
  EnableBrowserExtensionDetection: false
  UpdateDelayAfterDetection: 120

  LibraryPaths: [
    'E:/Anime'
  ]

  # Taken from Taiga
  # github.com/erengy/taiga
  MediaPlayerConfig: [
    { name: "MPC" , class: "MediaPlayerClassicW", executables: ['mpc-hc', 'mpc-hc64'], enabled: true },
    { name: "BSPlayer" , class: "BSPlayer", executables: ['bsplayer'], enabled: false },
    { name: "Google Chrome" , class: "Chrome_WidgetWin_1", browser:0, executables: ['chrome'], enabled: true },
    { name: "Mozilla Firefox" , class: "MozillaWindowClass", browser: 1, executables: ['firefox'], enabled: true },
    { name: "ACE Player HD (VLC)" , class: "QWidget", executables: ['ace_player'], enabled: false },
    { name: "ALLPlayer" , class: "TApplication", executables: ['ALLPlayer'], enabled: false },
    { name: "Baka MPlayer" , class: "Qt5QWindowIcon", executables: ['Baka MPlayer'], enabled: false },
    { name: "BESTplayer" , class: "TBESTplayerApp.UnicodeClass", executables: ['BESTplayer'], enabled: false },
    { name: "Bomi Player" , class: "Qt5QWindowGLOwnDCIcon", executables: ['bomi'], enabled: false },
    { name: "DivX Player" , class: "QWidget", executables: ['DivX Player.exe','DivX Plus Player'], enabled: false },
    { name: "GOM Player" , class: "GomPlayer1.x", executables: ['GOM'], enabled: false },
    { name: "Kantaris Media Player" , class: "WindowsForms10.Window.20008.app.0.378734a", executables: ['Kantaris'], enabled: false },
    { name: "Kodi" , class: "Kodi", executables: ['Kodi'], enabled: false },
    { name: "Kodi XBMC" , class: "XBMC", executables: ['XBMC'], enabled: false },
    { name: "Light Alloy" , class: "LightAlloyFront", executables: ['LA'], enabled: false },
    { name: "Miro" , class: "gdkWindowToplevel", executables: ['Miro'], enabled: false },
    { name: "MPCSTAR" , class: "wxWindowClassNR", executables: ['mpcstar'], enabled: false },
    { name: "MPDN" , class: "FilterGraphWindow", executables: ['MediaPlayerDotNet'], enabled: false },
    { name: "MPDN" , class: "VsyncWindowClass", executables: ['MediaPlayerDotNet'], enabled: false },
    { name: "mpv" , class: "mpv", executables: ['mpv'], enabled: false },
    { name: "MV2Player" , class: "TApplication", executables: ['Mv2Player'], enabled: false },
    { name: "PotPlayer" , class: "PotPlayer", executables: ['Miro'], enabled: false },
    { name: "PotPlayer64" , class: "PotPlayer64", executables: ['PotPlayer','PotPlayer64','PotPlayerMini','PotPlayerMini64'], enabled: false },
    { name: "SMPlayer" , class: "QWidget", executables: ['smplayer','smplayer2'], enabled: false },
    { name: "Splash Lite" , class: "DX_DISPLAY0", executables: ['SplashLite'], enabled: false },
    { name: "SPlayer" , class: "MediaPlayerClassicW", executables: ['splayer'], enabled: false },
    { name: "UMPlayer" , class: "QWidget", executables: ['umplayer'], enabled: false },
    { name: "VLC Media Player" , class: "QWidget", executables: ['vlc'], enabled: false },
    { name: "VLC Media Player" , class: "Qt5QWindowIcon", executables: ['vlc'], enabled: false },
    { name: "VLC Media Player" , class: "VLC DirectX", executables: ['vlc'], enabled: false },
    { name: "Winamp" , class: "Winamp v1.x", executables: ['winamp'], enabled: false },
    { name: "Windows Media Center" , class: "eHome Render Window", executables: ['ehshell'], enabled: false },
    { name: "Windows Media Player" , class: "WMPlayerApp", executables: ['wmplayer'], enabled: false },
    { name: "Windows Media Player" , class: "WMP Skin Host", executables: ['wmplayer'], enabled: false },
    { name: "Zoom Player" , class: "TApplication", executables: ['zplayer'], enabled: true }
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

  #Torrent
  FeedSources: [
    { name: 'Nyaa1', feed: 'http://www.nyaa.se/?page=rss&cats=1_37&filter=2', type: 'xml'}
    { name: 'Nyaa2', feed: 'http://www.nyaa.se/?page=rss&cats=1_37&filter=0', type: 'xml'}
    { name: 'TokyoTosho', feed: 'http://tokyotosho.info/rss.php?filter=1,11&zwnj=0', type: 'xml'}
    { name: 'BakaUpdates', feed: 'http://www.baka-updates.com/rss.php', type: 'xml'}
    { name: 'Haruhichan', feed: 'http://haruhichan.com/feed/feed.php?mode=rss', type: 'xml'}
  ]
  FeedByTitle: [
    { name: 'Nyaa1', feed: 'http://www.nyaa.se/?page=rss&cats=1_37&filter=2&term=', type: 'xml'}
    { name: 'Nyaa2', feed: 'http://www.nyaa.se/?page=rss&cats=1_37&filter=0&term=', type: 'xml'}
  ]
  FilterConditions: [
    { name: 'animeLibrary', desc: 'Library Provider', type: 'list'}
    { name: 'animeId',desc: 'Anime ID', type: 'number' }
    { name: 'animeAiringStatus',desc: 'Anime Airing Status', type: 'airing-status' }
    { name: 'animeType', desc: 'Anime Type', type: 'anime-type' }
    { name: 'animeEpisodeCount',desc: 'Anime Episode Count', type: 'anime-episode-count' }
    { name: 'animeDateStarted',desc: 'Anime Date Started', type: 'date' }
    { name: 'animeDateEnded',desc: 'Anime Date Ended', type: 'date' }
    { name: 'animeWatchingStatus',desc: 'Anime Watching Status', type: 'anime-user-status' }
    { name: 'animeTags',desc: 'Anime Tags', type: 'string' }
    { name: 'animeEpisodeAvailability',desc: 'Episode Availability', type: 'bool' }
    { name: 'episodeTitle', desc: 'Episode Title', type: 'anime-list-titles' }
    { name: 'episodeNumber',desc: 'Episode Number', type: 'anime-episode-count' }
    { name: 'episodeVersion',desc: 'Episode Version', type: 'number' }
    { name: 'episodeFansubGroup',desc: 'Episode Fansub Group', type: 'string' }
    { name: 'episodeVideoType',desc: 'Episode Video Type', type: 'video-type' }
    { name: 'fileName',desc: 'File Name', type: 'string' }
    { name: 'fileCategory',desc: 'File Category', type: 'video-file-category' }
    { name: 'fileDescription',desc: 'File Description', type: 'string' }
    { name: 'fileLink',desc: 'File Link', type: 'string' }
  ]

  Filters: [
    {
      name: 'Select Currently Watching', conditions: [{ name: 'animeWatchingStatus', operator: 'is', value: 'Watching' }],
      matchType: 'any',
      matchAction: 'select',
    }
    {
      name: 'Choose airing in Plan to Watch', conditions: [
        { name: 'animeAiringStatus', operator: 'is', value: 'Currently Airing' }
        { name: 'animeWatchingStatus', operator: 'is', value: 'Plan to Watch' }
      ],
      matchType: 'any',
      matchAction: 'select',
    }
    {
      name: 'Discard not-in-list', conditions: [
        { name: 'animeWatchingStatus', operator: 'is', value: 'Not In List' }
      ],
      matchType: 'any',
      matchAction: 'discard',
      discardType: 'deactivate'
    }
    {
      name: 'Discard watched', conditions: [
        { name: 'episodeNumber', operator: 'lessEq', value: 'anime-episode-watched' }
        { name: 'animeEpisodeAvailability', operator: 'is', value: 'true' }
      ],
      matchType: 'any',
      matchAction: 'discard',
      discardType: 'deactivate'
    }
  ]

  #Keys
  Keys:[
    { action: 'test', key: 'Shift+O' },
    { action: 'test2', key: 'Shift+P' },
    { action: 'test3', key: 'Shift+H'},
    { action: 'focus-input', key: 'Ctrl+L'}
  ]

  #Cards
  DisableCardNews: false
