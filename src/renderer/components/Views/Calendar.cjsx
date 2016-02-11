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
React = require 'react'
h = require './../Helpers'

class Calendar extends React.Component
  componentWillMount:() ->
    
  render: () ->
    (<div>
        <div className="calendar-titleBar">
            <span className="calendar-titleSpan">
                <h2 className="noSpace" id="anime-soon">Gintama° in less than 1 hour!</h2>
            </span>
        </div>
        <div className="calendarContainer">
            <div className="dayRow">
                <div className="day-name">
                    <h5 className="day-text">Mon</h5>
                </div>
                <div className="chipContainer">
                    <button className="animeChip chip-aired">Gintama S4 13:30</button>
                    <button className="animeChip chip-notAired">Gintama S4 13:30</button>
                </div>
            </div>

            <div className="dayRow row-active">
                <div className="day-name currentDay">
                    <h5 className="day-text">Tue</h5>
                </div>
                <div className="chipContainer">
                </div>
            </div>

            <div className="dayRow">
                <div className="day-name">
                    <h5 className="day-text">wEd</h5>
                </div>
                <div className="chipContainer">
                </div>
            </div>

            <div className="dayRow">
                <div className="day-name">
                    <h5 className="day-text">thU</h5>
                </div>
                <div className="chipContainer">
                </div>
            </div>

            <div className="dayRow">
                <div className="day-name">
                    <h5 className="day-text">Fri</h5>
                </div>
                <div className="chipContainer">
                </div>
            </div>

            <div className="dayRow">
                <div className="day-name">
                    <h5 className="day-text">Sun</h5>
                </div>
                <div className="chipContainer">
                </div>
            </div>

            <div className="dayRow">
                <div className="day-name">
                    <h5 className="day-text">sat</h5>
                </div>
                <div className="chipContainer">
                </div>
            </div>
        </div>
    </div>);

module.exports = Calendar
