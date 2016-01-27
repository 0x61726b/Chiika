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
React = require 'react'
ReactTabs = require 'react-tabs'
Tab = ReactTabs.Tab;
Tabs = ReactTabs.Tabs;
TabList = ReactTabs.TabList;
TabPanel = ReactTabs.TabPanel;

Helpers = require('./../Helpers')


WatchingList = require './AnimeList/Watching'
PlantoWatchList = require './AnimeList/PlantoWatch'
DroppedList = require './AnimeList/Dropped'
OnHoldList = require './AnimeList/OnHold'
CompletedList = require './AnimeList/Completed'

Tabs.setUseDefaultStyles(false)
AnimeList = React.createClass
  getInitialState: () ->
    selectedIndex: -1
    tabs:[
        { label:"Watching",element:"gridWatchingList" },
        { label:"Plan to Watch",element:"gridPlantoWatchList" },
        { label:"Completed",element:"gridCompletedList" },
        { label:"On Hold",element:"gridOnHoldList" },
        { label:"Dropped",element:"gridDroppedList" }
    ]
  render: () ->
    (<Tabs selectedIndex={this.props.startWithTabIndex} onSelect={this.props.onSelect} forceRenderTabPanel={false}>
        <TabList>
          {this.state.tabs.map((tab, i) =>
                <Tab key={i}>{tab.label}</Tab>
                )}
        </TabList>
        <TabPanel key={0}>
          <WatchingList />
        </TabPanel>
        <TabPanel key={1}>
          <PlantoWatchList />
        </TabPanel>
        <TabPanel key={2}>
          <CompletedList />
        </TabPanel>
        <TabPanel key={3}>
          <OnHoldList />
        </TabPanel>
        <TabPanel key={4}>
          <DroppedList />
        </TabPanel>
      </Tabs>);

module.exports = AnimeList
