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
    tabDataSourceLenghts: []
    gridColumnList: []
    gridColumnData: []
    currentTabIndex: 0
    scrollData: []
    view: {name: ''}

  currentGrid: null
  scrollPending: false
  componentWillMount: ->

  componentWillReceiveProps: (props) ->
    console.log props.route
    tabCache = chiika.viewManager.getTabSelectedIndexByName(props.route.view.name)
    if @state.view.name != props.route.view.name
      @state.currentTabIndex = tabCache.index

    dataSourceLengths = []

    _.forEach props.route.view.TabGridView.tabList, (v,k) ->
      name =  v.name

      findInDataSource = _.find(props.route.view.children, (o) -> o.name == name + "_grid")
      dataSourceLengths.push findInDataSource.dataSource.length

    # console.log "Hello -------- "
    # console.log props.route.view.children[0].dataSource[3]

    @setState {
      tabList: props.route.view.TabGridView.tabList,
      gridColumnData: props.route.view.children,
      view: props.route.view,
      tabDataSourceLenghts: dataSourceLengths }
  componentDidUpdate: ->
    @updateGrid(@state.tabList[@state.currentTabIndex].name + "_grid")

    scroll = chiika.viewManager.getTabScrollAmount(@state.view.name,@state.currentTabIndex)
    $(".objbox").scrollTop(scroll)


  onSelect: (index,last) ->
    @setState { currentTabIndex: index }
    chiika.viewManager.onTabSelect(@state.view.name,index,last)


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
    headerAligns = []

    totalArea = $(".objbox").width()
    fixedColumnsTotal = 0

    _.forEach @state.view.TabGridView.gridColumnList, (v,k) =>
      if v.width? && !v.hidden
        fixedColumnsTotal += parseInt(v.width)

    diff = totalArea - fixedColumnsTotal


    _.forEach @state.view.TabGridView.gridColumnList, (v,k) =>
      if !v.hidden
        columnIdsForDhtml += v.name + ","
        columnTextForDhtml += v.display + ","
        columnSorting += v.sort + ","
        columnAligns += v.align + ","
        headerAligns.push "text-align: #{v.headerAlign};"

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
    @currentGrid.enableAutoWidth(true)
    @currentGrid.setHeader(columnTextForDhtml,null,headerAligns)
    @currentGrid.setColTypes( columnIdsForDhtml )
    @currentGrid.setColAlign( columnAligns )
    @currentGrid.setColSorting( columnSorting )


    @currentGrid.enableMultiselect(true)

    gridData = _.find(@state.gridColumnData, (o) -> o.name == name)

    gridConf = { data: gridData.dataSource }


    @currentGrid.init()
    @currentGrid.parse gridConf,"js"


    $(window).resize( =>
      if @currentGrid?
        totalArea = $(".objbox").width()
        fixedColumnsTotal = 0

        _.forEach @state.view.TabGridView.gridColumnList, (v,k) =>
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
            )

  componentWillUnmount: ->
    #chiika.viewManager.onTabSelect(@props.route.view.name,@state.currentTabIndex)
    chiika.viewManager.onTabViewUnmount(@state.view.name)
    if @currentGrid?
      @currentGrid.clearAll()
      @currentGrid = null
  render: ->
    <Tabs selectedIndex={@state.currentTabIndex} onSelect={@onSelect}>
        <TabList>
          {@state.tabList.map((tab, i) =>
                <Tab key={i}>{tab.display} <span className="label raised theme-accent">{@state.tabDataSourceLenghts[i]}</span></Tab>
                )}
        </TabList>
        {
          @state.tabList.map (tab,i) =>
            <TabPanel key={i}>
              <div id="#{tab.name}_grid" className="listCommon"></div>
            </TabPanel>
        }
      </Tabs>
