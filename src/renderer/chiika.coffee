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
StatusBar = require './statusbar'
LoadingScreen = require './loading-screen'
Home = require './home'
AnimeList = require './anime-list'
Mangalist = require './manga-list'

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
      <div className="statusBar">
        <StatusBar />
      </div>
    </div>)

RouterContainer = React.createClass
  waiting: true
  componentDidMount: ->
    chiika.emitter.on 'chiika-ready', () =>
      @waiting = false
      $(".main").removeClass("hidden")
      #$(".main").fadeIn("slow")
      @forceUpdate()

  render: ->
    <div>
    {
       if !@waiting
         <div><SideMenu /><Content props={this.props}/></div>
       else
         <LoadingScreen />
    }
    </div>

ChiikaRouter = React.createClass
  onEnter:(nextState) ->
    path = nextState.location.pathname
    console.log path
  render: () ->
    (<Router history={BrowserHistory}>
      <Route component={RouterContainer}>
        #<Route path="/" component={Home} onEnter={@onEnter}/>
        <Route name="Home" path="Home" component={Home} onEnter={@onEnter}/>
        <Route name="AnimeList" path="AnimeList" component={AnimeList} onEnter={@onEnter}/>
        <Route name="MangaList" path="MangaList" component={Mangalist} onEnter={@onEnter}/>
        <Route name="Library" path="Library" component={Home} onEnter={@onEnter}/>
        <Route name="Calendar" path="Calendar" component={Home} onEnter={@onEnter}/>
        <Route name="Seasons" path="Seasons" component={Home} onEnter={@onEnter}/>
        <Route name="Torrents" path="Torrents" component={Home} onEnter={@onEnter}/>
        <Route name="User" path="User" component={Home} onEnter={@onEnter}/>
        <Route name="Anime" path="/Anime/:animeId" component={Home} onEnter={@onEnter}/>
      </Route>
    </Router>)

module.exports = ChiikaRouter
