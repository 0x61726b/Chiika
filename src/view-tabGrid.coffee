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
    tabs: 'dhtml'

  currentGrid: null
  scrollPending: false
  updated: false
  grids: []
  componentWillReceiveProps: (props) ->
    #document.title = @props.route.viewName  + "##{@state.currentTabIndex}"

    # if @props.route.viewName != props.route.viewName
    #   console.log "Changed from #{@props.route.viewName} to #{props.route.viewName}"
    #   @createTabAndGrids()
    #
    #   find = _find @grids, (o) => o.name == @props.route.viewName
    #   index = _indexOf @grids,find
    #
    #   @grids.splice()



    # if chiika.appSettings.RememberScrollTabPosition
    #   tabCache = chiika.viewManager.getTabSelectedIndexByName(props.route.viewName)
    #   if @state.viewName != props.route.viewName
    #     @state.currentTabIndex = tabCache.index
    #
    # dataSourceLengths = []

    # console.log "Hello -------- "
    # console.log props.route.view.children[0].dataSource[3]
    # uiItem = _find chiika.uiData, (o) => o.name == props.route.viewName
    #
    # _forEach uiItem.tabList, (v,k) ->
    #   viewData = _find(chiika.viewData, (o) => o.name == props.route.viewName)
    #   gridData = _find(viewData.dataSource, (o) => o.name == v.name)
    #
    #   dataSourceLengths.push gridData.data.length
    #
    #
    # @setState { viewName: props.route.viewName, tabList: uiItem.tabList, columns: uiItem.columns, tabLenghts: dataSourceLengths }


  componentDidUpdate: ->
    @uiItem = _find chiika.uiData, (o) => o.name == @props.route.viewName

    if @state.tabs == 'react'
      @updateGrid(@uiItem.tabList[@state.currentTabIndex].name,@uiItem.columns,@props.route.viewName)
    else
      @createTabAndGrids()

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

  createTabAndGrids: () ->
    if @tabbar?
      @tabbar.clearAll()
      @tabbar = null

    @tabbar = new dhtmlXTabBar("tabbar")

    @grids.push { name: @props.route.viewName }

    tabCache = chiika.viewManager.getTabSelectedIndexByName(@props.route.viewName)
    currentTabIndex = tabCache.index

    if !currentTabIndex?
      currentTabIndex = @uiItem.tabList[0].name

    for tab in @uiItem.tabList
      if tab.name == currentTabIndex
        @tabbar.addTab(tab.name, tab.display, null, null, true)
      else
        @tabbar.addTab(tab.name, tab.display)

    #@tabbar.enableAutoReSize(true)

    #document.title = @props.route.viewName  + "##{@state.currentTabIndex}"

    @tabbar.attachEvent 'onSelect', (index,last) =>
      if !@tabbar.tabs(index).getAttachedObject()?
        @updateGrid(index,@uiItem.columns,@props.route.viewName)

      chiika.viewManager.onTabSelect(@props.route.viewName,index,last)
      return true


    @updateGrid(@tabbar.getActiveTab(),@uiItem.columns,@props.route.viewName)

  componentDidMount: ->
    if @state.tabs == 'react'
      @updateGrid(@uiItem.tabList[0].name,@uiItem.columns,@props.route.viewName)
    else
      @createTabAndGrids()

  updateGrid: (name,columnList,viewName) ->
    if @state.tabs == 'dhtml'
      currentGrid = @tabbar.tabs(name).attachGrid()
    else if @state.tabs == 'react'
      currentGrid = new dhtmlXGridObject(name)



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


    _forEach columnList, (v,k) =>
      if v.width? && !v.hidden
        fixedColumnsTotal += parseInt(v.width)

    diff = totalArea - fixedColumnsTotal


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

    currentGrid.setInitWidths( columnInitWidths )
    currentGrid.setColumnIds( columnIdsForDhtml )
    currentGrid.setHeader(columnTextForDhtml,null,headerAligns)
    currentGrid.setColTypes( columnIdsForDhtml )
    currentGrid.setColAlign( columnAligns )
    currentGrid.setColSorting( columnSorting )


    currentGrid.enableMultiselect(true)

    viewData = _find(chiika.viewData, (o) => o.name == viewName)
    gridData = _find(viewData.dataSource, (o) => o.name == name)

    gridConf = { data: gridData.data }

    currentGrid.init()
    currentGrid.parse gridConf,"js"
    @grids.push { name: name, grid: currentGrid }

    # Sort rows based on the recorded sort info
    # if chiika.appSettings.RememberSortingPreference
    #   sortInfo = chiika.viewManager.getTabSortInfo(viewName,chiika.viewManager.getTabSelectedIndexByName(viewName).index)
    #   if sortInfo?
    #     currentGrid.sortRows(sortInfo.column,sortInfo.type,sortInfo.direction)

    #
    #
    #
    $(".form-control").on 'input', (e) =>
      currentGrid.filterBy(1,e.target.value)


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


    # $(window).resize( =>
    #   if currentGrid?
    #
    #     console.log "Resize"
    #
    #     @tabbar.setSizes()
    #     if $(".objbox")[0].scrollHeight > $(".objbox").height()
    #       totalArea = $(".objbox").width() - 8
    #     else
    #       totalArea = $(".objbox").width()
    #     fixedColumnsTotal = 0
    #
    #     _forEach @uiItem.columns, (v,k) =>
    #       if v.width? && !v.hidden
    #         fixedColumnsTotal += parseInt(v.width)
    #
    #     diff = totalArea - fixedColumnsTotal
    #
    #     for i in [0...@uiItem.columns.length]
    #       v = @uiItem.columns[i]
    #       if !v.hidden
    #         width = 0
    #         if v.widthP?
    #           width = diff * (v.widthP / 100)
    #         else
    #           width = v.width
    #         currentGrid.setColWidth(i,width.toString())
    #         )
    # $(window).trigger('resize')



  componentWillMount: ->
    @uiItem = _find chiika.uiData, (o) => o.name == @props.route.viewName

    @grids = []
  componentWillUnmount: ->
    if @state.tabs == 'dhtml'
      chiika.viewManager.onTabSelect(@props.route.viewName,@tabbar.getActiveTab())
      chiika.viewManager.onTabViewUnmount(@props.route.viewName,@tabbar.getActiveTab())

      @tabbar.clearAll()
      @tabbar.unload()
      @tabbar = null
    else if @state.tabs == 'react'
      _forEach @grids,(grid) =>
        grid.grid.clearAll()
        grid.grid = null

    # scroll = chiika.viewManager.getTabScrollAmount(@state.viewName,@state.currentTabIndex)
    $(".form-control").off 'input'
    $(window).off 'resize'
    # if @currentGrid?
    #   $(".form-control").off 'input'
    #   @currentGrid.clearAll()
    #   @currentGrid = null
  onSelect: (index,last) ->
    @setState { currentTabIndex: index, lastTabIndex: last }
  renderReactTabs: ->
    <Tabs selectedIndex={@state.currentTabIndex} onSelect={@onSelect} forceRenderTabPanel=true>
      <TabList>
        {@uiItem.tabList.map((tab, i) =>
              <Tab key={i}>{tab.display} <span className="label raised theme-accent">0</span></Tab>
              )}
      </TabList>
      {
        @uiItem.tabList.map (tab,i) =>
          <TabPanel key={i}>
            <div id="#{tab.name}" className="listCommon"></div>
          </TabPanel>
      }
  </Tabs>
  renderDhtmlTabbar: ->
    <div id="tabOuter">
      <div id="tabbar" style={{ width: '100%', height: '100%' }} />
    </div>
  render: ->
    if @state.tabs == 'react'
      @renderReactTabs()
    else if @state.tabs == 'dhtml'
      @renderDhtmlTabbar()
