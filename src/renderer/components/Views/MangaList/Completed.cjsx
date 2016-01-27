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
#Date: 27.1.2016
#authors: arkenthera
#Description:
#----------------------------------------------------------------------------
React = require 'react'
cn = require './../../../ChiikaNode'
Mixin = require './Common'

Helpers = require('./../../Helpers')
#Watching List
CompletedList = React.createClass
  mixins:[Mixin]
  componentDidMount: ->
    list = cn.getMangaListByUserStatus(2)
    @setGridName("gridMangaCompletedList")
    @setList(list)

    $("#gridMangaCompletedList").w2grid(@getGrid())
  componentWillUnmount: ->
    $('#gridMangaCompletedList').w2destroy();


  render: () ->
    (<div id="gridMangaCompletedList" className="listCommon"></div>);

module.exports = CompletedList
