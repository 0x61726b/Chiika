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


ReadingList = require './MangaList/Reading'
PlantoReadList = require './MangaList/PlantoRead'
DroppedList = require './MangaList/Dropped'
OnHoldList = require './MangaList/OnHold'
CompletedList = require './MangaList/Completed'

Tabs.setUseDefaultStyles(false)
MangaList = React.createClass
  getInitialState: () ->
    selectedIndex: -1
    tabs:[
        { label:"Reading",element:"gridMangaReadingList" },
        { label:"Plan to Read",element:"gridPlantoReadList" },
        { label:"Completed",element:"gridMangaCompletedList" },
        { label:"On Hold",element:"gridMangaOnHoldList" },
        { label:"Dropped",element:"gridMangaDroppedList" }
    ]
  render: () ->
    (<Tabs selectedIndex={this.props.startWithTabIndex} onSelect={this.props.onSelect} forceRenderTabPanel={false}>
        <TabList>
          {this.state.tabs.map((tab, i) =>
                <Tab key={i}>{tab.label}</Tab>
                )}
        </TabList>
        <TabPanel key={0}>
          <ReadingList />
        </TabPanel>
        <TabPanel key={1}>
          <PlantoReadList />
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

module.exports = MangaList
