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

{electron,ipcRenderer,remote}       = require 'electron'

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
    window.chiika = this

    @logger = remote.getGlobal('logger')

    @ipcManager = new IPC()

    window.ipcManager = @ipcManager


    @ipcManager.sendReceiveIPC 'get-services',null,(event,defer,args) =>
      if args?
        console.log args
        @setState { services: args }

        #args.map( (service,i) => $("#verifyBtn-#{service.name}").hide())

        args.map (service,i) =>
          $("#authPin-#{service.name}").on 'input',=>
            if _.isEmpty $("#authPin-#{service.name}").val()
              $("#verifyBtn-#{service.name}").hide()
              $("#gotoBtn-#{service.name}").show()
            else
              $("#verifyBtn-#{service.name}").show()
              $("#gotoBtn-#{service.name}").hide()




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
      $("#continue").prop("disabled",false)


    ipcRenderer.on 'inform-login-response', (event,response) =>
      console.log response
      if response.status
        $("#authPin-#{response.owner}").val(response.authPin)

        $("#gotoBtn-#{response.owner}").hide()
        $("#verifyBtn-#{response.owner}").show()
      else
        @highlightFormByParent("red","#authPin-#{response.owner}")

      $("#continue").prop("disabled",false)

    ipcRenderer.on 'inform-login-set-form-value', (event,response) =>
      parent = "#loginForm-#{response.owner} "
      $(parent + "##{response.target}").val(response.value)
      console.log response

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

    if _.isEmpty user || _.isEmpty pass
      #Do something here
    else
      #$(parent + "#log-btn").prop('disabled',true)
      loginData = { user: user, pass: pass }
      ipcRenderer.send 'set-user-login',{ login: loginData, service: serviceName }




  onSubmitAuthPin: (e) ->
    id = $(e.target).parent().attr("id")
    serviceName = string(id).chompLeft('loginForm-').s
    ipcRenderer.send 'set-user-auth-pin',{ service: serviceName }

    $("#continue").prop('disabled',true)

  onSubmitAuthPinStep2: (e) ->
    id = $(e.target).parent().attr("id")
    parent = "#" + $(e.target).parent().attr('id') + " "
    serviceName = string(id).chompLeft('loginForm-').s
    authPin = $("#authPin-#{serviceName}").val()
    user = $(parent + "#userName").val()

    ipcRenderer.send 'set-user-login',{ authPin: authPin, service: serviceName, user: user }

    $("#continue").prop('disabled',true)

  continueToApp: (e) ->
    @ipcManager.sendMessage 'call-window-method','close'
    @ipcManager.sendMessage 'window-method',{ method: 'show', window:'main' }
    @ipcManager.sendMessage 'continue-from-login'


  loginBody: (key,service) ->
    (<div className="card" id="login-container" key=key>
        <img src={service.logo} id="mal-logo" style={{width: 200 , height: 200}} alt="" />
        <form className="" id="loginForm-#{service.name}">
          <label htmlFor="log-usr">Username</label>
          <input type="text" className="text-input" id="email" required autofocus/>
          <label htmlFor="log-psw">Password</label>
          <input type="Password" className="text-input" id="password" required />
          <input type="submit" onClick={this.onSubmit} className="button raised indigo log-btn" id="log-btn" value="Verify"/>
        </form>
      </div>)
  authPinBody: (key,service) ->
    (<div className="card" id="login-container" key=key>
        <img src={service.logo} id="mal-logo" style={{width: 200 , height: 200}} alt="" />
        <form className="" id="loginForm-#{service.name}">
        <label htmlFor="log-usr">User Name</label>
        <input type="text" className="text-input" id="userName" placeholder="Will be automatically replaced. If not, type your display name" required autofocus/>
          <label htmlFor="log-usr">Auth Pin</label>
          <input type="text" className="text-input" id="authPin-#{service.name}" required autofocus disabled placeholder="Will be automatically replaced"/>
          <input type="submit" onClick={this.onSubmitAuthPin} className="button raised indigo log-btn" id="gotoBtn-#{service.name}" value="Go to #{service.description}"/>
          <input type="submit" onClick={this.onSubmitAuthPinStep2} className="button raised indigo log-btn" id="verifyBtn-#{service.name}" value="Verify"/>
        </form>
      </div>)
  render: () ->
    if @state.services?
      serviceCount = @state.services.length
    else
      serviceCount = 0
    if serviceCount == 0
      <LoadingScreen />
    else
      <div className="login-body-outer">
        <div className="login-body">
          {
            for i in [0...serviceCount]
              if @state.services[i].loginType == 'authPin'
                @authPinBody i,@state.services[i]
              else
                @loginBody(i,@state.services[i])
          }
        </div>
        <input type="submit" onClick={this.continueToApp} className="button raised indigo log-btn-contiue" id="continue" value="Continue to Chiika"/>
      </div>

ReactDOM.render(React.createElement(MalLogin), document.getElementById('app'))
