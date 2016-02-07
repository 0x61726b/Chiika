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

ContextMenu = require './AnimeList/ContextMenu'

WatchingList = require './AnimeList/Watching'
PlantoWatchList = require './AnimeList/PlantoWatch'
DroppedList = require './AnimeList/Dropped'
OnHoldList = require './AnimeList/OnHold'
CompletedList = require './AnimeList/Completed'


Chiika = require './../../ChiikaNode'
fs = require 'fs'

Tabs.setUseDefaultStyles(false)
AnimeList = React.createClass
  contextMenu:null
  columnArray:[]
  loadColumnData: ->
    columnData =
      [
        {column: { name:"typeWithIcon",order:0} },
        {column: { name:"title",order:1} },
        {column: { name:"score",order:2} },
        {column: { name:"season",order:4 }},
        {column: { name:"progress",order:3 }},
      ]
    #fs.appendFile Chiika.chiikaNode.rootOptions.modulePath + "Data/column.json",JSON.stringify(columnData), (err) => console.log err

    columnDataPath = Chiika.chiikaNode.rootOptions.modulePath+'Data/column.json'

    columnFileJson = []
    try
      file = fs.statSync(columnDataPath)
      bf = fs.readFileSync columnDataPath,'utf8'
      columnFileJson = JSON.parse(bf)
    catch error
      stream = fs.createWriteStream(columnDataPath)

      stream.once 'open', (fd) =>
        stream.write JSON.stringify columnData
        stream.end('')
      columnFileJson = columnData

    @columnArray = []
    for val in columnFileJson
      @columnArray.push val.column


  getColumnArray: ->
    @columnArray
  getInitialState: () ->
    selectedIndex: -1
    tabs:[
        { index:0, label:"Watching",element:"gridWatchingList" },
        { index:1, label:"Plan to Watch",element:"gridPlantoWatchList" },
        { index:2, label:"Completed",element:"gridCompletedList" },
        { index:3, label:"On Hold",element:"gridOnHoldList" },
        { index:4, label:"Dropped",element:"gridDroppedList" }
    ]
  componentWillMount: ->
    @loadColumnData()
  componentDidMount: ->

    startingIndex = this.props.startWithTabIndex
    result = $.grep(@state.tabs, (e) -> return e.index == startingIndex )
    
  onSelect: (index,last) ->
    result = $.grep(@state.tabs, (e) -> return e.index == index )
    gridName = result[0].element
    @contextMenu.onSelect gridName

    this.props.onSelect index,last
  render: () ->
    (<Tabs selectedIndex={this.props.startWithTabIndex} onSelect={this.onSelect} forceRenderTabPanel={false}>
        <TabList>
          {this.state.tabs.map((tab, i) =>
                <Tab key={i}>{tab.label}</Tab>
                )}
        </TabList>
        <TabPanel key={0}>
          <WatchingList columns={@getColumnArray()} />
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
