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

_ = require 'lodash'

CardView = require './card-view'
LoadingMini = require './loading-mini'
slick       = require 'slick-carousel'

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
  componentWillMount: ->
    id = @props.params.id

    owner = 'myanimelist'

    chiika.ipc.getDetailsLayout id,owner, (args) =>
      @setState { layout: args }
      console.log @state.layout

  componentWillUnmount:->
    chiika.ipc.disposeListeners('details-layout-request-response')
  componentDidMount: ->
    console.log "Mount"

    $('.fab-main').click ->
      $('.fab-container').toggleClass 'active'

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
            backgroundColor: ["#0288D1"]
            },{
            data: [average,10 - average],
            backgroundColor: ["#6A1B9A"]
          }]
          labels: ["Average","y"]
        }
      }
      chart = new Chart(document.getElementById("score-circle"),options)

      $('.characters-images').slick('unslick')
      $('.characters-images').slick({
        centerMode: true,
        centerPadding: '0px',
        slidesToShow: 2,
        arrows: false
      })



  render: ->
    <div className="detailsPage">
      <div className="detailsPage-left">
        <div className="detailsPage-back">
          <i className="mdi mdi-arrow-left"></i>
          Back
        </div>
      {
        if @state.layout.cover?
          <img src="#{@state.layout.cover}" onClick={yuiModal} width="150" height="225" alt="" />
        else
          <LoadingMini />
      }
        {
          if @state.layout.list
            <div>
              <button type="button" className="button raised lightblue" onClick={@openProgress}>
                {
                  if @state.layout.status.user == "1"
                    "Watching"
                  else if @state.layout.status.user == "2"
                    "Completed"
                  else if @state.layout.status.user == "3"
                    "On Hold"
                  else if @state.layout.status.user == "4"
                    "Dropped"
                  else if @state.layout.status.user == "6"
                    "Plan to Watch"
                }
              </button>
              <div className="statusInteractions">
                <div className="title">
                  {
                    if @state.layout.status.user == "1"
                      "Watching"
                    else if @state.layout.status.user == "2"
                      "Completed"
                    else if @state.layout.status.user == "3"
                      "On Hold"
                    else if @state.layout.status.user == "4"
                      "Dropped"
                    else if @state.layout.status.user == "6"
                      "Plan to Watch"
                  }
                </div>
                <div className="interactions">
                  <div>On Hold</div>
                  <div>On Hold</div>
                  <div>On Hold</div>
                  <div>On Hold</div>
                </div>
              </div>
              <div className="progressInteractions">
                <div className="title">
                  Episode
                </div>
                <div className="interactions">
                  <button className="minus">
                    -
                  </button>
                  <div className="number">
                    <input type="text"name="name" placeholder="#{@state.layout.status.watched}"/>
                    <span>/ { @state.layout.status.total }</span>
                  </div>
                  <button className="plus">
                    +
                  </button>
                </div>
              </div>
            </div>
        }
      </div>
      <div className="detailsPage-right">
        <div className="detailsPage-row">
          <h1>{ @state.layout.title }</h1>
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
                  <select className="button lightblue" name="" value={@state.layout.scoring.userScore}>
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
                      <div key={i}><img src={ch.image} style={{width:175, height: 291}}></img></div>
                  }
              </div>
            </div>
          </div>
        </div>
      </div>
      <div className="fab-container">
        <div className="fab fab-main">
          <i className="mdi mdi-menu"></i>
        </div>
        <div className="fab fab-little">
          <i className="mdi mdi-folder"></i>
        </div>
        <div className="fab fab-little">
          <i className="mdi mdi-rss"></i>
        </div>
        <div className="fab fab-little">
          <i className="mdi mdi-play"></i>
        </div>
      </div>
    </div>
