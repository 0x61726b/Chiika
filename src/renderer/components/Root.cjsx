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

SideMenu = require './SideMenu'
Content = require './Content'


#Views
Home = require './Views/Home'
AnimeList = require './Views/AnimeList'
MangaList = require './Views/MangaList'
Library = require './Views/Library'
Calendar = require './Views/Calendar'
Seasons = require './Views/Seasons'
Torrents = require './Views/Torrents'
User = require './Views/User'




class Root extends React.Component
  constructor: (props) ->
    super props
  render: () ->
    (<div><SideMenu /><Content props={this.props}/></div>)

class ChiikaRouter extends React.Component
  render: () ->
    (<Router>
      <Route component={Root}>
        <Route path="/" component={Home}/>
        <Route name="Home" path="Home" component={Home}/>
        <Route name="AnimeList" path="AnimeList" component={AnimeList}/>
        <Route name="MangaList" path="MangaList" component={MangaList}/>
        <Route name="Library" path="Library" component={Library}/>
        <Route name="Calendar" path="Calendar" component={Calendar}/>
        <Route name="Seasons" path="Seasons" component={Seasons}/>
        <Route name="Torrents" path="Torrents" component={Torrents}/>
        <Route name="User" path="User" component={User}/>
      </Route>
    </Router>)

module.exports = ChiikaRouter
