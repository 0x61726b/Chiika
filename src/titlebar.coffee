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

React = require('react')
{remote} = require 'electron'

{Emitter} = require 'event-kit'

module.exports = React.createClass
  emitter:null
  componentWillMount: ->
    @emitter = new Emitter
  componentDidMount: () ->
    $('.titlebar').addClass("webkit-draggable")
    close = $('.titlebar-close',$('.titlebar'))[0]
    fullscreen = $('.titlebar-fullscreen',$('.titlebar'))[0]
    minimize = $('.titlebar-minimize',$('.titlebar'))[0]

    $('.titlebar').on 'click', (e) =>
      if close.contains(e.target)
        @emitter.emit 'titlebar-close'
        remote.getCurrentWindow().close()
      else if fullscreen.contains(e.target)
        @emitter.emit 'titlebar-maximize'
        remote.getCurrentWindow().maximize()
      else if minimize.contains(e.target)
        @emitter.emit 'titlebar-minimize'
        remote.getCurrentWindow().minimize()
    $('.titlebar').on 'dblclick', (e) =>
      if close.contains(target) || minimize.contains(target) || fullscreen.contains(target)
        return
      remote.getCurrentWindow().maximize()
      @emitter.emit 'titlebar-maximize'


  render: ->
    <div className="titlebar">
        <div className="searchContainer">
          <input type="text" placeholder="Search..." className="form-control" id="gridSearch" />
        </div>
        <div className="spotlightContainer">
            <div className="titlebar-stoplight">
                <div className="titlebar-settings">
                </div>

                <div className="titlebar-divider">
                </div>

                <div className="titlebar-minimize">
                </div>

                <div className="titlebar-fullscreen">
                </div>

                <div className="titlebar-close">
                </div>
            </div>
        </div>
    </div>
  # appendTitlebar: ->
  #   @titlebar = new Titlebar()
  #   @titlebar.appendTo(document.getElementById('titleBar'))
  #
  #   @titlebar.on 'close', () ->
  #     remote.getCurrentWindow().close()
  #   @titlebar.on 'minimize', () ->
  #     remote.getCurrentWindow().minimize()
  #   @titlebar.on 'maximize', () ->
  #     remote.getCurrentWindow().maximize()
