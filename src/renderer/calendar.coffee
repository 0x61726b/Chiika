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
#authors: arkenthera, bera
#Description:
#----------------------------------------------------------------------------

React = require('react')
{Router,Route,BrowserHistory,Link} = require('react-router')


_ = require 'lodash'

#Views

module.exports = React.createClass
  render: () ->
    (<div className="card" id="calendar-card">
      <div className="cal-upnext">
        <div className="upnext-anime">
          <img src="73974.jpg" height="180" className="calendar-image" alt="" />
          <div className="upnext-info">
            <h2>On --</h2>
            <h3>Sket Dance</h3>
            <span>
              <h4>TV</h4>
              <h4>8.34</h4>
              <button type="button" className="button teal raised" name="button">Eh</button>
            </span>
            <p>
              At Kaimei High School, the Living Assistance Club (aka the Sket Brigade) was organized to help students with problems big or small. Most of the time, though, they hang out in their club room, bored, with only a few trivial problems floating in every once
              in a while. In spite of this, they still throw all their energy into solving these worries.
            </p>
          </div>
        </div>
      </div>
      <div className="day-row">
        <div className="day-title">
          <span className="timeline">
          <span className="timeline-circle">
            <p>MON</p>
          </span>
          </span>
        </div>
        <div className="day-series">
          <span className="label theme-accent">Tintama</span>
        </div>
      </div>
      <div className="day-row">
        <div className="day-title">
          <span className="timeline">
          <span className="timeline-circle">
            <p>TUE</p>
          </span>
          </span>
        </div>
        <div className="day-series">
          <span className="label theme-accent">Tintama</span>
        </div>
      </div>
      <div className="day-row">
        <div className="day-title">
          <span className="timeline">
          <span className="timeline-circle">
            <p>WED</p>
          </span>
          </span>
        </div>
        <div className="day-series">
          <span className="label theme-accent">Tintama</span>
        </div>
      </div>
      <div className="day-row">
        <div className="day-title">
          <span className="timeline">
          <span className="timeline-circle">
            <p>THU</p>
          </span>
          </span>
        </div>
        <div className="day-series">
          <span className="label theme-accent">Tintama</span>
          <span className="label theme-accent">Tintama</span>
          <span className="label theme-accent">Tintama</span>
        </div>
      </div>
      <div className="day-row currentDay">
        <div className="day-title">
          <span className="timeline">
          <span className="timeline-circle">
            <p>FRI</p>
          </span>
          </span>
        </div>
        <div className="day-series">
          <span className="label theme-accent">Tintama</span> <span className="label theme-accent">Tintama</span>
          <span className="label theme-accent">Tintama</span>

        </div>
      </div>
      <div className="day-row">
        <div className="day-title">
          <span className="timeline">
          <span className="timeline-circle">
            <p>SAY</p>
          </span>
          </span>
        </div>
        <div className="day-series">
          <span className="label theme-accent">Tintama</span> 
          <span className="label theme-accent">Tintama</span>
          <span className="label theme-accent">Tintama</span>
          <span className="label theme-accent">Tintama</span>

        </div>
      </div>
      <div className="day-row">
        <div className="day-title">
          <span className="timeline">
          <span className="timeline-circle">
            <p>SUN</p>
          </span>
          </span>
        </div>
        <div className="day-series">
        </div>
      </div>
    </div>)
