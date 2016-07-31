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
{Router,Route,BrowserHistory} = require('react-router')


SideMenu = require './side-menu'
Titlebar = require './titlebar'
LoadingScreen = require './loading-screen'
Home = require './home'
Calendar = require './calendar'

Content = React.createClass
  componentDidMount: ->

  render: () ->
    (<div className="main">
      <div id="titleBar">
        <Titlebar />
      </div>
      <div className="content">
        {this.props.props.children}
      </div>
    </div>)

RouterContainer = React.createClass
  waiting: true
  componentDidMount: ->

  render: ->
    <div><SideMenu /><Content props={this.props}/></div>

ChiikaRouter = React.createClass
  componentDidMount: ->

  onEnter:(nextState) ->
    path = nextState.location.pathname
  animeDetailsRoute: (props) ->
    (<AnimeDetails {...props}/>)
  render: () ->
    (<Router history={BrowserHistory}>
      <Route component={RouterContainer}>
        #<Route path="/" component={Home} onEnter={@onEnter}/>
        <Route name="Home" path="Home" component={Home} onEnter={@onEnter}/>
      </Route>
    </Router>)

module.exports = ChiikaRouter
