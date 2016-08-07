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
    console.log "Settings Mounted"


  render: ->
    <div className="modal">
      <div className="settingsModal">
        <div className="navigation">
          <h5>Settings</h5>
          <ul>
            <p className="list-title">General</p>
            <a id="window" className="side-menu-link active">
              <li>Window</li>
            </a>
            <a id="account" className="side-menu-link">
              <li>Account</li>
            </a>
            <a className="side-menu-link">
              <li>Page 1</li>
            </a>
            <p className="list-title">Lists</p>
            <a className="side-menu-link">
              <li>Page 1</li>
            </a>
            <a className="side-menu-link">
              <li>Page 1</li>
            </a>
            <p className="list-title">Accounts</p>
            <a className="side-menu-link">
              <li>Page 1</li>
            </a>
            <button className="button raised red" onClick=yuiCloseModal> Close </button>
          </ul>
        </div>
        <div className="settings-page">
          <h2>Settings Page Title</h2>
          <div className="card">
            <div className="title">
              <h4>Settings Group Tiddddddddddddtel</h4>
            </div>
          </div>
        </div>
      </div>
    </div>
