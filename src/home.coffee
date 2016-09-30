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

Chart                               = require 'chart.js'
_forEach                            = require 'lodash/collection/forEach'
Loading                             = require './loading'
CardsNews                           = require './cards/cards-news'
CardsUpcoming                       = require './cards/cards-upcoming'
CardsRecognized                     = require './cards/cards-recognized-anime'
CardStatistics                      = require './cards/cards-statistics-small'
CardsContinueWatching               = require './cards/cards-continue-watching'
_find                               = require 'lodash/collection/find'
_assign                             = require 'lodash.assign'
#Views

module.exports = React.createClass
  getInitialState: ->
    cards: []
  componentWillMount: ->
    @refresh()

    chiika.emitter.on 'ui-data-refresh', (item) =>
      find = _find @state.cards, (o) -> o.name == item.name
      find = item
      if @isMounted()
        @refresh()
        @setState { }



  refresh: ->
    @state.cards = []
    _forEach chiika.uiData, (ui) =>
      @state.cards.push ui

  render: ->
    <div className="home-grid">
      <div className="whats-next">
      <h5>Whats Next // Optional</h5>
        <div className="whats-next-list">
          <div className="whats-next-item">
            <div className="whats-next-cover" data-episodeno="13">
              <img></img>
            </div>
            <span>Anime Title</span>
          </div>
        </div>
      </div>
    {
      @state.cards.map (card,i) =>
        if card.name == 'cards_continueWatching' && !chiika.getOption('DisableCardContinueWatching')
          <CardsContinueWatching key={i} card={card} state={card.state}/>
        else if card.name == 'cards_news' && !chiika.getOption('DisableCardNews')
          <CardsNews key={i} card={card} state={card.state}/>
        else if card.name == 'cards_statistics' && !chiika.getOption('DisableCardStatistics')
          <CardStatistics key={i} card={card} state={card.state}/>
        else if card.name == 'cards_upcoming' && !chiika.getOption('DisableCardUpcoming')
          <CardsUpcoming key={i} card={card} state={card.state}/>
        else if card.name == 'cards_currentlyWatching'
          <CardsRecognized key={i} card={card} state={card.state}/>
    }
    </div>

  renderTest: ->
    <div className="gridTest" id="homeGrid">
    {
      @state.cards.map (card,i) =>
        chiika.cardManager.renderCard(card,i)
    }
    </div>
