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

_forEach                = require 'lodash/collection/forEach'
_assign                 = require 'lodash.assign'
_find                   = require 'lodash/collection/find'
_when                   = require 'when'
_remove                 = require 'lodash/array/remove'
string                  = require 'string'
cp                      = require 'child_process'
Websocket               = require 'websocket'
WebSocketServer         = Websocket.server
http                    = require 'http'



module.exports = class MediaManager
  processAlive: false
  isExtensionServerRunning: false
  extensionPort: 1337
  currentTab: ''


  #
  #
  #
  initialize: ->
    EnableMediaPlayerDetection = chiika.settingsManager.getOption('EnableMediaPlayerDetection')
    EnableBrowserDetection = chiika.settingsManager.getOption('EnableBrowserDetection')

    if EnableMediaPlayerDetection or EnableBrowserDetection
      @startDetectorProcess()

    if chiika.settingsManager.getOption('EnableBrowserExtensionDetection')
      @startExtensionServer()

  broadcastToExtension: (origin,message) ->
    connection = _find @extensionConnections, (o) -> o.origin == origin
    if connection?
      chiika.logger.info("Broadcasting to extension #{origin} -> #{message.state}")
      connection.connection.sendUTF(JSON.stringify(message))

  startExtensionServer: ->
    @extensionServer = http.createServer( (request,response) => )
    @extensionServer.listen(@extensionPort, -> )
    wsServer = new WebSocketServer({ httpServer: @extensionServer })

    chiika.logger.info("Running browser extension server on #{@extensionPort}.")
    @isExtensionServerRunning = true

    # There will be browser count times connection at most.
    @extensionConnections = []


    wsServer.on 'request', (request) =>
      chiika.logger.info((new Date()) + ' Connection from origin ' + request.origin + '.')
      parseOrigin = chiika.browserManager.parseOrigin(request.origin)

      # Find in connections, if the same origin is there, refuse. This logic might change in the future
      findInConnections = _find @extensionConnections, (o) -> o.origin == parseOrigin

      if !findInConnections?
        connection = request.accept(null, request.origin)
        @extensionConnections.push { origin: parseOrigin, connection: connection }

        connection.on 'message', (message) =>
          if message.type == 'utf8'
            data = message.utf8Data
            chiika.browserManager.onSocketMessage(request,data)

        connection.on 'close', (connection) =>
          chiika.logger.info("Closed connection #{parseOrigin}")
          _remove @extensionConnections, (o) -> o.origin == parseOrigin

      else
        chiika.logger.warn("Refusing connection from #{parseOrigin}")

  stopExtensionServer: ->
    @extensionServer.close()
    chiika.logger.info("Stopped browser extension server.")

    @isExtensionServerRunning = false



  #
  #
  #
  onVideoDetected: (videoInfo) ->
    if @player?
      chiika.emitter.emit 'md-detect',videoInfo

  onBrowserVideoDetected: (videoInfo) ->
    if @currentTab != videoInfo.title && @browser?
      url = videoInfo.url
      title = videoInfo.title
      @currentStreamService = chiika.browserManager.streamServices.getStreamServiceFromUrl(url)

      if @currentStreamService?
        streamTitle = chiika.browserManager.streamServices.cleanStreamServiceTitle(@currentStreamService,title)
        # Run through anitomy
        parse = chiika.browserManager.anitomy.Parse streamTitle
        @currentTab = videoInfo.title
        chiika.emitter.emit 'md-detect',{ parse: parse,detectionSource: 'browser' }
        @streamDetected = true
      else
        if @streamDetected? && @streamDetected
          @onPlayerClosed()
          @streamDetected = false
          @currentTab = ''
  #
  #
  #
  onPlayerClosed: ->
    chiika.emitter.emit 'md-close'



  #
  #
  #
  startDetectorProcess: ->
    MediaPlayerList = chiika.settingsManager.getOption('MediaPlayerConfig')
    str = JSON.stringify(MediaPlayerList)

    mpDetection = chiika.settingsManager.getOption('EnableMediaPlayerDetection')
    browserDetection = chiika.settingsManager.getOption('EnableBrowserDetection')

    chiika.logger.verbose "Spawning child process MP: #{mpDetection} - Browser: #{browserDetection}"

    @child = cp.fork("#{__dirname}/media-detect-win32-process.js",[str,mpDetection,browserDetection])

    @processAlive = true

    @child.on 'close',(code,signal) =>
      if signal == 'SIGTERM'
        return
      if code != 0
        throw "Error on child process - #{code} - #{signal}"

    @child.on 'message', (message) =>
      switch message.status

        #
        when 'md-no-video'
          if @player?
            @player = null
            @onPlayerClosed()

        #
        when 'md-running-video'
          if @comparePlayers(message.player,@player) == false
            @player = message.player
            chiika.logger.info("Known media player detected! #{@player.mediaPlayer.name}")

            @onVideoDetected(message)

        #
        when 'md-video-not-video-file'
          if @player?
            @player = null
            @onPlayerClosed()

        when 'md-browser'
          if @player?
            return
          @browser = message.browser

          @onBrowserVideoDetected(message)

  #
  #
  #
  runLibraryProcess: (libraryPaths,animelist,callback) ->
    chiika.logger.verbose("Spawning library process")

    if @libraryProcess?
      chiika.logger.error("Library process is already running.")
      return

    animelistStr = JSON.stringify(animelist)
    @libraryProcess = cp.fork("#{__dirname}/media-library-process.js",[JSON.stringify(libraryPaths)])


    @libraryProcess.send { message: 'set-anime-list', animelist: animelistStr }

    @libraryProcess.on 'close',(code,signal) =>
      if signal == 'SIGTERM'
        return
      if code != 0
        throw "Error on child process wtf? - #{code} - #{signal}"

    @libraryProcess.on 'message', (message) =>
      if message.message == 'lib-stats'
        list = message.list
        time = message.time
        recognizedLen = list.length
        unRecognizedLen = message.notRecognized.length
        chiika.logger.info "#{list.length} entries have been recognized. #{unRecognizedLen} isnt recognized. Took: #{time}"
        callback?(message)
        @libraryProcess.kill('SIGTERM')
        @libraryProcess = null


  #
  #
  #
  isVideoRunning: ->
    if @player?
      true
    else
      false


  #
  #
  #
  comparePlayers: (a,b) ->
    if a? && b? && a.processName == b.processName
      true
    else
      false

  #
  #
  #
  disableRecognition: ->
    if @processAlive
      @child.kill('SIGTERM')
      @child = null
      chiika.logger.verbose "Killing child process"
      @processAlive = false

  #
  #
  #
  enableRecognition: ->
    if !@processAlive
      @startDetectorProcess()
    else
      @disableRecognition()
      @startDetectorProcess()

  #
  #
  #
  systemEvent: (event,param) ->
    if event == 'set-option'
      optionValue = chiika.settingsManager.getOption(param)
      switch param
        when 'EnableMediaPlayerDetection'
          browserDetection = chiika.settingsManager.getOption('EnableBrowserDetection')
          if !optionValue && !browserDetection
            @disableRecognition()
          if optionValue or browserDetection
            @enableRecognition()

        when 'EnableBrowserDetection'
          mpDetection = chiika.settingsManager.getOption('EnableMediaPlayerDetection')
          if !optionValue && !mpDetection
            @disableRecognition()
          if optionValue or mpDetection
            @enableRecognition()



        when 'EnableBrowserExtensionDetection'
          if optionValue && !@isExtensionServerRunning
            @startExtensionServer()
          else if !optionValue && @isExtensionServerRunning
            @stopExtensionServer()
