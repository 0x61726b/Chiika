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

React = require('./Common').React
Router = require('./Common').Router
Route = require('./Common').Route
Link = require('./Common').Link

class Content extends React.Component
  constructor: (props) ->
    super props
  render: () ->
    (<div className="main">
      <div id="titleBar">
      </div>
      <div className="content">
        {this.props.props.children}
      </div>
      <div className="statusBar">
      </div>
    </div>)

module.exports = Content
