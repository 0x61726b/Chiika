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
Chart                               = require 'chart.js'
#Views

module.exports = React.createClass
  componentWillReceiveProps: ->
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
    chartCanvas = @refs.chart

    options = {
      type: 'doughnut',
      options: { legend: { display: false} },
      data: {
        labels: ["Your Score", "Total"],
        datasets: [{
          label: '# of Votes',
          data: [7.4, 2.6],
          backgroundColor: ['rgba(255, 159, 64, 1)'],
          borderColor: [
            'rgba(255, 159, 64, 1)'],
          borderWidth: 0
          }]}
      }
    @chart = new Chart(chartCanvas,options)

    @setState { chart: chartCanvas }

  componentDidUpdate: ->
    # chart = this.state.chart;
    # data = this.props.data;
    #
    # data.datasets.forEach((dataset, i) => chart.data.datasets[i].data = dataset.data);
    #
    # chart.data.labels = data.labels;
  componentWillUnmount: ->
    @chart.destroy()
  render: ->
    (<canvas ref={'chart'} height={'400'} width={'600'}></canvas>)
