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
{Router,Route,BrowserHistory,Link} = require('react-router')
{ReactTabs,Tab,Tabs,TabList,TabPanel} = require 'react-tabs'

WatchingList = require './al-watching'
PtwList = require './al-ptw'
CompletedList = require './al-completed'
OnHoldList = require './al-onhold'
DroppedList = require './al-dropped'

#Views

AnimeList = React.createClass
  getInitialState: () ->
    selectedIndex: -1
    tabs:[
        { index:0, label:"Watching",element:"gridWatchingList" },
        { index:1, label:"Plan to Watch",element:"gridPlantoWatchList" },
        { index:2, label:"Completed",element:"gridCompletedList" },
        { index:3, label:"On Hold",element:"gridOnHoldList" },
        { index:4, label:"Dropped",element:"gridDroppedList" }
    ]
  onSelect: ->

  componentDidMount: () ->

  render: () ->
    (<Tabs onSelect={this.onSelect}>
        <TabList>
          {this.state.tabs.map((tab, i) =>
                <Tab key={i}>{tab.label}</Tab>
                )}
        </TabList>
        <TabPanel key={0}>
          <WatchingList/>
        </TabPanel>
        <TabPanel key={1}>
          <PtwList/>
        </TabPanel>
        <TabPanel key={2}>
          <CompletedList/>
        </TabPanel>
        <TabPanel key={3}>
          <OnHoldList/>
        </TabPanel>
        <TabPanel key={4}>
          <DroppedList/>
        </TabPanel>
      </Tabs>)

module.exports = AnimeList
