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

window.$ = window.jQuery = require('jQuery')

UpdateWindow = React.createClass
  render: ->
    <div>
      <div style={{marginLeft: 250,marginTop: 250, color: 'white'}}>
        Installing Chiika...
      </div>
    </div>

ReactDOM.render(React.createElement(UpdateWindow), document.getElementById('app'))
