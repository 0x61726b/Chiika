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
_forEach                            = require 'lodash/collection/forEach'
{remote,ipcRenderer,shell}          = require 'electron'

window.$ = window.jQuery = require('jQuery')

NotificationBar = React.createClass
  getInitialState: ->
    recognized: false
    updateDelay: 120 # Default
    layout:
      title: ''
      suggestions: []
      image: ''

  onDismiss: ->
    ipcRenderer.send 'notf-bar-dismiss'

  showGuess: ->
    $("#notf").toggleClass 'recognized'
    $("#notf").toggleClass 'not-recognized'

  onImageClick: (id) ->
    shell.openExternal(id)

  update: ->
    ipcRenderer.send 'notf-bar-update',{ params: @state.layout }

  onHover: (title) ->
    $("#notf-title h1").html(title)

  setSelected: (entry) ->
    @selectedEntry = entry

    console.log @selectedEntry

  pick: () ->
    if @selectedEntry?
      ipcRenderer.send 'notf-bar-pick', { layout: @state.layout, entry: @selectedEntry }
      @onHover("Hello ?")

  search: () ->
    ipcRenderer.send 'notf-bar-search',{ layout: @state.layout }

  componentDidMount: ->
    ipcRenderer.on 'notf-bar-not-recognized', (event,args) =>
      layout = { title: args.title, episode: args.episode, videoFile: args.videoFile, parse: args.parse }
      console.log "notf-bar-not-recognized"
      console.log args

      if args.suggestions.length <= 4
        layout.suggestions = args.suggestions
      else
        layout.suggestions = []
        for i in [0...4]
          layout.suggestions.push args.suggestions[i]


      @setState { recognized: false, notRecognizedText:"Chiika could not identify this title #{args.title}", layout: layout }

    ipcRenderer.on 'notf-bar-recognized', (event,args) =>
      console.log "notf-bar-recognized"
      console.log args
      layout = { title: args.title, episode: args.episode,image: args.image,imageLink: args.imageLink }
      @setState { recognized: true, layout: layout, updateDelay: args.updateDelay }


    ipcRenderer.on 'fade', (event,args) =>
      console.log args
      if args == 'stop-fading' # Focus
        if @afterFadeTimeout?
          clearTimeout(@afterFadeTimeout)
          @afterFadeTimeout = null

        if $(".desktop-notification").hasClass 'dn-fade-out'
          $(".desktop-notification").toggleClass 'dn-fade-out'
      if args == 'start-fading' # Blur
        if !$(".desktop-notification").hasClass 'dn-fade-out'
          $(".desktop-notification").toggleClass 'dn-fade-out'

          afterFade = =>
            $(".desktop-notification").toggleClass 'dn-fade-out'

          @afterFadeTimeout = setTimeout(afterFade,2500)

  componentDidUpdate: ->
    if @state.recognized
      if @updateInterval?
        clearInterval(@updateInterval)
        @updateInterval = null
        console.log "Cleared previous interval"

      time = @state.updateDelay

      if !time?
        time = 120
      updateTimer = =>
        time = time - 1
        $("#updateButton").html("Update in #{time}")
        if time == 0
          $("#updateButton").html("Updated")
          $("#updateButton").attr('disabled','disabled')
          $(".desktop-notification").css('border-bottom','4px solid #60F181')

          @update()

          clearInterval(@updateInterval)
          @updateInterval = null

      @updateInterval = setInterval(updateTimer,1000)

      fadeOutAfterSometime = =>
        $(".desktop-notification").toggleClass 'dn-fade-out'

        afterFade = =>
          @onDismiss()
          $(".desktop-notification").toggleClass 'dn-fade-out'
          $(".desktop-notification").css('opacity:1')

        @afterFade = setTimeout(afterFade,2000)

      # @fadeAfterSometime = setTimeout(fadeOutAfterSometime,4000)
      #
      #
      # remote.getCurrentWindow().on 'focus', () =>
      #   @fadeAfterSometime = setTimeout(fadeOutAfterSometime,4000)



  recognized: ->
    <div className="desktop-notification recognized" id="notf">
      <div className="notification-title">
        <div className="notf-img">
          <div className="img-circle">
            <img src="#{@state.layout.image}" onClick={ () => @onImageClick(@state.layout.imageLink)} alt="" />
          </div>
        </div>
        <div className="notf-meta">
          <h1>{ @state.layout.title }</h1>
          <h2>Episode: { @state.layout.episode }</h2>
        </div>
      </div>
      <div className="notification-actions">
        <button type="button" className="notification-button" onClick={@update} id="updateButton">Update in 120</button>
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
        <div className="notf-meta" id="notf-title">
          <h1>{ @state.notRecognizedText }</h1>
          <h2>Episode: { @state.layout.episode }</h2>
        </div>
      </div>
      <div className="notification-guess img">
        {
          @state.layout.suggestions.map (suggestion,i) =>
            <div className="img-guess" key={i}>
              <img src="#{suggestion.entry.animeImage}" onClick={ () => @setSelected(suggestion.entry.id)} onMouseEnter={ () => @onHover(suggestion.entry.animeTitle)} alt="" />
            </div>
        }
      </div>
      <div className="notification-actions">
        <button type="button" className="notification-button" onClick={@pick}>Pick</button>
        <button type="button" className="notification-button" onClick={@search}>Search</button>
        <button type="button" className="notification-button" onClick={@onDismiss}>Dismiss</button>
      </div>
    </div>
  render: ->
    if @state.recognized
      @recognized()
    else
      @notRecognized()

ReactDOM.render(React.createElement(NotificationBar), document.getElementById('app'))
