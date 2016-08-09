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
Settings = require './settings'
LoadingScreen = require './loading-screen'
Home = require './home'

_ = require 'lodash'

TabGridView = require './view-tabGrid'
CardView = require './card-view'
DetailsCardView = require './card-view-details'

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
      <div id="settings">
        <Settings />
      </div>
    </div>)

RouterContainer = React.createClass
  render: ->
    <div id="appMain"><SideMenu props={this.props} /><Content props={this.props}/></div>


ChiikaRouter = React.createClass
  routes: []
  currentRouteName: null
  getInitialState: ->
    test: false
    uiData: chiika.uiData
    routerConfig: @getRoutes(chiika.uiData)

  getRoutes: (uiData) ->
    routes = []
    uiData.map (route,i) =>
      if route.displayType == "TabGridView"
        routes.push {
        name: "/#{route.name}"
        path: "/#{route.name}"
        component:require(chiika.viewManager.getComponent(route.displayType))
        view: route
        onEnter: @onEnter}

    testCards = []
    testCards.push chiika.cardManager.getCard('typeMiniCard')
    testCards.push chiika.cardManager.getCard('seasonMiniCard')
    testCards.push chiika.cardManager.getCard('episodeMiniCard')
    testCards.push chiika.cardManager.getCard('studioMiniCard')
    testCards.push chiika.cardManager.getCard('sourceMiniCard')

    detailsLayout =
      title: "Nisekoi"
      genres: "Romcom,Comedy,Romance"
      list: true
      synopsis: 'test'
      cover: './../assets/images/nisekoi.jpg'
      characters: [
        { name: 'Chitoge', image: './../assets/images/chitoge.png' },
        { name: 'Kosaki', image: './../assets/images/kosaki.png' }
        { name: 'Raku', image: './../assets/images/raku.png' }
      ]
      actionButtons: [
        { name: 'Torrent', action: 'torrent',color: 'lightblue' },
        { name: 'Library', action: 'library',color: 'purple' }
        { name: 'Play Next', action: 'playnext',color: 'teal' }
        { name: 'Search', action: 'search',color: 'green' }
      ]
      scoring:
        type: 'normal'
        userScore: '8'
      miniCards: testCards
    dl =
      title: "Re:zero season 2"
      genres: "Drama,fantasy,thriller"
      list: false
      synopsis: 'Subaru kun having fun with girls Rem,Ram and Emilia.'
      cover: './../assets/images/rezero.jpg'
      characters: [
        { name: 'Chitoge', image: './../assets/images/chitoge.png' },
        { name: 'Kosaki', image: './../assets/images/kosaki.png' }
        { name: 'Raku', image: './../assets/images/raku.png' }
      ]
      actionButtons: [
        { name: 'Torrent', action: 'torrent',color: 'lightblue' },
        { name: 'Library', action: 'library',color: 'purple' }
        { name: 'Play Next', action: 'playnext',color: 'teal' }
        { name: 'Search', action: 'search',color: 'green' }
      ]
      scoring:
        type: 'normal'
        userScore: '8'
      miniCards: testCards


    routerConfig = {
        component: RouterContainer,
        childRoutes: [
          { name:'Home', path: '/Home', component: Home, onEnter: @onEnter },
          { name:'CardTest', path: '/CardTest', component: CardView, onEnter: @onEnter, cards: testCards  },
          { name:'DetailsCardTest', path: '/DetailsCardTest', component: DetailsCardView, onEnter: @onEnter, layout: detailsLayout  },
          { name:'DetailsCardTest2', path: '/DetailsCardTest2', component: DetailsCardView, onEnter: @onEnter, layout: dl  },
          { name:'Details', path: '/details/:id', component: DetailsCardView, onEnter: @onEnter },
        ]
    }
    for route in routes
      routerConfig.childRoutes.push route
    routerConfig
  componentDidMount: ->
    @setState { routerConfig: @getRoutes(chiika.uiData) }


    chiika.ipc.refreshUIData (args) =>
      routerConfig = @state.routerConfig
      #routerConfig = @getRoutes(chiika.uiData)
      _.forEach args, (v,k) =>
        findChildRoute = _.find(routerConfig.childRoutes, (o) -> o.name == '/' + v.name)

        if findChildRoute?
          findChildRoute.view = v
      @setState { routerConfig: routerConfig }

    routerConfig = @state.routerConfig
    _.forEach @state.uiData, (v,k) =>
      findChildRoute = _.find(routerConfig.childRoutes, (o) -> o.name == @currentRouteName)

      if findChildRoute?
        findChildRoute.view = v
    @setState { routerConfig: routerConfig }



  componentDidUpdate: ->
    @state.uiDataChanged = false

  onEnter:(nextState) ->
    path = nextState.routes[1].name
    routerConfig = @state.routerConfig

    @currentRouteName = nextState.location.pathname

    routerConfig = @state.routerConfig



  render: () ->
    (<Router history={BrowserHistory} routes={@state.routerConfig}/>)

module.exports = ChiikaRouter
