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
#Date: 6.2.2016
#authors: arkenthera
#Description:
#----------------------------------------------------------------------------

React = require 'react'
ReactDOM = require 'react-dom'


GridHelper = require './GridHelper'

TestContextMenu = React.createClass
  contextMenuData:{ }
  handleSelect: (e) ->
    if e.currentTarget.checked == true
      for columns in @props.columns
        res =  $.grep $(e.target).parent().parent().attr('class').split(" "), (e) -> e == columns.name
        if res.length > 0
          gh  = new GridHelper w2ui[@props.gridName]
          gh.addColumn res[0]
          w2ui[@props.gridName] = gh.getGrid()
          w2ui[@props.gridName].refresh()
    else
      for columns in @props.columns
        res =  $.grep $(e.target).parent().parent().attr('class').split(" "), (e) -> e == columns.name
        if res.length > 0
          gh  = new GridHelper w2ui[@props.gridName]
          gh.removeColumn res[0]

  componentDidMount: ->
    toggleables = $.grep @props.columns, (e) -> e.toggleable == true

    contextMenuItems = {}



    for val,index in @props.columns
      if val.toggleable == true
        contextMenuItems[val.name] = {}
        contextMenuItems[val.name].name = val.name
        contextMenuItems[val.name].type = "checkbox"
        contextMenuItems[val.name].events = { click: @handleSelect }
        contextMenuItems[val.name].className = val.name

        if val.order != -1
          @contextMenuData[val.name] = true


    $.contextMenu({
    selector: ".w2ui-head",
    items:contextMenuItems,
    events: {
      show: (opt) =>
        $.contextMenu.setInputValues(opt, @contextMenuData)
      hide: (opt) =>
        $.contextMenu.getInputValues(opt, @contextMenuData)

        for input in opt.inputs
          checked = input.$input[0].checked
          @contextMenuData.input = checked
        console.log @contextMenuData
    }})
  componentWillUnmount: ->
    $.contextMenu ('destroy')
  render: ->
    (<div id="contextMenuTest"></div>)
module.exports = TestContextMenu
