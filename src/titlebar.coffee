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

  getInitialState: ->
    updateAvailable: false

  componentWillMount: ->
    @emitter = new Emitter

  componentDidMount: () ->
    chiika.emitter.on 'update-available', =>
      @setState { updateAvailable: true }

    chiika.emitter.on 'update-not-available', =>
      @setState { updateAvailable: false }


  minimize: ->
    @emitter.emit 'titlebar-minimize'
    remote.getCurrentWindow().minimize()

  maximize: ->
    @emitter.emit 'titlebar-maximize'
    remote.getCurrentWindow().maximize()

  close: ->
    @emitter.emit 'titlebar-close'
    remote.getCurrentWindow().close()

  update: ->
    onUpdateConfirm = ->
      chiika.ipc.sendMessage 'squirrel', 'start-update'

      chiika.toastLoading('Updating Chiika...',10000)

    chiika.notificationManager.updateDialog(onUpdateConfirm)

  render: ->
    <div className="titlebar">
        <div className="searchContainer">
          <input type="text" placeholder="Search..." className="form-control" id="gridSearch" />
        </div>
        <div className="spotlightContainer">
            <div className="titlebar-stoplight">
                {
                  if @state.updateAvailable
                    <div className="titlebar-update" onClick={@update}>
                    </div>
                }
                <div className="titlebar-devtools" onClick={ () => chiika.toggleDevTools() }>
                </div>

                <div className="titlebar-settings" onClick={ () => window.location = "##{@props.location.pathname}?settings=true&location=App"}>
                </div>

                <div className="titlebar-divider">
                </div>

                <div className="titlebar-minimize" onClick={@minimize}>
                </div>

                <div className="titlebar-fullscreen" onClick={@maximize}>
                </div>

                <div className="titlebar-close" onClick={@close}>
                </div>
            </div>
        </div>
    </div>
