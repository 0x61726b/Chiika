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
BrowserHistory = require('./Common').BrowserHistory
SideMenu = require './SideMenu'
Content = require './Content'


#Views
Home = require './Views/Home'
AnimeList = require './Views/AnimeList'
AnimeDetails = require './Views/AnimeDetails'
MangaList = require './Views/MangaList'
Library = require './Views/Library'
Calendar = require './Views/Calendar'
Seasons = require './Views/Seasons'
Torrents = require './Views/Torrents'
User = require './Views/User'

h = require './Helpers'
Search = require './Search'

Chiika = require './../ChiikaNode'


Root = React.createClass
  routes: [
    'Home',
    'AnimeList',
    'MangaList',
    'Library',
    'Calendar',
    'Seasons',
    'Torrents',
    'User'
  ]
  componentDidMount: ->
    path = @props.routes[@props.routes.length-1]
    routeIndex = 0
    for val,index in @routes
      if path.path == val
        routeIndex = index

    Search.updateState(routeIndex)
    h.SetActiveMenuItem(routeIndex)
  render: () ->
    (<div><SideMenu /><Content props={this.props}/></div>)

ChiikaRouter = React.createClass
  lastAnimeDetailsData:null
  onEnter:(nextState) ->
    path = nextState.location.pathname

    if path == '/Home' || path == 'Home'
      Search.updateState(0)
    if path == 'AnimeList'
      Search.updateState(1)
    if path == 'MangaList'
      Search.updateState(2)
    if path == 'Library'
      Search.updateState(3)
    if path == 'Calendar'
      Search.updateState(4)
    if path == 'Seasons'
      Search.updateState(5)
    if path == 'Torrents'
      Search.updateState(6)
    if path == 'User'
      Search.updateState(7)

  getInitialState: ->
    animeListLastTab:0
    shouldUpdateDetails:false
  componentDidMount: ->
    Chiika.listener = this
  trigger: () ->
    console.log "triggered"
    
    @setState( {shouldUpdateDetails:true })
  onAnimeListTabSelect: (index,last) ->
    @state.animeListLastTab = index

  CreateAnimeList: (props) ->
    (<AnimeList onSelect={@onAnimeListTabSelect} startWithTabIndex={@state.animeListLastTab} />)
  CreateAnimeDetails: (props) ->
    (<AnimeDetails {...props} shouldUpdateDetails={@state.shouldUpdateDetails}/>)
  render: () ->
    (<Router history={BrowserHistory}>
      <Route component={Root}>
        #<Route path="/" component={Home} onEnter={@onEnter}/>
        <Route name="Home" path="Home" component={Home} onEnter={@onEnter}/>
        <Route name="AnimeList" path="AnimeList" component={@CreateAnimeList} onEnter={@onEnter}/>
        <Route name="MangaList" path="MangaList" component={MangaList} onEnter={@onEnter}/>
        <Route name="Library" path="Library" component={Library} onEnter={@onEnter}/>
        <Route name="Calendar" path="Calendar" component={Calendar} onEnter={@onEnter}/>
        <Route name="Seasons" path="Seasons" component={Seasons} onEnter={@onEnter}/>
        <Route name="Torrents" path="Torrents" component={Torrents} onEnter={@onEnter}/>
        <Route name="User" path="User" component={User} onEnter={@onEnter}/>
        <Route name="Anime" path="/Anime/:animeId" component={@CreateAnimeDetails} onEnter={@onEnter}/>
      </Route>
    </Router>)

module.exports = ChiikaRouter
