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
                <div className="titlebar-minimize">
                    <svg x="0px" y="0px" viewBox="0 0 8 1.1">
                        <rect fill="#995700" width="8" height="1.1"></rect>
                    </svg>
                </div>

                <div className="titlebar-fullscreen">
                    <svg className="fullscreen-svg" x="0px" y="0px" viewBox="0 0 6 5.9">
                        <path fill="#006400" d="M5.4,0h-4L6,4.5V0.6C5.7,0.6,5.3,0.3,5.4,0z"></path>
                        <path fill="#006400" d="M0.6,5.9h4L0,1.4l0,3.9C0.3,5.3,0.6,5.6,0.6,5.9z"></path>
                    </svg>
                    <svg className="maximize-svg" x="0px" y="0px" viewBox="0 0 7.9 7.9">
                        <polygon fill="#006400" points="7.9,4.5 7.9,3.4 4.5,3.4 4.5,0 3.4,0 3.4,3.4 0,3.4 0,4.5 3.4,4.5 3.4,7.9 4.5,7.9 4.5,4.5"></polygon>
                    </svg>
                </div>

                <div className="titlebar-close">
                    <svg x="0px" y="0px" viewBox="0 0 6.4 6.4">
                        <polygon fill="#4d0000" points="6.4,0.8 5.6,0 3.2,2.4 0.8,0 0,0.8 2.4,3.2 0,5.6 0.8,6.4 3.2,4 5.6,6.4 6.4,5.6 4,3.2"></polygon>
                    </svg>
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
