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

  componentWillUnmount: ->

  render: () ->
    (<div className="sidebar">
      <div className="topLeft">
        <div className="logoContainer">
          <img className="chiikaLogo" src="assets/images/topLeftLogo.png"/>
        </div>
        <Link to="User" className="userArea noDecoration">
          <div className="imageContainer">
            <img id="userAvatar" className="img-circle avatar" src="assets/images/avatar.jpg"/>
          </div>
          <div className="userInfo">
            Chiika
          </div>
        </Link>
      </div>
      <div className="navigation">
        <ul>
          <Link className="side-menu-link active" to="Home"><li className="side-menu-li">Home</li></Link>
          <p className="list-title">Lists</p>
          <Link className="side-menu-link" to="AnimeList"><li className="side-menu-li">Anime List</li></Link>
          <Link className="side-menu-link" to="MangaList"><li className="side-menu-li">Manga List</li></Link>
          <p className="list-title">Watch</p>
          <Link className="side-menu-link" to="Library"><li className="side-menu-li">Library</li></Link>
          <Link className="side-menu-link" to="Calendar"><li className="side-menu-li">Calendar</li></Link>
          <Link className="side-menu-link" to="Seasons"><li className="side-menu-li">Seasons</li></Link>
          <p className="list-title">Discover</p>
          <Link className="side-menu-link" to="Torrents"><li className="side-menu-li">Torrents</li></Link>
         </ul>
      </div>
    </div>)

module.exports = SideMenu
