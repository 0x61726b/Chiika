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
moment = require 'moment-timezone'

#Views

module.exports = React.createClass
  getInitialState: ->
    calendarShowType: 0 #0 = User's watching list #1 = User's complete list #2 Everything
    closestAnime: {}
  componentWillMount: ->
    @calculateCalendarData()
    chiika.emitter.on 'calendar-ready', =>
      @calculateCalendarData()

    chiika.emitter.on 'anime-details-update', (arg) =>
      @state.closestAnime = chiika.getAnimeById(@state.closestAnime.series_animedb_id)
      _.assign @state.closestAnime, { date: @closestShows[0].date }
      @forceUpdate()
    chiika.emitter.on 'download-image', =>
      if @isMounted()
        @forceUpdate()
  calculateCalendarData: ->
    if chiika.calendarData?
      console.log "Recalculate calendar dara"
      @entriesInTimezone = []
      @entriesInUserList = []
      @entriesUserWatching = []

      animeListDb = chiika.animeList

      utcOffset = chiika.getUserTimezone().offset



      _.forEach chiika.calendarData.items, (v,k) =>
        airDates = v.airdates
        _.forOwn airDates, (value,key) =>
          if parseInt(key) == utcOffset
            @entriesInTimezone.push v
            return false
      _.forEach chiika.calendarData.items, (v,k) =>
        MALID = v.MALID

        searchAnimelist = _.find animeListDb.anime, { series_animedb_id: MALID }

        if searchAnimelist?
          airDates = v.airdates
          _.forOwn airDates, (value,key) =>
            if parseInt(key) == utcOffset
              @entriesInUserList.push v
              return false
      _.forEach @entriesInUserList, (v,k) =>
        malid = v.MALID
        searchAnimelist = _.find animeListDb.anime, { series_animedb_id: malid }
        if searchAnimelist?
          if searchAnimelist.my_status == '1' #MAL status Watching
            @entriesUserWatching.push v


      if @state.calendarShowType == 0
        @closestShows = @getClosestCalendarEntry @entriesUserWatching
      if @state.calendarShowType == 1
        @closestShows = @getClosestCalendarEntry @entriesInUserList
      if @state.calendarShowType == 2
        @closestShows = @getClosestCalendarEntry @entriesInTimezone

      if @closestShows[0]?
        closestShow = @closestShows[0]
        malid = closestShow.entry.MALID

        closestAnime = chiika.getAnimeById malid
        _.assign closestAnime, { date: closestShow.date }

        @setState {closestAnime: closestAnime}

        chiika.animeDetailsPreRequest malid
  #Returns the next sorted show dates, closest one will be at 0th index
  getClosestCalendarEntry: (list) ->
    if list?
      airdates = []

      compareDates = (a,b) ->
        if a.milliseconds < b.milliseconds
          return -1
        else if b.milliseconds < a.milliseconds
          return 1
        else
          return 0
      currentDate = moment()
      userTimezone = chiika.getUserTimezone().offset
      _.forEach list, (v,k) ->
        weeklyAirDate = _.find v.airdates,(v,k) -> return parseInt(k) == userTimezone
        originalAirDate = moment(v.airdate, 'DD/MM/YYYY HH:mm')
        if moment().isAfter(originalAirDate)
          if weeklyAirDate?
            #weeklyAirDate = { rd_date: 02 Jul, rd_time: 16:30, rd_weekday: Sat, weekday: 6 }
            #How to find closest date
            #Senpai data shows the date of the first weeks airing
            #Convert it to DD/MM/YYYY HH:mm and add current date then sort

            weeklyAirDateHour = weeklyAirDate.rd_time.substring(0,2)
            weeklyAirDateMinute = weeklyAirDate.rd_time.substring(3,5)
            nextShowday = moment().hour(weeklyAirDateHour).minute(weeklyAirDateMinute).add(Math.abs(currentDate.day() - weeklyAirDate.weekday),'d')

            airdates.push { entry: v, date: nextShowday, milliseconds: nextShowday.valueOf() }

      airdates.sort(compareDates)
      airdates

  getShowsAtDay: (day) -> #day is [Mon,Tue,Wed,Thurs,Fri,Sat,Sun]
    userTimezone = chiika.getUserTimezone().offset
    showsAtThisDay = []
    if @state.calendarShowType == 0 #Watching list
      _.forEach @entriesUserWatching, (v,k) ->
        originalAirDate = moment(v.airdate, 'DD/MM/YYYY HH:mm')
        if moment().isAfter(originalAirDate)
          weeklyAirDate = _.find v.airdates,(v,k) -> return parseInt(k) == userTimezone
          if weeklyAirDate?
            if weeklyAirDate.rd_weekday == day
              showsAtThisDay.push { time: weeklyAirDate.rd_time, title: v.name, simDelay: v.simulcast_delay, simulcast: v.simulcast }
    if @state.calendarShowType == 1 #User's complete list
      _.forEach @entriesInUserList, (v,k) ->
        originalAirDate = moment(v.airdate, 'DD/MM/YYYY HH:mm')
        if moment().isAfter(originalAirDate)
          weeklyAirDate = _.find v.airdates,(v,k) -> return parseInt(k) == userTimezone
          if weeklyAirDate?
            if weeklyAirDate.rd_weekday == day
              showsAtThisDay.push { time: weeklyAirDate.rd_time, title: v.name, simDelay: v.simulcast_delay, simulcast: v.simulcast }
    if @state.calendarShowType == 2 #Everything in this timezone
      _.forEach @entriesInTimezone, (v,k) ->
        originalAirDate = moment(v.airdate, 'DD/MM/YYYY HH:mm')
        if moment().isAfter(originalAirDate)
          weeklyAirDate = _.find v.airdates,(v,k) -> return parseInt(k) == userTimezone
          if weeklyAirDate?
            if weeklyAirDate.rd_weekday == day
              showsAtThisDay.push { time: weeklyAirDate.rd_time, title: v.name, simDelay: v.simulcast_delay, simulcast: v.simulcast }
    return showsAtThisDay
  componentDidMount: ->
    console.log @closestShows
  onCalendarViewChange: (e) ->
    #@setState { calendarShowType: parseInt(e.target.value) }
    @state.calendarShowType = parseInt(e.target.value)
    @calculateCalendarData()
  getCurrentDay: (day) ->
    currentDayStr = moment.weekdays()[moment().day()]

    if day == currentDayStr
      'day-row currentDay'
    else
      'day-row'

  getDayHtml: (i,show) -> #Change the outmost <div> to <span> and see what happens
    <div className="label theme-accent" key={i}>{show.title}
      <p className="detail">{show.time}</p>
      <p className="detail">{show.simulcast}
         {
           if show.simDelay != 0
              " (+" + show.simDelay + ")"
         }
      </p>
    </div>
    
  render: () ->
    (<section className="calendar-container">
      <select style={{float:'right' }} className="button red raised" onChange={this.onCalendarViewChange} value={@state.calendarShowType}>
      	<option value="0">Watching List</option>
        <option value="1">Complete User List</option>
        <option value="2">Season</option>
      </select>
      <div className="card" id="calendar-card">
        <div className="cal-upnext">
          <div className="upnext-anime">
            <img src={chiika.getAnimeCoverById(@state.closestAnime.series_animedb_id)} height="180" className="calendar-image" alt="" />
            <div className="upnext-info">
              <h2>On { moment.weekdays()[@state.closestAnime.date.weekday()] } - { @state.closestAnime.date.format('HH:mm') }</h2>
              <h3>{ @state.closestAnime.series_title }</h3>
              <span>
                <h4>{ chiika.animeHelper.getType(@state.closestAnime)}</h4>
                <h4>{ @state.closestAnime.misc_score }</h4>
                <button type="button" className="button teal raised" name="button">Eh</button>
              </span>
              <p dangerouslySetInnerHTML={{ __html: chiika.animeHelper.getSynopsis(@state.closestAnime) }} />
            </div>
          </div>
        </div>
        <div className={@getCurrentDay('Monday')}>
          <div className="day-title">
            <span className="timeline">
            <span className="timeline-circle">
              <p>MON</p>
            </span>
            </span>
          </div>
          <div className="day-series">
            {
              (@getShowsAtDay 'Mon').map (show,i) =>
                @getDayHtml i,show
            }
          </div>
        </div>
        <div className={@getCurrentDay('Tuesday')}>
          <div className="day-title">
            <span className="timeline">
            <span className="timeline-circle">
              <p>TUE</p>
            </span>
            </span>
          </div>
          <div className="day-series">
            {
              (@getShowsAtDay 'Tue').map (show,i) =>
                @getDayHtml i,show
            }
          </div>
        </div>
        <div className={@getCurrentDay('Wednesday')}>
          <div className="day-title">
            <span className="timeline">
            <span className="timeline-circle">
              <p>WED</p>
            </span>
            </span>
          </div>
          <div className="day-series">
            {
              (@getShowsAtDay 'Wed').map (show,i) =>
                @getDayHtml i,show
            }
          </div>
        </div>
        <div className={@getCurrentDay('Thursday')}>
          <div className="day-title">
            <span className="timeline">
            <span className="timeline-circle">
              <p>THU</p>
            </span>
            </span>
          </div>
          <div className="day-series">
            {
              (@getShowsAtDay 'Thu').map (show,i) =>
                @getDayHtml i,show
            }
          </div>
        </div>
        <div className={@getCurrentDay('Friday')}>
          <div className="day-title">
            <span className="timeline">
            <span className="timeline-circle">
              <p>FRI</p>
            </span>
            </span>
          </div>
          <div className="day-series">
          {
            (@getShowsAtDay 'Fri').map (show,i) =>
              @getDayHtml i,show
          }
          </div>
        </div>
        <div className={@getCurrentDay('Saturday')}>
          <div className="day-title">
            <span className="timeline">
            <span className="timeline-circle">
              <p>SAT</p>
            </span>
            </span>
          </div>
          <div className="day-series">
          {
            (@getShowsAtDay 'Sat').map (show,i) =>
              @getDayHtml i,show
          }
          </div>
        </div>
        <div className={@getCurrentDay('Sunday')}>
          <div className="day-title">
            <span className="timeline">
            <span className="timeline-circle">
              <p>SUN</p>
            </span>
            </span>
          </div>
          <div className="day-series">
          {
            (@getShowsAtDay 'Sun').map (show,i) =>
              @getDayHtml i,show
          }
          </div>
        </div>
      </div>
    </section>)
