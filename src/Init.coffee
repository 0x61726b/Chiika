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
React = require("react")
ReactDOM = require("react-dom")

Chiika = require("./chiika")
LoadingScreen = require './loading-screen'

Environment = require './chiika-environment'
ApplicationDelegate = require './application-delegate'

Col = require './custom-column-types'

window.$ = window.jQuery = require('./bundleJs.js')
$ ->
  loading = ->
    ReactDOM.render(React.createElement(LoadingScreen), document.getElementById('app'))
  app = ->
    ReactDOM.render(React.createElement(Chiika), document.getElementById('app'))

  loading()

  window.chiika = new Environment({
    window,
    applicationDelegate: new ApplicationDelegate,
    chiikaHome: process.env.CHIIKA_HOME,
    env: process.env
    })
  chiika.reInitializeUI(loading,app)


  chiika.emitter.emit 'reinitialize-ui'
  


  #ReactDOM.render(React.createElement(Chiika), document.getElementById('app'))
