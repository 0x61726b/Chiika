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
ReactDOM = require("react-dom")

{BrowserWindow, ipcRenderer,remote} = require 'electron'

#Views

Menubar = React.createClass
  currentVideoFile:null
  componentDidMount: ->
    ipcRenderer.on 'mp-found',(mp,data) ->
      #Do something

    ipcRenderer.on 'mp-closed', (mp,data) ->
      @currentVideoFile = null

    ipcRenderer.on 'mp-video-changed', (mp,data) ->

      @currentVideoFile = data

    ipcRenderer.send 'request-current-video'

    ipcRenderer.on 'request-current-video-response', (event,data) =>
      @currentVideoFile = data


  render: () ->
    (<div className="menubar-container" id="menubarMain">
  		<div className="menubar-content">
  			<div className="menubar-title">
  				<div id="menubar-nowPlaying">
  					<span><i className="fa fa-play fa-1x"></i></span>
  					<h3>Now Playing: 13/13</h3>
  				</div>
  				<div className="menubar-icon" id="threeDot"><i className="fa fa-ellipsis-v" id="menubar-shareIcon"></i></div>
  			</div>
  			<div className="menubar-infoContainer">
  				<div className="menubar-imageContainer">
  					<img src="cover.png" />
  				</div>
  				<div className="menubar-infoColumn">
  					<div className="menubar-animeTitle">
  						<h4>Yahari ore no seishun love comedy wa machige</h4>
  					</div>
  					<div className="menubar-info">
  						<div className="menubar-info-text">
  							<span><p><b>type: </b>TV</p></span>
  							<span><p><b>score: </b>8.34</p></span>
  							<span><p><b>studıo: </b>Feel</p></span>
  							<span><p><b>source: </b>Light Novel</p></span>
  							<span><p><b>season: </b>Spring 2015</p></span>
  						</div>
  						<div className="menubar-info-button">
  							<button className="menubar-button">
  								<p>Open Folder</p>
  							</button>
  							<button className="menubar-button">
  								<p>open on mal</p>
  							</button>
  							<button className="menubar-button">
  								<p>go to details</p>
  							</button>
  						</div>
  					</div>
  				</div>
  			</div>
  		</div>
  		<div className="context-div" id="contextDiv">
  			<ul>
  				<li>Twitter</li>
  				<li>IRC</li>
  				<li>Google+</li>
  			</ul>
  		</div></div>)

ReactDOM.render(React.createElement(Menubar), document.getElementById('app'))
