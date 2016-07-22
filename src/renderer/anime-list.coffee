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


AnimeListViewCompact = require './al-list-view-compact'
AnimeListViewAlternate = require './al-list-view-alternate'

_ = require 'lodash'

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
    currentView:0 # 1 for compact, 1 for alternate
  onSelect: (index,last) ->
    chiika.emitter.emit 'animelist-stab-changed', { index: index, last: last }
  setListCounts: ->
    watching = window.chiika.getAnimeListByType(1)
    ptw = window.chiika.getAnimeListByType(6)
    completed = window.chiika.getAnimeListByType(2)
    onhold = window.chiika.getAnimeListByType(3)
    dropped = window.chiika.getAnimeListByType(4)
    @state.tabs[0].length = watching.length
    @state.tabs[1].length = ptw.length
    @state.tabs[2].length = completed.length
    @state.tabs[3].length = onhold.length
    @state.tabs[4].length = dropped.length

    @forceUpdate()
  ipcCall: ->
    @doReady()
  doReady: ->
    @setListCounts()

    if chiika.appOptions.UseAlternateListView
      @state.currentView = 1

  componentWillMount: ->
    window.chiika.ipcListeners.push this

    if !window.chiika.isWaiting
      @doReady()
  componentWillUnmount: ->
    _.pull window.chiika.ipcListeners,this
  render: () ->
    (<Tabs onSelect={this.onSelect}>
        <TabList>
          {this.state.tabs.map((tab, i) =>
                <Tab key={i}>{tab.label} <span className="label raised theme-accent">{tab.length}</span></Tab>
                )}
        </TabList>
        <TabPanel key={0}>
        {
          if @state.currentView == 1
            <AnimeListViewAlternate name='watching' listStatus=1 />
          else
            <AnimeListViewCompact name='watching' listStatus=1 />
        }
        </TabPanel>
        <TabPanel key={1}>
          <AnimeListViewCompact name='ptw' listStatus=6 />
        </TabPanel>
        <TabPanel key={2}>
          <AnimeListViewCompact name='completed' listStatus=2 />
        </TabPanel>
        <TabPanel key={3}>
          <AnimeListViewCompact name='onhold' listStatus=3 />
        </TabPanel>
        <TabPanel key={4}>
          <AnimeListViewCompact name='dropped' listStatus=4 />
        </TabPanel>
      </Tabs>)

module.exports = AnimeList
