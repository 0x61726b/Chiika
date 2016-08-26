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

React                   = require('react')

_find                   = require 'lodash/collection/find'

CardView                = require './card-view'
LoadingMini             = require './loading-mini'

{dialog}                            = require('electron').remote

module.exports = React.createClass
  getInitialState: ->
    layout:
      miniCards: []
      genres: ""
      actionButtons:[]
      synopsis: ""
      characters: []
      cover: null
      scoring:
        type: 'normal'
        userScore: 0


  #
  #
  #
  componentWillMount: ->
    id = @props.params.id

    owner = @props.route.owner


    chiika.ipc.getDetailsLayout id,@props.route.viewName,owner, (args) =>
      @setState { layout: args.layout }
      console.log args.layout

      # if args.updated
      #   chiika.ipc.sendMessage 'get-view-data-by-name',{ name: @props.route.viewName }


  #
  #
  #
  componentWillUnmount:->
    chiika.ipc.disposeListeners('details-layout-request-response')
    chiika.ipc.disposeListeners('details-action-response')

    @chart.destroy()

  #
  #
  #
  componentDidMount: ->
    $('.fab-main').click ->
      $('.fab-container').toggleClass 'active'

    $('.fab-main fab').click ->
      console.log(this)


  #
  #
  #
  componentDidUpdate: ->
    scoring = @state.layout.scoring

    userScore = 0
    remainder = 10

    if scoring.type == 'normal' #0-10
      userScore = scoring.userScore
      average = scoring.average
      remainder = 10 - userScore
      options = {
        type: 'doughnut',
        options: { legend: { display: false}, cutoutPercentage: 60 },
        data: {
          datasets: [{
            data: [userScore,remainder],
            backgroundColor: [$('.primary').css('background-color')]
            },{
            data: [average,10 - average],
            backgroundColor: [$('.emphasis').css('color')]
          }]
          labels: ["Average","y"]
        }
      }
      @chart = new Chart(document.getElementById("score-circle"),options)


      # jQuery stuff
      $("#scoreSelect option[value=#{@state.layout.scoring.userScore}]").attr('selected','selected')

      $(".number input").bind 'keypress', (e) =>
        if e.keyCode == 13 #Enter
          @onProgressValueChange(e)

      $(".number input").focus ->
        $(this).val("")


  #
  #
  #
  onAction: (action,params,returnCallback) ->
    chiika.ipc.detailsAction(action,@state.layout,params)

    chiika.ipc.detailsActionResponse action,(args) =>
      chiika.ipc.disposeListeners('details-action-response')
      returnCallback?(args)

  #
  #
  #
  onCoverClick: ->
    @onAction('cover-click', { viewName: @props.route.viewName })


  #
  #
  #
  onCharacterClick: (e) ->
    @onAction('character-click',{ id: $(e.target).parent().attr("data-character") })

  openProgress: (e) ->
    $('.userStatus').toggleClass('open')
    $('.userStatusButton').toggleClass('open')

  onProgressValueChange: (e) ->
    itemTitle = $(e.target).parent().parent().parent().attr("data-item")

    findItem = _find @state.layout.status.items, (o) -> o.title == itemTitle

    if findItem?
      currentOld = parseInt(findItem.current)
      current = parseInt($(e.target).val())
      total = parseInt(findItem.total)

      if current == currentOld
        return

      if total? && total > 0 && (current) > total
        return

      if current > 0
        findItem.current = current
        @onAction('progress-update',{ item: { title: itemTitle,current: current, total: total },viewName: @props.route.viewName },@onUpdate)

        # Update input
        $($(e.target).next()).find('input').attr('placeholder',current)
        $($(e.target)).attr('placeholder',current)
      else
        @onActionError("You thought you could do that,didnt you?")
    else
      @onActionError("There was a problem updating the progress.")

  #
  #
  #
  onMinus: (e) ->
    itemTitle = $(e.target).parent().parent().attr("data-item")

    findItem = _find @state.layout.status.items, (o) -> o.title == itemTitle

    if findItem?
      current = parseInt(findItem.current)
      total = parseInt(findItem.total)

      if current > 0
        current--

        findItem.current = current
        @onAction('progress-update',{ item: { title:itemTitle, current: current, total: total },viewName: @props.route.viewName },@onUpdate)

        # Update input
        $($(e.target).next()).find('input').attr('placeholder',current)
    else
      @onActionError("There was a problem updating the progress.")

  #
  #
  #
  onPlus: (e) ->
    itemTitle = $(e.target).parent().parent().attr("data-item")

    findItem = _find @state.layout.status.items, (o) -> o.title == itemTitle


    if findItem?
      current = parseInt(findItem.current)
      total = parseInt(findItem.total)

      if total? && total > 0 && (current + 1) > total
        return


      if current >= 0
        current++

        findItem.current = current
        @onAction('progress-update',{ item: { title:itemTitle, current: current, total: total },viewName: @props.route.viewName },@onUpdate)

        # Update input
        $($(e.target).prev()).find('input').attr('placeholder',current)
    else
      @onActionError("There was a problem updating the progress.")

  #
  #
  #
  onScoreChange: (e) ->
    value = $(e.target).val()
    $("#scoreSelect option[value=#{value}]").attr('selected','selected');

    if @state.layout.scoring.type == 'normal'
      @chart.data.datasets[0].data[0] = parseInt($(e.target).val())
      @chart.data.datasets[0].data[1] = 10 - parseInt($(e.target).val())
      @chart.update()


    @onAction('score-update',{ item: { current: parseInt(value) },viewName: @props.route.viewName },@onUpdate)

  #
  #
  #
  onStatusChange: (e) ->
    action = $(e.target).attr('data-action')
    $(".userStatus .current").removeClass('current')
    $(e.target).addClass('current')


    @state.layout.status.defaultAction = $(e.target).text()
    $(".userStatusButton").html($(e.target).text())
    $('.userStatus').toggleClass('open')

    @onAction('status-update',{ item: { identifier: action },viewName: @props.route.viewName },@onUpdate)
  #
  #
  #
  onUpdate: (result) ->
    if result.args.success
      @onActionSuccess("Updated!")

      #Refresh view data
      chiika.ipc.sendMessage 'get-view-data-by-name', { name: @props.route.viewName }
    else
      @onActionError("Whoops..Something went wrong.")

  #
  #
  #
  onActionError: (error) ->
    chiika.toastError(error,5000)

  #
  #
  #
  onActionSuccess: (message) ->
    chiika.toastSuccess(message,2500)

  onCardActionCompleteCommon: (id,args) ->
    if args.state == 'not-found'
      chiika.notificationManager.folderNotFound =>
        folders = dialog.showOpenDialog({
          properties: ['openDirectory','multiSelections']
        })

        if folders?
          chiika.scriptAction('media','set-folders-for-entry', { id: id,folders: folders })
  #
  #
  #
  openFolder: ->
    chiika.mediaAction 'cards','open-folder', { id: @state.layout.id }, (args) => @onCardActionCompleteCommon(@state.layout.id,args)

  playNextEpisode: ->
    nextEpisode = parseInt(@state.layout.status.items[0].current) + 1
    onActionCompete = (args) =>
      console.log args
      if args.state == 'episode-not-found'
        chiika.notificationManager.episodeNotFound(@state.layout.title,nextEpisode)

      if args.state == 'not-found'
        chiika.notificationManager.folderNotFound =>
          folders = dialog.showOpenDialog({
            properties: ['openDirectory','multiSelections']
          })

          if folders?
            chiika.scriptAction('media','set-folders-for-entry', { id: @state.layout.id,folders: folders })

    chiika.mediaAction 'cards','play-next-episode', { nextEpisode: nextEpisode, id: @state.layout.id }, onActionCompete

  render: ->
    <div className="detailsPage">
      <div className="detailsPage-left">
        <div className="detailsPage-back" onClick={this.props.history.goBack}>
          <i className="mdi mdi-arrow-left"></i>
          Back
        </div>
      {
        if @state.layout.cover?
          <img src="#{@state.layout.cover}" onClick={@onCoverClick} width="150" height="225" alt="" />
        else
          <LoadingMini />
      }
        {
          if @state.layout.list
            <div>
              <button type="button" className="button raised primary userStatusButton" onClick={@openProgress}>
                {
                  @state.layout.status.defaultAction
                }
              </button>
              <div className="userStatus">
              {
                @state.layout.status.actions.map (action,i) =>
                  if action.name == @state.layout.status.defaultAction
                    <div className="status current" key={i} onClick={@onStatusChange} data-action={action.identifier}>{action.name}</div>
                  else
                    <div className="status" key={i} onClick={@onStatusChange} data-action={action.identifier}>{action.name}</div>
              }
              </div>
              {
                @state.layout.status.items.map (item,i) =>
                  <div className="progressInteractions" key={i} data-item={item.title}>
                    <div className="title">
                      { item.title }
                    </div>
                    <div className="interactions">
                      <button className="minus" onClick={@onMinus}>
                        -
                      </button>
                      <div className="number">
                        <input type="number" name="name" placeholder="#{item.current}"/>
                        <span>/ { item.total }</span>
                      </div>
                      <button className="plus" onClick={@onPlus}>
                        +
                      </button>
                    </div>
                  </div>
              }
            </div>
        }
      </div>
      <div className="detailsPage-right">
        <div className="detailsPage-row">
          <h1>{ @state.layout.title }</h1>
          <h2>
          {
            if @state.layout.params?
              @state.layout.params.author.name
            }
          </h2>
          <span className="detailsPage-genre">
            <ul>
              {
                if @state.layout.genres?
                  @state.layout.genres.split(',').map (genre,i) =>
                    <li key={i}>{genre}</li>
              }
            </ul>
          </span>
        </div>
        <div className="detailsPage-score detailsPage-row">
          <div className="score-circle-div" data-score={@state.layout.scoring.average}>
            <canvas id="score-circle" width="100" height="100"></canvas>
          </div>
          <span className="detailsPage-score-info">
            <h5>From { @state.layout.voted ? ""} votes</h5>
            <span>
              <h5>Your Score</h5>
              {
                if @state.layout.scoring.type == "normal"
                  <select id="scoreSelect" className="button primary" name="" onChange={@onScoreChange}>
                  {
                    [0,1,2,3,4,5,6,7,8,9,10].map (score,i) =>
                      <option value={score} key={i}>{score}</option>
                  }
                  </select>
              }
            </span>
            </span>
        </div>
        <div className="detailsPage-miniCards detailsPage-row">
          {
            if @state.layout.miniCards.length != 0
              @state.layout.miniCards.map (card,i) =>
                chiika.cardManager.renderCard(card,i)
            else
              <LoadingMini />
          }
        </div>
        <div className="card">
          <div className="detailsPage-card-item">
            <div className="title">
              <h2>Synopsis</h2>
            </div>
            {
              if @state.layout.synopsis.length > 0
                <div className="card-content" dangerouslySetInnerHTML={{__html: @state.layout.synopsis }} />
            }
          </div>
          <div className="detailsPage-card-item">
            <div className="title">
              <h2>Characters</h2>
            </div>
            <div className="card-content">
              <div className="characters-images">
                 {
                  if @state.layout.characters.length > 0
                    @state.layout.characters.map (ch,i) =>
                      <div key={i} data-character={ch.id} onClick={@onCharacterClick}>
                        <img src={ch.image}></img>
                        <p>{ch.name}</p>
                      </div>
                  }
              </div>
            </div>
          </div>
        </div>
      </div>
      <div className="fab-container">
        <div className="fab fab-main raised accent">
          <i className="mdi mdi-menu"></i>
        </div>
        <div className="fab fab-little emphasis" title="Open Folder" onClick={@openFolder}>
          <i className="mdi mdi-folder"></i>
        </div>
        <div className="fab fab-little emphasis" title="Torrent">
          <i className="mdi mdi-rss"></i>
        </div>
        <div className="fab fab-little emphasis" title="Play Next Episode" onClick={@playNextEpisode}>
          <i className="mdi mdi-play"></i>
        </div>
      </div>
    </div>
