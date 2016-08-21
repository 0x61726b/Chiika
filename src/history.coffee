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
_filter                             = require 'lodash/collection/filter'
#Views

module.exports = React.createClass
  getInitialState: ->
    charts: []

  componentWillReceiveProps: (props) ->


  componentDidMount: ->
    @init()


    # @setState { cards: chiika.cardManager.cards }
    #
    #
    # chiika.ipc.getViewData (args) =>
    #   if @isMounted()
    #     @setState { cards: chiika.cardManager.cards }

  init: ->
    historyView = _filter chiika.viewData, (o) -> o.name.indexOf('_history') != -1

    charts = []
    _forEach historyView, (history) =>
      chartConfig = history.dataSource

      if chartConfig?
        _forEach chartConfig, (chart) =>
          charts.push @createChartFromPoints(chart)
          console.log chart

    @setState { charts: charts }


  createChartFromPoints: (config) ->
    options = {
      type: 'line',
      data: {
        labels: config.labels
        datasets: []
      }
    }
    _forEach config.datasets, (dataset) =>
      options.data.datasets.push @getDataset dataset.name,dataset.data,dataset.color

    @chart = new Chart(document.getElementById("test1"),options)

  getDataset: (label,data,color) ->
    dataset = {
        label: label,
        fill: false,
        lineTension: 0.3,
        backgroundColor: color,
        borderColor: color,
        borderCapStyle: 'butt',
        borderDash: [],
        borderDashOffset: 0.0,
        borderJoinStyle: 'miter',
        pointBorderColor: color,
        pointBackgroundColor: "#fff",
        pointBorderWidth: 1,
        pointHoverRadius: 5,
        pointHoverBackgroundColor: "rgba(75,192,192,1)",
        pointHoverBorderColor: "rgba(220,220,220,1)",
        pointHoverBorderWidth: 2,
        pointRadius: 1,
        pointHitRadius: 10,
        data: data,
        spanGaps: false}
    dataset

  componentWillUnmount: ->

  render: ->
    <div>
      <canvas id="test1" width="600" height="500"></canvas>
    </div>
