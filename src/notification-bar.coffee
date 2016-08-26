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

React                               = require('react')
ReactDOM                            = require("react-dom")
Chart                               = require 'chart.js'
_forEach                            = require 'lodash.foreach'
{remote,ipcRenderer}                 = require 'electron'

window.$ = window.jQuery = require('jQuery')

NotificationBar = React.createClass
  getInitialState: ->
    recognized: false
    layout:
      title: ''
      suggestions: []
      image: ''

  onDismiss: ->
    ipcRenderer.send 'notf-bar-dismiss'

  showGuess: ->
    $("#notf").toggleClass 'recognized'
    $("#notf").toggleClass 'not-recognized'

  componentDidMount: ->
    ipcRenderer.on 'notf-bar-not-recognized', (event,args) =>
      layout = { title: args.title, episode: args.episode }

      if args.suggestions.length <= 4
        layout.suggestions = args.suggestions
      else
        layout.suggestions = []
        for i in [0...4]
          layout.suggestions.push args.suggestions[i]


      @setState { recognized: false, layout: layout }

    ipcRenderer.on 'notf-bar-recognized', (event,args) =>
      layout = { title: args.title, episode: args.episode,image: args.image }
      @setState { recognized: true, layout: layout }

      time = 120
      updateTimer = ->
        if time == 0
          time = 120
        time = time - 1
        $("#updateButton").html("Update in #{time}")

      setInterval(updateTimer,1000)

  recognized: ->
    <div className="desktop-notification recognized" id="notf">
      <div className="notification-title">
        <div className="notf-img">
          <div className="img-circle">
            <img src="#{@state.layout.image}" alt="" />
          </div>
        </div>
        <div className="notf-meta">
          <h1>{ @state.layout.title }</h1>
          <h2>Episode: { @state.layout.episode }</h2>
        </div>
      </div>
      <div className="notification-actions">
        <button type="button" className="notification-button" id="updateButton">Update in 120</button>
        <button type="button" className="notification-button" onClick={@onDismiss}>Dismiss</button>
      </div>
    </div>

  notRecognized: ->
    <div className="desktop-notification recognized" id="notf">
      <div className="notification-title">
        <div className="notf-img">
          <div className="img-circle">
            <img src="../assets/images/notfbar/cover6.jpg" alt="" />
          </div>
        </div>
        <div className="notf-meta">
          <h1>Couldnt identify title { @state.layout.title }</h1>
          <h2>Episode: { @state.layout.episode }</h2>
        </div>
      </div>
      <div className="notification-guess img">
        {
          @state.layout.suggestions.map (suggestion,i) =>
            <div className="img-guess" key={i}>
              <img src="#{suggestion.entry.animeImage}" alt="" />
            </div>
        }
      </div>
      <div className="notification-actions">
        <button type="button" className="notification-button" onClick={@showGuess}>Show Guess</button>
        <button type="button" className="notification-button">Search</button>
        <button type="button" className="notification-button" onClick={@onDismiss}>Dismiss</button>
      </div>
    </div>
  render: ->
    if @state.recognized
      @recognized()
    else
      @notRecognized()

ReactDOM.render(React.createElement(NotificationBar), document.getElementById('app'))
