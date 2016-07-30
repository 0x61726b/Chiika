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
{Router,Route,BrowserHistory,Link}  = require('react-router')

{electron,ipcRenderer}              = require 'electron'

IPC                                 = require '../chiika-ipc'
LoadingScreen                       = require '../loading-screen'

_                                   = require 'lodash'
string                              = require 'string'

#Views

window.$ = window.jQuery            = require('../bundleJs.js')

MalLogin = React.createClass
  getInitialState: ->
    services: []
  componentDidMount: ->
    @ipcManager = new IPC()

    window.ipcManager = @ipcManager

    @ipcManager.sendReceiveIPC 'get-services',null,(event,args,defer) =>
      console.log "???????"
      @setState { services: args }

    #This callback only gets called if error on login
    ipcRenderer.on 'login-response',(event,response) =>
      $("#log-btn").prop('disabled',false)
      if !response.success
        message = "We couldn't login you with the selected service!"
        window.yuiToast(message,'top',5000,'dark')
        console.log response

        @highlightFormByParent("red","#loginForm-#{response.service} ")
      else
        console.log response
        @highlightFormByParent("green","#loginForm-#{response.service} ")



      #ToDo(ahmedbera) : Implement UI for error messages

  highlightFormByParent: (color,parent) ->
    user = $(parent + "#email")
    pass = $(parent + "#password")


    user.css({ "border": "#{color} 1px solid"});
    pass.css({ "border": "#{color} 1px solid"});


  componentDidUpdate: ->
    $("form").
    filter(->
      if !_.isUndefined this.id
        return this.id.match(/loginForm-(.*?)/g))
    .submit( (e) =>
      e.preventDefault()
      false
      )


  onSubmit: (e) ->
    parent = "#" + $(e.target).parent().attr('id') + " "
    user = $(parent + "#email").val()
    pass = $(parent + "#password").val()

    id = $(e.target).parent().attr("id")
    serviceName = string(id).chompLeft('loginForm-').s

    console.log user

    if _.isEmpty user || _.isEmpty pass
      #Do something here
    else
      #$(parent + "#log-btn").prop('disabled',true)
      loginData = { user: user, pass: pass }
      ipcRenderer.send 'set-user-login',{ login: loginData, service: serviceName }

  loginBody: (key,service) ->
    (<div className="card" id="login-container" key=key>
        <img src={service.logo} id="mal-logo" style={{width: 200 , height: 200}} alt="" />
        <form className="" id="loginForm-#{service.name}">
          <label htmlFor="log-usr">Username</label>
          <input type="text" className="text-input" id="email" required autofocus/>
          <label htmlFor="log-psw">Password</label>
          <input type="Password" className="text-input" id="password" required />
          <input type="submit" onClick={this.onSubmit} className="button raised indigo" id="log-btn" value="Verify"/>
        </form>
      </div>)
  render: () ->
    serviceCount = @state.services.length
    if serviceCount == 0
      <LoadingScreen />
    else
      <div className="login-body">
        {
          for i in [0...serviceCount]
            @loginBody(i,@state.services[i])
        }
      </div>

ReactDOM.render(React.createElement(MalLogin), document.getElementById('app'))
