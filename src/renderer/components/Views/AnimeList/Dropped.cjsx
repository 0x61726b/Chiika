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
#Date: 24.1.2016
#authors: arkenthera
#Description:
#----------------------------------------------------------------------------
React = require 'react'
cn = require './../../../ChiikaNode'
Mixin = require './Common'

#Dropped List
DroppedList = React.createClass
  mixins:[Mixin]


  componentDidMount: ->
    list = cn.getAnimeListByUserStatus(4)
    @setGridName("gridDroppedList")
    @setList(list)
    $("#gridDroppedList").w2grid(@getGrid())
  componentWillUnmount: ->
    $('#gridDroppedList').w2destroy()
  refreshDataSource: ->
    list = cn.getAnimeListByUserStatus(4)
    @setList(list)
    w2ui["gridDroppedList"].records = list
  render: () ->
    (<div id="gridDroppedList" className="listCommon"></div>);

module.exports = DroppedList
