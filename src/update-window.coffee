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

React                               = require('react')
ReactDOM                            = require("react-dom")
{remote,ipcRenderer,shell}          = require 'electron'
LoadingMini                         = require '../loading-mini'

window.$ = window.jQuery = require('jquery')

UpdateWindow = React.createClass
  getInitialState: ->
    update: 'checking-for-update'
  componentDidMount: ->
    downloadingUpdate = =>
      @setState { update: 'update-available' }

    setTimeout(downloadingUpdate,5000)
    ipcRenderer.on 'update-available', (event,args) =>
      @setState { update: args.message }

    ipcRenderer.on 'update-error', (event,args) =>
      @setState { update: args.message }

    ipcRenderer.on 'update-available', (event,args) =>
      @setState { update: args.message }

    ipcRenderer.on 'update-not-available', (event,args) =>
      @setState { update: args.message }

    ipcRenderer.on 'update-downloaded', (event,args) =>
      @setState { update: args.message }

  componentDidUpdate: ->
    console.log @state
  render: ->
    <div className="update-window">
      <div className="update-window-row">
        <div className="updater-window-item">
          <div className="updater-loading-logo">
            <LoadingMini />
          </div>
        </div>
      </div>
      <div className="updater-window-item">
        {
          if @state.update == 'checking-for-update'
            <div className="updater-window-info">Checking for updates..</div>
          else if @state.update == 'update-error'
            <div className="updater-window-info">Error when updating!</div>
          else if @state.update == 'update-available'
            <div className="updater-window-info">Downloading new update..</div>
          else if @state.update == 'update-downloaded'
            <div className="updater-window-info">Downloaded!</div>
          else if @state.update == 'update-not-available'
            <div className="updater-window-info">Chiika is up-to-date!</div>
        }
      </div>
    </div>


ReactDOM.render(React.createElement(UpdateWindow), document.getElementById('app'))
