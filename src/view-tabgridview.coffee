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
{Menu,MenuItem}                         = require('electron').remote

_find                                   = require 'lodash/collection/find'
_forEach                                = require 'lodash.foreach'
_indexOf                                = require 'lodash/array/indexOf'
_remove                                 = require 'lodash/array/remove'
_assign                                 = require 'lodash.assign'
{ReactTabs,Tab,Tabs,TabList,TabPanel}   = require 'react-tabs'
Loading                                 = require './loading'
ReactList                               = require 'react-list'

module.exports = React.createClass
  getInitialState: ->
    index: 0
    lastKnownTabIndex: 0
    header: null
    tabs: []
    data: []
    columns: []
    state: 1 # Loading
    viewName: @props.route.viewName
  componentWillMount: ->
    header = @constructHeader(@state.viewName)
    tabs   = @constructTabs(@state.viewName)
    data   = @constructData(@state.viewName,0)
    @state.header = header
    @state.tabs   = tabs
    @state.state  = 1
    @state.data   = data
  componentDidMount: ->
    # Table features

    #Dev
    @componentWillReceiveProps(@props)

  #
  #
  #componentDidUpdate: ->
    #$("#chiika-table-header").colResizable({ resizeMode: 'overflow',liveDrag: true})
  #


  componentWillReceiveProps: (props) ->
    chiika.logger.renderer("TabGridView - ViewName: #{props.route.viewName}")

    header = @constructHeader(props.route.viewName)
    tabs   = @constructTabs(props.route.viewName)
    columns = @constructColumns(props.route.viewName)
    data    = @constructData(props.route.viewName,0)

    @setState { header: header, viewName: props.route.viewName, tabs: tabs,columns: columns,data:data, state: 1 }

  onSelect: (index,last) ->

    data    = @constructData(@state.viewName,index)
    @setState { index: index,data:data}

  constructHeader: (viewName) ->
    uiItem = _find chiika.uiData, (o) => o.name == viewName
    columnList = uiItem.columns
    headers = []

    _forEach columnList, (column) =>
      if !column.hidden
        headers.push { text: column.display, class: "header-#{column.name}" }

    headers

  constructTabs: (viewName) ->
    uiItem = _find chiika.uiData, (o) => o.name == viewName
    tabs = uiItem.tabList

    tabs
  constructColumns: (viewName) ->
    uiItem = _find chiika.uiData, (o) => o.name == viewName
    columns = uiItem.columns

    notHiddenColumns = []
    _forEach columns, (column) ->
      if !column.hidden
        notHiddenColumns.push column

    notHiddenColumns


  constructData: (viewName,index) ->
    uiItem = _find chiika.uiData, (o) => o.name == viewName
    viewData = _find(chiika.viewData, (o) => o.name == viewName)
    gridData = _find(viewData.dataSource, (o) => o.name == viewData.dataSource[index].name)
    gridData.data

  listItemClick: (e) ->
    
    $("#chiika-list").find(".list-item").each (e) ->
      $(this).removeClass "selected"
    $(e.target).parent().toggleClass "selected"
  render: ->
    if @state.state == 0
      <Loading />
    else
      @renderTabs()

  renderSingleItem: (index,key) ->
    <div className="list-item" key={key} onClick={@listItemClick}>
      {
        @state.columns.map (col,i) =>
          <div className="col-list col-#{col.name}" key={i}>{@state.data[index][col.name]}</div>
      }
    </div>
  renderHeader: (index) ->
    <div className="chiika-header" key={index}>
    {
      @state.columns.map (col,i) =>
        <div className="header-#{col.name}" key={i}>{col.display}</div>
    }
    </div>

  renderTabs: ->
    <Tabs onSelect={@onSelect} selectedIndex={@state.index}>
      <TabList>
        {@state.tabs.map (tab, i) =>
            <Tab key={i}>{tab.name}</Tab>
            }
      </TabList>
      {
        @state.tabs.map (tab,i) =>
          <TabPanel key={i}>
          {
            @renderHeader(i)
          }
          {
              <div style={{'overflow':'auto',height: '100%'}} id="chiika-list">
                <ReactList itemRenderer={@renderSingleItem} length={@state.data.length} type='simple' />
              </div>
          }
          </TabPanel>
      }
    </Tabs>
