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
_when                   = require 'when'
string                  = require 'string'
cp                      = require 'child_process'


module.exports = class MediaManager
  processAlive: false


  #
  #
  #
  initialize: ->
    if chiika.settingsManager.getOption('DisableAnimeRecognition')
      chiika.logger.error("Detection is disabled.")
    else
      @startDetectorProcess()

  #
  #
  #
  onVideoDetected: (videoInfo) ->
    if @player?
      chiika.emitter.emit 'md-detect',videoInfo

  #
  #
  #
  onPlayerClosed: ->
    chiika.emitter.emit 'md-close'


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
      if message.message == 'media-recognized'
        list = message.list
        chiika.logger.info "#{list.length} entries have been recognized."
        callback?(list)
      if message.message == 'media-not-recognized'
        list = message.list
        chiika.logger.info "#{list.length} entries have not been recognized."
        @libraryProcess.kill('SIGTERM')
        @libraryProcess = null





  #
  #
  #
  startDetectorProcess: ->
    MediaPlayerList = [
      { name: "MPC" , class: "MediaPlayerClassicW", executables: ['mpc-hc', 'mpc-hc64'] },
      { name: "BSPlayer" , class: "BSPlayer", executables: ['bsplayer'] },
      { name: "Google Chrome" , class: "Chrome_WidgetWin_1", browser:0, executables: ['chrome'] },
      { name: "Mozilla Firefox" , class: "MozillaWindowClass", browser: 1, executables: ['firefox'] }]
    str = JSON.stringify(MediaPlayerList)

    chiika.logger.verbose "Spawning child process"
    @child = cp.fork("#{__dirname}/media-detect-win32-process.js",[str,true])

    @processAlive = true

    @child.on 'close',(code,signal) =>
      if signal == 'SIGTERM'
        return
      if code != 0
        throw "Error on child process wtf? - #{code} - #{signal}"

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

  #
  #
  #
  systemEvent: (event,param) ->
    if event == 'set-option'
      optionValue = chiika.settingsManager.getOption(param)
      switch param
        when 'DisableAnimeRecognition'
          if !optionValue
            @enableRecognition()
          else
            @disableRecognition()
