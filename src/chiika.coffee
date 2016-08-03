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

TabGridView = require './view-tabGrid'

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
  render: ->
    <div id="appMain"><SideMenu /><Content props={this.props}/></div>


ChiikaRouter = React.createClass
  routes: []
  getInitialState: ->
    test: false
    uiData: chiika.uiData
    routerConfig: @getRoutes(chiika.uiData)

  getRoutes: (uiData) ->
    routes = []
    uiData.map (route,i) => routes.push {
      name: "/#{route.name}"
      path: "/#{route.name}"
      component:require(chiika.viewManager.getComponent(route.displayType))
      view: route
    }

    routerConfig = {
        component: RouterContainer,
        childRoutes: [
          { name:'Home', path: '/Home', component: Home }
        ]
    }
    for route in routes
      routerConfig.childRoutes.push route
    routerConfig
  renderSingleRoute: (route,i) ->
    <Route name={route.name} path={route.name} key={i} component={require(chiika.viewManager.getComponent(route.displayType))} view={route} onEnter={@onEnter}/>

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




  componentDidUpdate: ->
    @state.uiDataChanged = false

  componentDidMount: ->
    changeTest = =>
      routeConf = @state.routerConfig
      routeConf.childRoutes[2].test = true
      @setState { routerConfig: routeConf }

    #setTimeout(changeTest,3000)
  onEnter:(nextState) ->
    path = nextState.location.pathname

  render: () ->
    (<Router history={BrowserHistory} routes={@state.routerConfig}/>)

module.exports = ChiikaRouter
