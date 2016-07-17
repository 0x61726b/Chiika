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

React = require('react')
{Router,Route,BrowserHistory,Link} = require('react-router')

_ = require 'lodash'
#Views

Home = React.createClass
  ipcCall: ->

  componentDidMount: ->
    chiika.ipcListeners.push this
    console.log "Home: Mount"

    # @mygrid = new dhtmlXGridObject('myGrid')
    #
    # @mygrid.setImagePath("./codebase/imgs/")
    # @mygrid.setHeader("Sales,Book title,Author,Price")
    # @mygrid.setInitWidths("100,250,150,100")
    # @mygrid.setColAlign("right,left,left,left")
    # @mygrid.setColTypes("ro,ed,ed,ed")
    # @mygrid.setColSorting("int,str,str,int")
    # @mygrid.init()
    #
    # data={ rows:[] }
    #
    # for i in [0...1000]
    #   data.rows.push { id: i , data:[ "Test " + i, "Huhee","HUehue "]}
    # @mygrid.parse(data,"json")
  componentWillUnmount: ->
    _.pull chiika.ipcListeners,this

  render: () ->
    (<div id="myGrid" />)

module.exports = Home
