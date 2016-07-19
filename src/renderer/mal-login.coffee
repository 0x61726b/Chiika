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
ReactDOM = require("react-dom");
{Router,Route,BrowserHistory,Link} = require('react-router')

{electron,ipcRenderer} = require 'electron'

_ = require 'lodash'
ipcHelpers = require '../ipcHelpers'

#Views

window.$ = window.jQuery = require('../chiika.js')

MalLogin = React.createClass
  componentDidMount: ->
    #This callback only gets called if error on login
    ipcRenderer.on 'set-user-login-response',(event,response) ->
      console.log response
      #ToDo(ahmedbera) : Implement UI for error messages
  onSubmit: ->
    user = $("#email").val()
    pass = $("#password").val()

    if _.isEmpty user || _.isEmpty pass
      #Do something here
    else
      loginData = { user: user, pass: pass }
      ipcRenderer.send 'set-user-login',loginData

  render: () ->
    (<div className="login-body">
      <div className="card" id="login-container">
        <img src="./../assets/images/my.png" id="mal-logo" alt="" />
        <form className="">
          <label for="log-usr">Username</label>
          <input type="text" className="text-input" id="email" required autofocus/>
          <label for="log-psw">Password</label>
          <input type="Password" className="text-input" id="password" required />
          <input type="button" onClick={this.onSubmit} className="button raised indigo" id="log-btn" value="Login"/>
        </form>
      </div>
    </div>)

ReactDOM.render(React.createElement(MalLogin), document.getElementById('malLogin'))
