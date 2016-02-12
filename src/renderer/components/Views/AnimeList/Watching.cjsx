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
Mixin = require './Common'

#Watching List
WatchingList = React.createClass
  mixins:[Mixin]
  componentDidMount: ->
    list = chiika.chiika.getAnimeListByUserStatus(1)
    @setGridName("gridWatchingList")
    @setList(list)

    @addColumns()
    $("#gridWatchingList").w2grid(@getGrid())



  componentWillUnmount: ->
    $('#gridWatchingList').w2destroy();
  refreshDataSource: ->
    list = chiika.chiika.getAnimeListByUserStatus(1)
    @setList(list)
    w2ui["gridWatchingList"].records = list

  render: () ->
    (<div id="gridWatchingList" className="listCommon"></div>);

module.exports = WatchingList
