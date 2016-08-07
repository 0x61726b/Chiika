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

_                                   = require 'lodash'

CardView                            = require './card-view'
LoadingMini                         = require './loading-mini'

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
    console.log "Will mount"
    id =  @props.params.id

    owner = 'myanimelist'

    chiika.ipc.getDetailsLayout id,owner, (args) =>
      @setState { layout: args }
      console.log @state.layout

  componentWillUnmount:->
    chiika.ipc.disposeListeners('details-layout-request-response')
  componentDidMount: ->
    console.log "Mount"
  componentDidUpdate: ->
    scoring = @state.layout.scoring

    userScore = 0
    remainder = 10

    if scoring.type == 'normal' #0-10
      userScore = scoring.userScore
      remainder = 10 - userScore


    options = {
      type: 'doughnut',
      options: { legend: { display: false}, cutoutPercentage: 75 },
      data: {
        labels: ["Your Score", "Total"],
        datasets: [{
          label: '# of Votes',
          data: [userScore,remainder],
          backgroundColor: ['rgba(255, 159, 64, 1)'],
          borderColor: [
            'rgba(255, 159, 64, 1)'],
          borderWidth: 0
          }]}
      }
    chart = new Chart(document.getElementById("score-circle"),options)

  render: ->
    <div className="detailsPage">
      <div className="detailsPage-left">
      {
        if @state.layout.cover?
          <img src="#{@state.layout.cover}" onClick={yuiModal} width="150" height="225" alt="" />
        else
          <LoadingMini />
      }
        {
          if @state.layout.list
            <button type="button" className="button raised lightblue">Watching</button>
        }
        {
          if @state.layout.list
            @state.layout.actionButtons.map (button,i) =>
              <button type="button" className="button raised #{button.color}" key={i}> { button.name }</button>
          else
            <button type="button" className="button raised yellow">Add to List</button>
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
          <div>
            <canvas id="score-circle" width="200" height="200"></canvas>
          </div>
          <span className="detailsPage-score-info">
              <h5>From 5,854 votes</h5>
              <span>
                <h5>Your Score</h5>
                {
                  if @state.layout.scoring.type == "normal"
                    <select className="button yellow" name="" value={@state.layout.scoring.userScore}>
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
              {
                if @state.layout.characters.length > 0
                  @state.layout.characters.map (ch,i) =>
                    <div key={i}>
                      <img src={ch.image} alt=""></img>
                      <span>{ch.name}</span>
                    </div>
              }
            </div>
          </div>
        </div>
      </div>
    </div>
