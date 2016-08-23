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


_find                                   = require 'lodash/collection/find'
_forEach                                = require 'lodash.foreach'
_indexOf                                = require 'lodash/array/indexOf'
_remove                                 = require 'lodash/array/remove'
_assign                                 = require 'lodash.assign'
{ReactTabs,Tab,Tabs,TabList,TabPanel}   = require 'react-tabs'
LoadingScreen                           = require './loading-screen'
#Views

module.exports = React.createClass
  getInitialState: ->
    tabList: []
    tabLenghts:[]
    viewName: ""
    currentTabIndex: 0
    lastTabIndex: 0
    tabs: 'react'
    lowMemoryUsage: false

  diff: 0
  grids: []
  containerWidth: 0
  componentWillReceiveProps: (props) ->
    #document.title = @props.route.viewName  + "##{@state.currentTabIndex}"
    @uiItem = _find chiika.uiData, (o) => o.name == props.route.viewName

    if @props.route.viewName != props.route.viewName
      prevUIItem = _find chiika.uiData, (o) => o.name == @props.route.viewName
      toRemove = []
      _forEach @grids,(grid) =>
        findInPreviousTabList = _find prevUIItem.tabList, (o) => o.name == grid.name

        if findInPreviousTabList?
          toRemove.push grid.name

      _forEach toRemove, (val) =>
        findGrid = _find @grids, (o) => o.name == val

        if findGrid?
          findGrid.grid.clearAll()
          findGrid.grid = null
          _remove @grids,findGrid
          $(window).off 'resize'


    if chiika.appSettings.RememberScrollTabPosition
      tabCache = chiika.viewManager.getTabSelectedIndexByName(props.route.viewName)
      if @state.viewName != props.route.viewName
        @state.currentTabIndex = tabCache.index ? 0
    #
    dataSourceLengths = []
    _forEach @uiItem.tabList, (v,k) ->
      viewData = _find(chiika.viewData, (o) => o.name == props.route.viewName)
      gridData = _find(viewData.dataSource, (o) => o.name == v.name)

      dataSourceLengths.push gridData.data.length


    @setState { viewName: props.route.viewName,tabList: @uiItem.tabList, columnList: @uiItem.columns,lengths: dataSourceLengths }

  componentDidUpdate: ->
    # Did we create it before?
    findGrid = _find @grids, { name: @uiItem.tabList[@state.currentTabIndex].name }
    if !findGrid?
      @updateGrid(@uiItem.tabList[@state.currentTabIndex].name,@uiItem.columns,@props.route.viewName)




    #Get UI item
    #

    # if chiika.appSettings.RememberScrollTabPosition
    #   scroll = chiika.viewManager.getTabScrollAmount(@props.route.viewName,chiika.viewManager.getTabSelectedIndexByName(@props.route.viewName).index)
    #   $(".objbox").scrollTop(scroll)
    #
    #   if $('scrollPosition').length == 0
    #     $('head').append("<scrollPosition value='#{scroll}' />")
    #   else
    #     $('scrollPosition').attr('value',scroll)

  componentDidMount: ->
    # Hacks
    @componentWillReceiveProps(@props)

    $(".form-control").off 'input'
    $(".form-control").on 'input', (e) =>
      @filterGrids(e.target.value)



  filterGrids: (input) ->
    _forEach @grids, (grid) =>
      grid.grid.filterBy(1,input)

  updateGrid: (name,columnList,viewName) ->
    currentGrid = new dhtmlXGridObject(name)

    columnIdsForDhtml = ""
    columnTextForDhtml = ""
    columnInitWidths = ""
    columnAligns = ""
    columnSorting = ""
    headerAligns = []


    # Calculate container size
    if $("##{name}.objbox").scrollHeight > $("##{name} .objbox").height()
      totalArea = $("##{name} .objbox").width() - 20
    else
      totalArea = $("##{name} .objbox").width()

    if totalArea > 400
      @containerWidth = totalArea

    fixedColumnsTotal = 0


    _forEach columnList, (v,k) =>
      if v.width? && !v.hidden
        fixedColumnsTotal += parseInt(v.width)

    diff = @containerWidth - fixedColumnsTotal

    # For each column
    _forEach columnList, (v,k) =>
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

    # Set grid properties
    currentGrid.setInitWidths( columnInitWidths )
    currentGrid.setColumnIds( columnIdsForDhtml )
    currentGrid.setHeader(columnTextForDhtml,null,headerAligns)
    currentGrid.setColTypes( columnIdsForDhtml )
    currentGrid.setColAlign( columnAligns )
    currentGrid.setColSorting( columnSorting )
    currentGrid.enableMultiselect(true)

    # Find this grids data
    viewData = _find(chiika.viewData, (o) => o.name == viewName)
    gridData = _find(viewData.dataSource, (o) => o.name == name)

    gridConf = { data: gridData.data }

    currentGrid.init()
    currentGrid.parse gridConf,"js"
    @grids.push { name: name, grid: currentGrid }

    # Filter grid if the search box isnt exmpty
    if $(".form-control").val().length > 0
      currentGrid.filterBy(1,$(".form-control").val())
    # Sort rows based on the recorded sort info
    if chiika.appSettings.RememberSortingPreference
      sortInfo = chiika.viewManager.getTabSortInfo(viewName,chiika.viewManager.getTabSelectedIndexByName(viewName).index)
      if sortInfo?
        currentGrid.sortRows(sortInfo.column,sortInfo.type,sortInfo.direction)

    #
    #
    #


    #
    # After sorting, remember the sort preference of a particular tab
    #
    if chiika.appSettings.RememberSortingPreference
      currentGrid.attachEvent 'onAfterSorting', (index,type,direction) =>
        chiika.viewManager.onTabSorted(viewName,chiika.viewManager.getTabSelectedIndexByName(@props.route.viewName).index,index,type,direction)


    # When clicked, go to details
    currentGrid.attachEvent 'onRowDblClicked', (rId,cInd) =>
      for i in  [0...gridConf.data.length]
        if i == rId - 1
          find = gridConf.data[i]
          window.location = "##{viewName}_details/#{find.mal_id}"

    $(window).resize( =>
      if currentGrid?
        if $("##{name} .objbox").scrollHeight > $("##{name} .objbox").height()
          totalArea = $("##{name} .objbox").width() - 8
        else
          totalArea = $("##{name} .objbox").width()
        fixedColumnsTotal = 0

        _forEach @state.columnList, (v,k) =>
          if v.width? && !v.hidden
            fixedColumnsTotal += parseInt(v.width)

        diff = totalArea - fixedColumnsTotal

        for i in [0...@state.columnList.length]
          v = @state.columnList[i]
          if !v.hidden
            width = 0
            if v.widthP?
              width = diff * (v.widthP / 100)
            else
              width = v.width
            currentGrid.setColWidth(i,width.toString())
            )
    $(window).trigger('resize')



  componentWillMount: ->
    @uiItem = _find chiika.uiData, (o) => o.name == @props.route.viewName

    @grids = []

  clearGrids: ->
    _forEach @grids,(grid) =>
      grid.grid.clearAll()
      grid.grid = null


  componentWillUnmount: ->
    @clearGrids()

    chiika.viewManager.onTabSelect(@state.viewName,@state.currentTabIndex)
    chiika.viewManager.onTabViewUnmount(@state.viewName,@state.currentTabIndex)

    # scroll = chiika.viewManager.getTabScrollAmount(@state.viewName,@state.currentTabIndex)
    $(".form-control").off 'input'
    $(window).off 'resize'

  onSelect: (index,last) ->
    @setState { currentTabIndex: index, lastTabIndex: last }

    chiika.viewManager.onTabSelect(@state.viewName,index,last)


  renderReactTabs: ->
    <Tabs selectedIndex={@state.currentTabIndex} onSelect={@onSelect} forceRenderTabPanel={!@state.lowMemoryUsage}>
      <TabList>
        {@state.tabList.map((tab, i) =>
            <Tab key={i}>{tab.display} <span className="label raised theme-accent">{@state.lengths[i]}</span></Tab>
            )}
      </TabList>
      {
        @state.tabList.map (tab,i) =>
          <TabPanel key={i}>
            <div id="#{tab.name}" className="listCommon"></div>
          </TabPanel>
      }
    </Tabs>
  render: ->
    @renderReactTabs()
