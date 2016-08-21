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

  componentWillReceiveProps: (props) ->
    @props.data = {
      labels: ["Your Score", "Total"],
      datasets: [{
        label: '# of Votes',
        data: [7.4, 2.6],
        backgroundColor: ['rgba(255, 159, 64, 1)'],
        borderColor: [
          'rgba(255, 159, 64, 1)'],
        borderWidth: 0
        }]}

  componentDidMount: ->
    # chartCanvas = @refs.chart
    #
    # options = {
    #   type: 'doughnut',
    #   options: { legend: { display: false}, responsive: true },
    #   data: {
    #     labels: ["Your Score", "Total"],
    #     datasets: [{
    #       label: '# of Votes',
    #       data: [7.4, 2.6],
    #       backgroundColor: ['rgba(255, 159, 64, 1)'],
    #       borderColor: [
    #         'rgba(255, 159, 64, 1)'],
    #       borderWidth: 0
    #       }]}
    #   }
    #
    # @setState { chart: chartCanvas }

    @setState { cards: chiika.cardManager.cards }

    $('.card.image-card').click ->
      $('.card.image-card').toggleClass "expanded"

    chiika.ipc.getViewData (args) =>
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
