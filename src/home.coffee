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
_forEach                            = require 'lodash.foreach'
#Views

module.exports = React.createClass
  getInitialState: ->
    cards: []
  componentDidMount: ->
    @setState { cards: chiika.cardManager.cards }

    chiika.emitter.on 'view-refresh', =>
      if @isMounted()
        @setState { cards: chiika.cardManager.cards }

    chiika.emitter.on 'ui-data-refresh', =>
      if @isMounted()
        @setState { cards: chiika.cardManager.cards }



  componentDidUpdate: ->
    # chart = this.state.chart;
    # data = this.props.data;
    #
    # data.datasets.forEach((dataset, i) => chart.data.datasets[i].data = dataset.data);
    #
    # chart.data.labels = data.labels;
  componentWillUnmount: ->

  render: ->
    <div className="gridTest" id="homeGrid">
    {
      @state.cards.map (card,i) =>
        chiika.cardManager.renderCard(card,i)
    }
    </div>
