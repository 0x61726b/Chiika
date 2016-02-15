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
React = require 'react'
Titlebar = require './components/Titlebar'
electron = require 'electron'
ipcRenderer = electron.ipcRenderer
remote = require 'remote'
BrowserWindow = remote.BrowserWindow

#This component will run on another context
class MyAnimelistLogin extends React.Component
  utility:null
  constructor: (props) ->
    super props

    ipcRenderer.on 'set-login-info',(event,arg) ->
      if arg == 'error'
        console.log "Error!"
  onSubmit: =>
    user = $("#email").val()
    pass = $("#password").val()

    if user == '' || pass == ''
      console.log "?"
    else
      ipcData = { user: user, pass:pass }
      ipcRenderer.send 'set-login-info',ipcData
  render: () ->
    (<div className="container">
      <div className="row">
          <div className="loginContainer">
              <h1 className="text-center login-title">Please login to your Myanimelist.net Account</h1>
                <div className="account-wall">
                    <img className="profile-img" src="./../assets/images/my.png" />
                    <div className="form-signin">
                    <input type="text" id="email" className="form-control chiika-input" placeholder="Email" required autofocus />
                    <input type="password" id="password" className="form-control chiika-input" placeholder="Password" required />
                    <button onClick={this.onSubmit} className="chiika-button" id="login-button">Sign in</button>
                    </div>
                </div>
          </div>
      </div>
</div>);
Content = React.createClass
  render: () ->
    (<div><div id="titleBar"></div>
    <MyAnimelistLogin /></div>)

React = require("react");
ReactDOM = require("react-dom");

ReactDOM.render(React.createElement(Content), document.getElementById('malLogin'))

titlebar = new Titlebar
titlebar.appendTitlebar()
