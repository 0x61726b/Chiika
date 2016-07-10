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
{BrowserWindow, ipcRenderer,remote} = require 'electron'

_ = require 'lodash'
path = require 'path'

#Views

SideMenu = React.createClass
  componentDidMount: ->
    window.chiika.ipcListeners.push this

    if !window.chiika.isWaiting
      @chiikaReady()

    hoverIn = ->
      $(this).addClass "rotateLogo"
    hoverOut = ->
      $(this).removeClass "rotateLogo"
    $(".chiikaLogo").hover(hoverIn, hoverOut)
    $("div.navigation ul a").click ->
      $("div.navigation ul li").removeClass "active"
      $(this).parent().toggleClass "active"

    window.chiika.emitter.on 'download-image',() =>
      @refreshSideMenu()
      console.log "Emitter: download-image"
  componentWillUnmount: ->
    _.pull window.chiika.ipcListeners,this
  ipcCall: ->
    @refreshSideMenu()
  refreshSideMenu: ->
    @imagePath = @getUserImage()
    @forceUpdate()
  getUserImage: ->
    @imagePath = window.chiika.configDirPath
    @imagePath = path.join(@imagePath,'Data','Images',window.chiika.user.userId + '.jpg')
    @imagePath
  render: () ->
    (<div className="sidebar">
      <div className="topLeft">
        <div className="logoContainer">
          <img className="chiikaLogo" src="./../assets/images/topLeftLogo.png"/>
        </div>
        <Link to="User" className="userArea noDecoration">
          <div className="imageContainer">
            <img id="userAvatar" className="img-circle avatar" src={@imagePath}/>
          </div>
          <div className="userInfo">
            Chiika
          </div>
        </Link>
      </div>
      <div className="navigation">
        <ul>
          <li className="active"><Link to="Home">Home</Link></li>
          <p className="list-title">Lists</p>
          <li><Link to="AnimeList">Anime List</Link></li>
          <li><Link to="MangaList">Manga List</Link></li>
          <p className="list-title">Watch</p>
          <li><Link to="Library">Library</Link></li>
          <li><Link to="Calendar">Calendar</Link></li>
          <li><Link to="Seasons">Seasons</Link></li>
          <p className="list-title">Discover</p>
          <li><Link to="Torrents">Torrents</Link></li>
         </ul>
      </div>
    </div>)

module.exports = SideMenu
