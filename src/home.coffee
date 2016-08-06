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
Packery                             = require 'packery'
jQBridger                           = require 'jquery-bridget'
draggabilly                         = require 'draggabilly'
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
      options: { legend: { display: false}, responsive: true },
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
    # chart1 = new Chart(document.getElementById("canvas1"),options)
    # chart2 = new Chart(document.getElementById("canvas2"),options)
    # chart3 = new Chart(document.getElementById("canvas3"),options)
    # chart4 = new Chart(document.getElementById("canvas4"),options)

    @setState { chart: chartCanvas }

    window.$ = require 'jquery'



    # $.bridget 'packery',Packery
    # $.bridget 'draggabilly',draggabilly
    #
    # grid = $('.gridTest').packery({
    #   itemSelector: '.card.grid',
    #   percentPosition: true
    #   })


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
      <div className="card grid teal" id="card-thisWeek">
        <div className="grid-sizer"></div>
        <div className="home-inline title">
          <h1>This week</h1>
          <button type="button" className="teal raised button" name="button">History</button>
        </div>
        <ul className="yui-list floated divider">
          <li>Episodes watched <span className="label raised green">5</span></li>
          <li>Chapters read <span className="label raised teal">5</span></li>
          <li>Volumes read <span className="label raised lightblue">5</span></li>
          <li>Avg Episode/Week <span className="label raised indigo">5</span></li>
          <li>Avg Chapter/Week <span className="label raised purple">5</span></li>
          <li>Avg Volume/Week <span className="label raised pink">5</span></li>
        </ul>
      </div>
      <div className="card grid indigo" id="card-news">
        <div className="home-inline title">
          <h1>News</h1>
          <button type="button" className="button indigo raised" id="btn-play">View more on MAL</button>
  			</div>
        <ul className="yui-list news divider">
          <li> <span className="label raised red">Anime</span> Series Continuation of Senki Zesshou Symphogear Announced </li>
          <li> <span className="label raised red">Anime</span> Horimiya Anime Never </li>
          <li> <span className="label raised indigo">Music</span> Love Live! School Idol Project Group μs Wins Japan Gold Disc Awards </li>
          <li> <span className="label raised purple">Events</span> Baccano and Oregairu Light Novels Part of Yen Presss New Line-Up </li>
          <li> <span className="label raised orange">Manga</span> 4-koma Manga Nobunaga no Shinobi Gets TV Anime Adaptation </li>
          <li> <span className="label raised grey">Industry</span> Anime Blu-ray and DVD sales rankings.</li>
        </ul>
      </div>
      <div className="card grid currently-watching" id="card-cw">
        <div className="title">
          <div className="home-inline">
            <h1>Shirobako</h1>
            <button type="button" className="button raised red">Details</button>
          </div>
          <span id="watching-genre">
            <ul>
              <li>Comedy</li>
              <li>Drama</li>
              <li>Comedy</li>
              <li>Drama</li>
              <li>Comedy</li>
              <li>Drama</li>
            </ul>
          </span>
        </div>
        <div className="currently-watching-info">
          <div className="watching-cover">
            <img src="./../assets/images/cover1.jpg" width="150" height="225" alt="" />
            <button type="button" className="button raised lightblue">Share</button>
          </div>
          <div className="watching-info">
            <span className="info-miniCards">
              <div className="card pink">
                <div className="title">
                  <p className="mini-card-title">Score</p>
                </div>
                <div className="score-select">8.50
                  <div className="score-dropdown card pink">
                    <ul>
                      <li>1</li>
                      <li>2</li>
                      <li>3</li>
                      <li>4</li>
                      <li>5</li>
                      <li>6</li>
                      <li>7</li>
                      <li>8</li>
                      <li>9</li>
                      <li className="selected">10</li>
                    </ul>
                  </div>
                </div>
              </div>
              <div className="card purple">
                <div className="title">
                  <p className="mini-card-title">Type</p>
                </div>
                <p>TV</p>
              </div>
              <div className="card lightblue">
                <div className="title">
                  <p className="mini-card-title">Season</p>
                </div>
                <p>Fall 2014</p>
              </div>
              <div className="card indigo">
                <div className="title">
                  <p className="mini-card-title">Episode</p>
                </div>
                <p>6/24</p>
              </div>
              <div className="card green">
                <div className="title">
                  <p className="mini-card-title">Group</p>
                </div>
                <p>Commie</p>
              </div>
            </span>
            <p>
              Shirobako begins with the five members of the Kaminoyama High School animation club all making a pledge to work hard on their very first amateur production and make it into a success. After showing it to an audience at a culture festival, that pledge
              turned into a huge dream - to move to Tokyo, get jobs in the anime industry and one day join hands to create something amazing.
              <br/> Fast forward two and a half years and two of those members, Aoi Miyamori and Ema Yasuhara, have made their dreams into reality by landing jobs at a famous production company called Musashino Animation. Everything seems perfect at first. However,
              as the girls slowly discover, the animation industry is a bit tougher than they had imagined. Who said making your dream come true was easy?
            </p>
          </div>
        </div>
    	</div>
      <div className="card grid pink" id="card-soon">
        <div className="home-inline title">
          <h1>Soon™</h1>
          <button type="button" className="button raised pink" name="button">Calendar <i className="ion-android-calendar"></i></button>
        </div>
        <ul className="yui-list divider">
          <li><span className="label indigo">20:00<p className="detail">TUE</p></span> NEW GAME</li>
          <li><span className="label indigo">20:00<p className="detail">TUE</p></span> Kono Bijutsubu ni wa Mondai ga Aru!</li>
          <li><span className="label orange">15:00<p className="detail">TUE</p></span> Shokugeki no Soma</li>
          <li><span className="label raised orange">22:00<p className="detail">TUE</p></span> One Piece</li>
          <li><span className="label raised indigo">06:00<p className="detail">TUE</p></span> orange</li>
          <li><span className="label raised purple">06:00<p className="detail">HUE</p></span> Horimiya</li>
        </ul>
      </div>
      <div className="card grid continue-watching" id="card-cnw">
        <div className="title home-inline">
          <h1>Continue Watching</h1>
          <button type="button" className="button raised lightblue" name="button">Anime List <i className="ion-ios-list"></i></button>
        </div>
        <div className="recent-images">
          <div className="card image-card">
            <div className="watch-img">
              <img src="./../assets/images/cover1.jpg" width="120" height="180" alt="" />
              <a>Shirobako</a>
            </div>
            <div className="watch-info">
              <p>Kono Bijutsubu ni wa Mondai ga Aru!</p>
              <span className="label indigo">Episode 6 out of 12</span>
              <span>
              <span className="label red">TV</span>
              <span className="label teal">7.42</span>
              <span className="label orange">12 EPS</span>
              </span>
              <button type="button" className="button raised indigo" name="button">Details</button>
              <button type="button" className="button raised teal" name="button">Play next episode</button>
              <button type="button" className="button raised green" name="button">open folder</button>
            </div>
          </div>
        </div>
      </div>
    </div>
