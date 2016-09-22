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
Loading                             = require './loading'
_forEach                            = require 'lodash/collection/forEach'
_indexOf                            = require 'lodash/array/indexOf'
_find                               = require 'lodash/collection/find'


module.exports = React.createClass
  getInitialState: ->
    dataByDay: {}
  componentWillMount: ->
    # Load calendar data
    calendarData =  _find chiika.viewData, (o) -> o.name == 'calendar_senpai'

    if calendarData?
      data = calendarData.dataSource

      days = ["Sat","Sun","Mon","Tue","Wed","Thu","Fri"]
      days.map (day,i) =>
        @state.dataByDay[day] = []

      _forEach data, (v,k) =>
        @state.dataByDay[k].push x for x in v

  renderSingleItem: (item,index) ->
    <div className="day-series" key={index}>
      <div className="series-hour">
        {item.time}
      </div>
      <div className="series-episode">
        Ep. 3
      </div>
      <div className="series-title">
        {item.name} | {item.simulcast}
      </div>
      <div className="series-buttons">
        <button type="button" className="button lightblue">Details</button>
        <button type="button" className="button lightblue">Library</button>
      </div>
    </div>

  render: ->
    <div>
    {
      ["Sat","Sun","Mon","Tue","Wed","Thu","Fri"].map (dayOfWeek,i) =>
        <div key={i}>
          <div className="day-row" key={i}>
            <div className="day-title">
              <span className="timeline">
                <span className="timeline-circle">
                  <p>{dayOfWeek}</p>
                </span>
              </span>
            </div>
            <div className="day-series-list">
            {
              @state.dataByDay[dayOfWeek].map (item,i) =>
                @renderSingleItem(item,i)
            }
            </div>
          </div>
        </div>
    }
    </div>
