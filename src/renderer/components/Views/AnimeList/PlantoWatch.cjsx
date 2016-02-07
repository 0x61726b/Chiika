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

#Plan to Watch List
PlantoWatchList = React.createClass
  mixins:[Mixin]


  componentDidMount: ->
    list = cn.getAnimeListByUserStatus(6)
    @setGridName("gridPlantoWatchList")
    @setList(list)
    @addColumns()
    $("#gridPlantoWatchList").w2grid(@getGrid())
  componentWillUnmount: ->
    $('#gridPlantoWatchList').w2destroy()
  refreshDataSource: ->
    list = cn.getAnimeListByUserStatus(6)
    @setList(list)
    w2ui["gridPlantoWatchList"].records = list
  render: () ->
    (<div id="gridPlantoWatchList" className="listCommon"></div>);

module.exports = PlantoWatchList
