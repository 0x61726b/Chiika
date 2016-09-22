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
_forEach                                = require 'lodash/collection/forEach'
_indexOf                                = require 'lodash/array/indexOf'
_remove                                 = require 'lodash/array/remove'
_assign                                 = require 'lodash.assign'
_cloneDeep                              = require 'lodash.clonedeep'
{ReactTabs,Tab,Tabs,TabList,TabPanel}   = require 'react-tabs'
Loading                                 = require './loading'
ReactList                               = require 'react-list'
moment                                  = require 'moment'

module.exports = React.createClass
  getInitialState: ->
    index: 0
    lastKnownTabIndex: 0
    header: null
    tabs: []
    lengths: []
    columns: []
    data: []
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
        @prepare(params.view,true)

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

    # if $(".list-item-expanded").length > 0
    #   $(".list-item-expanded").slideDown()

    for i in [0...@state.data.length]
      d = @state.data[i]
      if d.expanded
        element = $("#chiika-list div")
        children = element.children()
        child    = children[i]


        #$(child).find(".list-item").toggleClass "selected"

        if !$(child).hasClass("expanded")
          $(child).find(".list-item-expanded").slideDown 500,->
            $(child).toggleClass "expanded"





  #
  #
  #
  componentWillReceiveProps: (props) ->
    @prepare(props.route.viewName)
  #
  #
  #
  prepare: (viewName,force) ->
    if !force?
      force = false

    if !force && @state.state == 1 && @state.viewName == viewName
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

      sortAsc = null
      if @state.sortingPrefDir == "asc"
        sortAsc = true
      else
        sortAsc = false
      data = @sort(data,@state.sortingType,sortAsc,@state.sortingPrefCol)
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
    for i in [0...gridData.data.length]
      expand = false
      select = false
      if @state.data.length > 0
        find = _find @state.data, (o) -> o.id == gridData.data[i].id
        if find?
          expand = find.expanded
          select = find.selected

      _assign gridData.data[i], { expanded: expand }
      _assign gridData.data[i], { selected: select }
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
    chiika.logger.info("Sorting #{column} - #{type} - #{order}")
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
          else if parseFloat(a[column]) < parseFloat(b[column])
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
            return (if order then (-1) else (1))
          return 0


    data


  dexpand: (index) ->
    element = $("#chiika-list div")
    children = element.children()
    child    = children[index]

    if $(child).find(".list-item").hasClass "selected"
      $(child).find(".list-item").toggleClass "selected"
    $(child).find(".list-item-expanded").slideToggle 400,->
      $(child).toggleClass "expanded"

  select: (index) ->
    element = $("#chiika-list div")
    children = element.children()
    child    = children[index]

    $(child).find(".list-item").toggleClass "selected"




  #
  #
  #
  listItemClick: (e,index) ->
    # if !e.ctrlKey
    #   # De select everything
    #
    # if e.ctrlKey
    #   @select(index)

    if $(e.target).hasClass("prevent-expand")
      return

    if !e.ctrlKey
      newExpandState = !@state.data[index].expanded
      newSelectState = !@state.data[index].selected
      old            = @state.data[index]
      old.expanded = newExpandState
      old.selected = newSelectState
      @state.data.splice(index,1,old)

      if !newExpandState
        @dexpand(index)
      else
        @setState { }


  #
  #
  #
  listItemDblClick: (e,index) ->
    data = @state.data[index]
    #window.location = "##{@state.viewName}_details/#{data.id}"


  #
  #
  #
  headerClick: (e,col) ->
    tag =  $(e.target).prop('tagName')

    if tag == 'SPAN'
      # Sorting
      sortType = col.sort
      name     = col.name
      lastSort = @state.sortingPrefDir

      if name.lastIndexOf('Text') > -1
        name = name.substring(0,name.lastIndexOf('Text'))

      thisSort = ""

      if lastSort == "asc"
        thisSort = "dsc"
      else
        thisSort = "asc"

      sortAsc = null
      if thisSort == "asc"
        sortAsc = true
      else
        sortAsc = false
      @setState { data: @sort(@state.data,sortType,sortAsc,name), sortingPrefDir: thisSort,sortingPrefCol: name, sortingType: sortType }

      if chiika.getOption('RememberSortingPreference')
        uiItem = _find chiika.uiData, (o) => o.name == @state.viewName
        uiItem.displayConfig.sortingPrefDir = thisSort
        uiItem.displayConfig.sortingPrefCol = name

        chiika.viewManager.saveTabGridViewState(uiItem)


      # orderAsc = $(e.target).parent().hasClass("order-asc")
      # orderDsc = $(e.target).parent().hasClass("order-dsc")
      # name     = col.name
      #
      # if orderAsc
      #   $(e.target).parent().removeClass "order-asc"
      #   $(e.target).parent().addClass "order-dsc"
      #
      # if orderDsc
      #   $(e.target).parent().removeClass "order-dsc"
      #   $(e.target).parent().addClass "order-asc"
      #
      # data = @state.data
      #
      # if name.lastIndexOf('Text') > -1
      #   name = name.substring(0,name.lastIndexOf('Text'))
      #
      # chiika.logger.info("Sorting #{name} - #{sortType} - #{orderAsc} - #{orderDsc}")
      #
      # if chiika.getOption('RememberSortingPreference')
      #   uiItem = _find chiika.uiData, (o) => o.name == @state.viewName
      #   uiItem.displayConfig.sortingPrefDir = if !orderAsc then "asc" else "dsc"
      #   uiItem.displayConfig.sortingPrefCol = name
      #
      #   chiika.viewManager.saveTabGridViewState(uiItem)
      #
      #   @setState { data: @sort(data,sortType,!orderAsc,name), sortingPrefDir:uiItem.displayConfig.sortingPrefDir,sortingPrefCol: uiItem.displayConfig.sortingPrefCol,sortingType: sortType  }
      # else
      #   @setState { data: @sort(data,sortType,!orderAsc,name) }




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

    window["#{@state.viewName}_contextMenu"](item)

    # chiika.popupContextMenu(menuItems)

  columnAction: (action,params) ->
    if action == 'score-update'
      e     = params.e
      id    = params.id
      score = parseFloat(params.score)
      column = params.column
      type   = params.type
      owner = params.owner

      findEntry = _find @state.data, (o) -> o.id == id
      if findEntry?
        oldScore = parseFloat(findEntry[column])

        if score != oldScore
          findEntry[column] = score
          @setState {}

          chiika.listManager.updateScore('anime',id,owner,
          { current: score },@props.route.viewName)

    if action == "progress-update"
      current = parseInt(params.current)
      total   = parseInt(params.total)
      column  = params.column
      id      = params.id
      owner   = params.owner

      if current > total
        return

      if current < 0
        return


      findEntry = _find @state.data, (o) -> o.id == id
      if findEntry?
        findEntry[column] = current
        @setState { }

        chiika.listManager.updateProgress('anime',id,owner,
        { title: "Episodes",current: current, total: total },@props.route.viewName)


  #
  #
  #
  render: ->
    if @state.state == 0
      <Loading />
    else
      @renderTabs()
  #
  #
  #
  renderSingleItem: (index,key) ->
    <div key={key}>
      <div
      className="list-item #{if @state.data[index].listBorderColor? then @state.data[index].listBorderColor else ''}"
      onClick={(e) => @listItemClick(e,index)}
      onDoubleClick={ (e) => @listItemDblClick(e,index)}
      onContextMenu={ (e) => @itemContextMenu(e,index)}>
        {
          @state.columns.map (col,i) =>
            <div className="col-list col-#{col.name} #{if col.css? then col.css else ''}" key={i}>
              {
                if window["#{@state.viewName}_#{col.name}"]?
                  window["#{@state.viewName}_#{col.name}"](@state.data[index],@columnAction)
                else
                  @state.data[index][col.name]
              }
            </div>
        }
      </div>
      {
        if @state.data[index]? && @state.data[index].expanded
          window["#{@state.viewName}_expanded"](@state.data[index],@columnAction)
      }
    </div>

  #
  #
  #
  renderHeader: (index) ->
    <div className="chiika-header" key={index}>
    {
        @state.columns.map (col,i) =>
          <div className="header-title col-#{col.name} order-#{@state.sortingPrefDir} #{if col.css? then col.css else ''}" onContextMenu={ (e) => @headerContextMenu(e,col)} onClick={ (e) => @headerClick(e,col)} key={i}><span>{col.display}</span></div>
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
