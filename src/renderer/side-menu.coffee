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


#Views

SideMenu = React.createClass
  componentDidMount: ->
    hoverIn = ->
      $(this).addClass "rotateLogo"
    hoverOut = ->
      $(this).removeClass "rotateLogo"
    $(".chiikaLogo").hover(hoverIn, hoverOut)
    $("div.navigation ul li").click ->
      $("div.navigation ul li").removeClass "active"
      $(this).toggleClass "active"

  render: () ->
    (<div className="sidebar">
      <div className="topLeft">
        <div className="logoContainer">
          <img className="chiikaLogo" src="./../assets/images/topLeftLogo.png"/>
        </div>
        <Link to="User" className="userArea noDecoration">
          <div className="imageContainer">
            <img id="userAvatar" className="img-circle avatar" src="./../assets/images/avatar.jpg"/>
          </div>
          <div className="userInfo">
            Chiika
          </div>
        </Link>
      </div>
      <div className="navigation">
        <ul>
          <li className="active"><Link to="Home">Home</Link></li>
          <li><Link to="AnimeList">Anime List</Link></li>
          <li><Link to="MangaList">Manga List</Link></li>
          <li><Link to="Library">Library</Link></li>
          <li><Link to="Calendar">Calendar</Link></li>
          <li><Link to="Seasons">Seasons</Link></li>
          <li><Link to="Torrents">Torrents</Link></li>
         </ul>
      </div>
    </div>)

module.exports = SideMenu
