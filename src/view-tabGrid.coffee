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
LoadingScreen = require './loading-screen'
#Views

module.exports = React.createClass
  getInitialState: ->
    tabList: []
    tabLenghts:[]
    viewName: ""
    currentTabIndex: 0
    lastTabIndex: 0

  currentGrid: null
  scrollPending: false
  componentWillReceiveProps: (props) ->
    document.title = @props.route.viewName  + "##{@state.currentTabIndex}"

    # Attach scroll position to HEAD

    tabCache = chiika.viewManager.getTabSelectedIndexByName(props.route.viewName)
    if @state.viewName != props.route.viewName
      @state.currentTabIndex = tabCache.index

    dataSourceLengths = []

    # console.log "Hello -------- "
    # console.log props.route.view.children[0].dataSource[3]
    uiItem = _.find chiika.uiData, (o) => o.name == props.route.viewName

    _.forEach uiItem.tabList, (v,k) ->
      viewData = _.find(chiika.viewData, (o) => o.name == props.route.viewName)
      gridData = _.find(viewData.dataSource, (o) => o.name == v.name)

      dataSourceLengths.push gridData.data.length


    @setState { viewName: props.route.viewName, tabList: uiItem.tabList, columns: uiItem.columns, tabLenghts: dataSourceLengths }




  componentDidUpdate: ->

    #Get UI item
    @updateGrid(@state.tabList[@state.currentTabIndex].name)
    #
    scroll = chiika.viewManager.getTabScrollAmount(@state.viewName,@state.currentTabIndex)
    $(".objbox").scrollTop(scroll)

    if $('scrollPosition').length == 0
      $('head').append("<scrollPosition value='#{scroll}' />")
    else
      $('scrollPosition').attr('value',scroll)

  componentDidMount: ->
    # Bad solution
    # Leave it for now
    # The reason for this,when navigated through goBack() or manually refresh , React wont feed the component with props
    # So the page appears blank
    @componentWillReceiveProps(@props)

    document.title = @props.route.viewName  + "##{@state.currentTabIndex}"

  onSelect: (index,last) ->
    @setState { currentTabIndex: index, lastTabIndex: last }
    chiika.viewManager.onTabSelect(@state.viewName,index,last)

    document.title = @state.viewName  + "##{index}"


  updateGrid: (name) ->
    if @currentGrid?
      @currentGrid.clearAll()
      @currentGrid = null
    @currentGrid = new dhtmlXGridObject(name)

    columnList = @state.columns

    columnIdsForDhtml = ""
    columnTextForDhtml = ""
    columnInitWidths = ""
    columnAligns = ""
    columnSorting = ""
    headerAligns = []

    if $(".objbox").scrollHeight > $(".objbox").height()
      totalArea = $(".objbox").width() - 20
    else
      totalArea = $(".objbox").width()
    fixedColumnsTotal = 0

    _.forEach columnList, (v,k) =>
      if v.width? && !v.hidden
        fixedColumnsTotal += parseInt(v.width)

    diff = totalArea - fixedColumnsTotal



    _.forEach columnList, (v,k) =>
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

    viewData = _.find(chiika.viewData, (o) => o.name == @state.viewName)
    gridData = _.find(viewData.dataSource, (o) => o.name == name)

    gridConf = { data: gridData.data }

    @currentGrid.init()
    @currentGrid.parse gridConf,"js"

    @currentGrid.filterBy(1,$(".form-control").val())

    for i in [0...columnList.length]
      column = columnList[i]
      if !column.hidden && column.customSort?
        @currentGrid.setCustomSorting(window.sortFunctions[v.customSort],i)

    $(".form-control").on 'input', (e) =>
      @currentGrid.filterBy(1,e.target.value)

    @currentGrid.attachEvent 'onRowDblClicked', (rId,cInd) =>
      for i in  [0...gridConf.data.length]
        if i == rId - 1
          find = gridConf.data[i]
          window.location = "##{@state.viewName}_details/#{find.mal_id}"

    $(window).resize( =>
      if @currentGrid?
        if $(".objbox")[0].scrollHeight > $(".objbox").height()
          totalArea = $(".objbox").width() - 8
        else
          totalArea = $(".objbox").width()
        fixedColumnsTotal = 0

        _.forEach @state.columns, (v,k) =>
          if v.width? && !v.hidden
            fixedColumnsTotal += parseInt(v.width)

        diff = totalArea - fixedColumnsTotal

        for i in [0...@state.columns.length]
          v = @state.columns[i]
          if !v.hidden
            width = 0
            if v.widthP?
              width = diff * (v.widthP / 100)
            else
              width = v.width
            @currentGrid.setColWidth(i,width)
            )
    $(window).trigger('resize')

  componentWillUnmount: ->
    chiika.viewManager.onTabSelect(@state.viewName,@state.currentTabIndex)
    chiika.viewManager.onTabViewUnmount(@state.viewName,@state.currentTabIndex)
    scroll = chiika.viewManager.getTabScrollAmount(@state.viewName,@state.currentTabIndex)

    if @currentGrid?
      $(".form-control").off 'input'
      @currentGrid.clearAll()
      @currentGrid = null
  render: ->
    <Tabs selectedIndex={@state.currentTabIndex} onSelect={@onSelect}>
        <TabList>
          {@state.tabList.map((tab, i) =>
                <Tab key={i}>{tab.display} <span className="label raised theme-accent">{ @state.tabLenghts[i]}</span></Tab>
                )}
        </TabList>
        {
          @state.tabList.map (tab,i) =>
            <TabPanel key={i}>
              <div id="#{tab.name}" className="listCommon"></div>
            </TabPanel>
        }
      </Tabs>
