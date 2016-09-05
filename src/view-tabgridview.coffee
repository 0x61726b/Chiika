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
remote                                  = require('electron').remote
{MenuItem}                              = require('electron').remote
_find                                   = require 'lodash/collection/find'
_forEach                                = require 'lodash.foreach'
_indexOf                                = require 'lodash/array/indexOf'
_remove                                 = require 'lodash/array/remove'
_assign                                 = require 'lodash.assign'
{ReactTabs,Tab,Tabs,TabList,TabPanel}   = require 'react-tabs'
Loading                                 = require './loading'
ReactList                               = require 'react-list'
Sortable                                = require 'react-sortablejs'
moment                                  = require 'moment'

module.exports = React.createClass
  getInitialState: ->
    index: 0
    lastKnownTabIndex: 0
    header: null
    tabs: []
    lengths: []
    columns: []
    state: 0 # Loading
    viewName: @props.route.viewName

  componentWillMount: ->
    @prepare(@state.viewName)

  componentDidMount: ->
    # Table features

    #Dev
    #@componentWillReceiveProps(@props)

    @refreshData = chiika.emitter.on 'view-refresh', (params) =>
      if params.view == @state.viewName
        data   = @constructData(@state.viewName,@state.index)
        @setState { data: data }

    $("#gridSearch").on 'input', (e) =>
      @filter(e.target.value)

  componentWillUnmount: ->
    @refreshData.dispose()
    $("#gridSearch").off 'input'
  #ve
  #
  componentDidUpdate: ->
    uiItem = _find chiika.uiData, (o) => o.name == @state.viewName

    sortingPrefCol = uiItem.sortingPrefCol
    sortingPrefDir = uiItem.sortingPrefDir

    if $(".list-item-expanded").length > 0
      $(".list-item-expanded").slideDown()


  #
  #
  #
  componentWillReceiveProps: (props) ->
    @prepare(props.route.viewName)
  #
  #
  #
  prepare: (viewName) ->
    if @state.state == 1 && @state.viewName == viewName
      return
    chiika.logger.renderer("TabGridView - ViewName: #{viewName}")

    newViewName = viewName
    uiItem = _find chiika.uiData, (o) => o.name == newViewName

    header = @constructHeader(newViewName)
    tabs   = @constructTabs(newViewName).tabs
    lengths = @constructTabs(newViewName).lengths
    columns = @constructColumns(newViewName)
    data    = @constructData(newViewName,uiItem.displayConfig.lastTabIndex)
    sortingPrefDir = uiItem.displayConfig.sortingPrefDir
    sortingPrefCol = uiItem.displayConfig.sortingPrefCol
    findCol = _find uiItem.displayConfig.gridColumnList, (o) -> o.name == sortingPrefCol

    if !findCol?
      findCol = _find uiItem.displayConfig.gridColumnList, (o) -> o.name == "#{sortingPrefCol}Text"

    sortingType    = findCol.sort
    sortOrder = true
    if sortingPrefDir == "dsc"
      sortOrder = false



    data = @sort(data,sortingType,sortOrder,sortingPrefCol)

    state =
      header: header
      viewName: viewName
      tabs: tabs
      lengths:lengths
      columns: columns
      data:data
      state: 1
      index: uiItem.displayConfig.lastTabIndex
      sortingPrefDir: sortingPrefDir
      sortingPrefCol: sortingPrefCol
      sortingType: sortingType


    if @isMounted()
      @setState state
    else
      @state = state

  #
  #
  #
  onSelect: (index,last) ->

    uiItem = _find chiika.uiData, (o) => o.name == @state.viewName
    uiItem.displayConfig.lastTabIndex = index
    chiika.viewManager.saveTabGridViewState(uiItem)

    if chiika.getOption('RememberSortingPreference')
      data    = @constructData(@state.viewName,index)

      data = @sort(data,@state.sortingType,@state.sortingPrefDir,@state.sortingPrefCol)
      @setState { index: index,data:data }
    else
      data    = @constructData(@state.viewName,index)
      @setState { index: index,data:data}


  #
  #
  #
  constructHeader: (viewName) ->
    uiItem = _find chiika.uiData, (o) => o.name == viewName
    columnList = uiItem.displayConfig.gridColumnList
    headers = []

    _forEach columnList, (column) =>
      if !column.hidden
        headers.push { text: column.display, class: "header-#{column.name}" }

    headers

  #
  #
  #
  constructTabs: (viewName) ->
    uiItem = _find chiika.uiData, (o) => o.name == viewName
    tabs = uiItem.displayConfig.tabList

    dataLenghts = []

    viewData = _find(chiika.viewData, (o) => o.name == viewName)
    _forEach tabs,(tab) =>
      findDataSource = _find viewData.dataSource, (o) -> o.name == tab.name
      gridData = _find(viewData.dataSource, (o) => o.name == findDataSource.name)
      dataLenghts.push gridData.data.length

    return { tabs: tabs,lengths: dataLenghts }

  #
  #
  #
  constructColumns: (viewName) ->
    uiItem = _find chiika.uiData, (o) => o.name == viewName
    columns = uiItem.displayConfig.gridColumnList


    notHiddenColumns = []
    _forEach columns, (column) ->
      if !column.hidden
        notHiddenColumns.push column

    notHiddenColumns

  #
  #
  #
  constructData: (viewName,index) ->
    uiItem = _find chiika.uiData, (o) => o.name == viewName
    viewData = _find(chiika.viewData, (o) => o.name == viewName)

    findDataSource = _find viewData.dataSource, (o) -> o.name == uiItem.displayConfig.tabList[index].name
    gridData = _find(viewData.dataSource, (o) => o.name == findDataSource.name)
    _forEach gridData.data, (data) =>
      _assign data, { expanded: false }
    gridData.data

  #
  #
  #
  filter: (data) ->
    data = data.toLowerCase()
    uiItem = _find chiika.uiData, (o) => o.name == @state.viewName
    columns = uiItem.displayConfig.gridColumnList


    filterByTitle = (value) ->
      value[columns[1].name].toLowerCase().indexOf(data) > -1

    data = @constructData(@state.viewName,@state.index).filter(filterByTitle)
    @setState { data: data }

  #
  #
  #
  sort: (data,type,order,column) ->
    switch type
      when 'int'
        data.sort (a,b) =>
          a = parseInt(a[column])
          b = parseInt(b[column])
          if a > b
            return (if order then (1) else (-1))
          else if b > a
            return (if order then (-1) else (1))
          else if a == b
            return 0
      when 'float'
        data.sort (a,b) =>
          if parseFloat(a[column]) > parseFloat(b[column])
            return (if order then (1) else (-1))
          else if b > a
            return (if order then (-1) else (1))
          return 0
      when 'str'
        data.sort (a,b) =>
          a = a[column].toLowerCase()
          b = b[column].toLowerCase()

          if a > b
            return (if order then (1) else (-1))
          else if b > a
            return (if order then (-1) else (1))
          return 0

      when 'date'
        data.sort (a,b) =>
          a = moment(a[column],'YYYY/MM/DD')
          b = moment(b[column],'YYYY/MM/DD')

          if a.isAfter(b)
            return (if order then (1) else (-1))
          else if b.isAfter(a)
            return (if order then (1) else (-1))
          return 0


    data

  #
  #
  #
  listItemClick: (e,index) ->
    $("#chiika-list").find(".list-item").each (e) ->
      $(this).removeClass "selected"
    $(e.target).parent().toggleClass "selected"

    @state.data[index].expanded = !@state.data[index].expanded
    @state.data.splice(index,1,@state.data[index])

    if @state.data[index].expanded == false
      $(e.target).parent().parent().find(".list-item-expanded").slideToggle "slow", =>
        @setState { data: @state.data }
    else
      @setState { data: @state.data }


  #
  #
  #
  listItemDblClick: (e,index) ->
    data = @state.data[index]
    window.location = "##{@state.viewName}_details/#{data.id}"


  #
  #
  #
  headerClick: (e,col) ->
    tag =  $(e.target).prop('tagName')

    if tag == 'SPAN'
      # Sorting
      sortType = col.sort
      orderAsc = $(e.target).parent().hasClass("order-asc")
      orderDsc = $(e.target).parent().hasClass("order-dsc")
      name     = col.name

      if orderAsc
        $(e.target).parent().removeClass "order-asc"
        $(e.target).parent().addClass "order-dsc"

      if orderDsc
        $(e.target).parent().removeClass "order-dsc"
        $(e.target).parent().addClass "order-asc"

      data = @state.data

      if name.lastIndexOf('Text') > -1
        name = name.substring(0,name.lastIndexOf('Text'))

      chiika.logger.info("Sorting #{name} - #{sortType} - #{orderAsc} - #{orderDsc}")

      if chiika.getOption('RememberSortingPreference')
        uiItem = _find chiika.uiData, (o) => o.name == @state.viewName
        uiItem.displayConfig.sortingPrefDir = if !orderAsc then "asc" else "dsc"
        uiItem.displayConfig.sortingPrefCol = name

        chiika.viewManager.saveTabGridViewState(uiItem)

        @setState { data: @sort(data,sortType,!orderAsc,name), sortingPrefDir:uiItem.displayConfig.sortingPrefDir,sortingPrefCol: uiItem.displayConfig.sortingPrefCol,sortingType: sortType  }
      else
        @setState { data: @sort(data,sortType,!orderAsc,name) }




  #
  #
  #
  headerContextMenu: (e,col) ->
    uiItem = _find chiika.uiData, (o) => o.name == @state.viewName
    onClick = (menuItem,browserWindow,event) =>
      if menuItem.type == 'checkbox'
        column = _find uiItem.displayConfig.gridColumnList, (o) -> o.display == menuItem.label
        column.hidden = !column.hidden
        @setState { columns: @constructColumns(@state.viewName) }
        chiika.viewManager.saveTabGridViewState(uiItem)

    menuItems = []
    _forEach uiItem.displayConfig.gridColumnList,(column) =>
      if column.display?
        menuItems.push new MenuItem( { type: 'checkbox', label: "#{column.display}",checked: !column.hidden,click: onClick})
    chiika.popupContextMenu(menuItems)

  #
  #
  #
  itemContextMenu: (e,index) ->
    item = @state.data[index]

    onDeleteFromList = (menuItem,browserWindow,event) =>
      chiika.listManager.deleteFromList('anime',item.id,'myanimelist')

    onSearch = (menuItem,browserWindow,event) =>
      chiika.searchManager.searchAndGo(item.animeTitle,'list-remote','anime',"#{@state.viewName}")

    menuItems = []
    menuItems.push new MenuItem( { type: 'normal', label: "#{item.id}", enabled: false })
    menuItems.push new MenuItem( { type: 'separator'})
    menuItems.push new MenuItem( { type: 'normal', label: "Delete from list", click: onDeleteFromList })
    menuItems.push new MenuItem( { type: 'normal', label: "Search", click: onSearch })
    chiika.popupContextMenu(menuItems)


  #
  #
  #
  render: ->
    if @state.state == 0
      <Loading />
    else
      @renderTabs()

  renderExpanded: (index,key) ->
    <div className="hidden list-item-expanded">
      <div>
        <div className="expanded-cover">
        </div>
        <div className="expanded-meta">
          <div className="meta-row">
            <h5>Rate</h5>
            <div className="expanded-rate">
              <span>1</span>
              <span>2</span>
              <span>3</span>
              <span className="selected">4</span>
              <span>5</span>
              <span>6</span>
              <span>7</span>
              <span>8</span>
              <span>9</span>
              <span>10</span>
            </div>
          </div>
          <div className="meta-row">
            <h5>Watch</h5>
            <div className="expanded-watch">
              <span className="watched">6</span>
              <span className="watched">7</span>
              <span className="watched">8</span>
              <span className="aired">9</span>
            </div>
          </div>
          <div className="meta-row">
            <h5>More</h5>
            <div className="expanded-more">
              <span className="button orange">Check Torrents</span>
              <span className="button indigo">View on Web</span>
              <span className="button green">Open Library</span>
              <span className="button red">Open Details</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  #
  #
  #
  renderSingleItem: (index,key) ->
    <div key={key}>
      <div className="list-item #{if @state.data[index]? && @state.data[index].expanded then 'expanded' else ''}" onClick={(e) => @listItemClick(e,index)} onDoubleClick={ (e) => @listItemDblClick(e,index)} onContextMenu={ (e) => @itemContextMenu(e,index)}>
        {
          @state.columns.map (col,i) =>
            <div className="col-list col-#{col.name}" key={i}>
              {
                if window["#{@state.viewName}_#{col.name}"]?
                  window["#{@state.viewName}_#{col.name}"](@state.data[index][col.name])
                else
                  @state.data[index][col.name]
              }
            </div>
        }
      </div>
      {
        if @state.data[index]? && @state.data[index].expanded
          window["#{@state.viewName}_expanded"](@state.data[index])
      }
    </div>

  #
  #
  #
  renderHeader: (index) ->
    <div className="chiika-header" key={index}>
    {
        @state.columns.map (col,i) =>
          <div className="header-title col-#{col.name} order-#{@state.sortingPrefDir}" onContextMenu={ (e) => @headerContextMenu(e,col)} onClick={ (e) => @headerClick(e,col)} key={i}><span>{col.display}</span></div>
    }
    </div>

  #
  #
  #
  renderTabs: ->
    <Tabs onSelect={@onSelect} selectedIndex={@state.index}>
      <TabList>
        {@state.tabs.map (tab, i) =>
            <Tab key={i}>{tab.display} <span className="label raised primary">{@state.lengths[i]}</span></Tab>
            }
      </TabList>
      {
        @state.tabs.map (tab,i) =>
          <TabPanel key={i}>
          {
            @renderHeader(i)
          }
          {
              <div style={{'overflow':'overlay',height: '100%'}} id="chiika-list">
                <ReactList itemRenderer={@renderSingleItem} length={@state.data.length} type='simple' />
              </div>
          }
          </TabPanel>
      }
    </Tabs>
