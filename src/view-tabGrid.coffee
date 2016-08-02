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

React                                   = require('react')

_                                       = require 'lodash'
{ReactTabs,Tab,Tabs,TabList,TabPanel}   = require 'react-tabs'
#Views

module.exports = React.createClass
  getInitialState: ->
    tabList: []
    gridColumnList: []
    gridColumnData: []
    currentTabIndex: 0

  currentGrid: null
  componentWillMount: ->

  componentWillReceiveProps: (props) ->
    @setState { tabList: props.route.dataSource.tabList, gridColumnList: props.route.dataSource.gridColumnList, gridColumnData: props.route.gridColumnData }

  componentDidUpdate: ->
    @updateGrid(@state.tabList[@state.currentTabIndex] + "_grid")

  onSelect: (index,last) ->
    @setState { currentTabIndex: index }

  updateGrid: (name) ->
    if @currentGrid?
      @currentGrid.clearAll()
      @currentGrid = null
    @currentGrid = new dhtmlXGridObject(name)

    columnIdsForDhtml = ""
    columnTextForDhtml = ""
    columnInitWidths = ""
    columnAligns = ""
    columnSorting = ""

    totalArea = $(".objbox").width()
    fixedColumnsTotal = 0

    _.forEach @state.gridColumnList, (v,k) =>
      if v.width? && !v.hidden
        fixedColumnsTotal += parseInt(v.width)

    diff = totalArea - fixedColumnsTotal


    _.forEach @state.gridColumnList, (v,k) =>
      if !v.hidden
        columnIdsForDhtml += v.name + ","
        columnTextForDhtml += v.display + ","
        columnSorting += v.sort + ","
        columnAligns += v.align + ","

        if v.widthP?
          calculatedWidth = diff * (v.widthP / 100)
          columnInitWidths += calculatedWidth + ","
        else
          columnInitWidths += v.width + ","

    columnIdsForDhtml = columnIdsForDhtml.substring(0,columnIdsForDhtml.length - 1)
    columnTextForDhtml = columnTextForDhtml.substring(0,columnTextForDhtml.length - 1)
    columnInitWidths = columnInitWidths.substring(0,columnInitWidths.length - 1)
    columnSorting = columnSorting.substring(0,columnSorting.length - 1)
    columnAligns = columnAligns.substring(0,columnAligns.length - 1)


    @currentGrid.setInitWidths( columnInitWidths )
    @currentGrid.setColumnIds( columnIdsForDhtml )
    @currentGrid.setColSorting( columnSorting )
    @currentGrid.enableAutoWidth(true)
    @currentGrid.setHeader(columnTextForDhtml,null,["text-align:center;","text-align:left;","text-align:center;","text-align:center;","text-align:center;"]) #To-do move this to owner script
    @currentGrid.setColTypes( columnIdsForDhtml )
    @currentGrid.setColAlign( columnAligns )


    @currentGrid.enableMultiselect(true)

    gridData = _.find(@state.gridColumnData, (o) -> o.name == name)

    gridConf = { data: gridData.dataSource }


    @currentGrid.init()
    @currentGrid.parse gridConf,"js"

    $(window).resize( =>
      console.log "resize"
      totalArea = $(".objbox").width()
      fixedColumnsTotal = 0

      _.forEach @state.gridColumnList, (v,k) =>
        if v.width? && !v.hidden
          fixedColumnsTotal += parseInt(v.width)

      diff = totalArea - fixedColumnsTotal

      for i in [0...@state.gridColumnList.length]
        v = @state.gridColumnList[i]
        if !v.hidden
          width = 0
          if v.widthP?
            width = diff * (v.widthP / 100)
          else
            width = v.width
          @currentGrid.setColWidth(i,width)
          console.log "Setting col #{i} width #{width}"
          )

  componentWillUnmount: ->
    if @currentGrid?
      @currentGrid.clearAll()
      @currentGrid = null
  render: ->
    <Tabs selectedIndex={@state.currentTabIndex} onSelect={@onSelect}>
        <TabList>
          {@state.tabList.map((tab, i) =>
                <Tab key={i}>{tab} <span className="label raised theme-accent">0</span></Tab>
                )}
        </TabList>
        {
          @state.tabList.map (tab,i) =>
            <TabPanel key={i}>
              <div id="#{tab}_grid" className="listCommon"></div>
            </TabPanel>
        }
      </Tabs>
