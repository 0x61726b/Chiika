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

React = require('react')
{Router,Route,BrowserHistory,Link} = require('react-router')
ReactRouter = require('react-router')

_ = require 'lodash'
History = ReactRouter.History
AnimeDetailsHelper = require './anime-details-helper'
#Views

module.exports = React.createClass
  mixins: [History]
  updateCover: ->
    coverImage = @detailsHelper.checkCoverImage @props.params.animeId
    if !_.isUndefined coverImage
      $("#coverImg").attr("src",coverImage)
  componentDidMount: ->
    @updateCover()

    if @pendingUpdates
      @forceUpdate()
    @forceUpdate()
  setCurrentAnimeFromDb: ->
    @currentAnime = chiika.getAnimeById @props.params.animeId
    @detailsHelper = new AnimeDetailsHelper @currentAnime
    console.log @currentAnime
  componentWillMount: ->
    chiika.emitter.on 'download-image', (args) =>
      console.log args
      if args.downloadedEntry == @props.params.animeId
        console.log "HUEHRUEHEU"
        @updateCover()

    @setCurrentAnimeFromDb()
    console.log "Anime Details Will Mount : " + @props.params.animeId

    chiika.emitter.on 'anime-details-update', (updateInfo) =>
      @setCurrentAnimeFromDb()
      if @isMounted()
        @forceUpdate()
      else
        @pendingUpdates = true
  updateScore: ->
    console.log "Update"
  minusProgress: ->
    console.log "Minus Progress"
  plusProgress: ->
    console.log "Plus Progress"
  updateStatus: ->
    console.log "Update Status"
  render: () ->
    (<div id="animeDetails">
      <div className="" id="animeTitle">
            <div className="backButtonDiv" onClick={this.history.goBack}>
                <i className="centerMe fa fa-angle-left fa-2x" id="backButton"></i>
            </div>
            <div className="titleDiv">
              <h2 className="centerMe noSpace" id="animeName">{@currentAnime.series_title}</h2>
            </div>
            <div className="airingStatsuDiv">
                <span className="label label-primary" id="airingStatus"></span>
            </div>
        </div>
        <div className="vCenter" id="animeGenre">
                <h4 className="vCenter">
                {if @currentAnime.misc_genres?
                  @currentAnime.misc_genres.map((tab, i) =>
                    <span key={i} className="label indigo">{tab}</span>)}
                </h4>
        </div>
        <div className="row" id="detailsRow">
            <div className="coverImage">
                <div className="cIm"><img id="coverImg" onClick={@openMalLink} src="./../assets/images/topLeftLogo.png" /></div>
            </div>
            <div className="cardColumn" id="col1">
                <div className="detailCard cardInfo card-twoLine" id="typeCard" style={{backgroundImage: 'url(' + @detailsHelper.getTypeImage(@currentAnime)+ ')' }}>
                    <h5 className="noSpace">Type</h5>
                    <h4 className="noSpace" id="cardInfo">{@detailsHelper.getType(@currentAnime)}</h4>
                </div>
                <div className="detailCard cardInfo card-twoLine" id="sourceCard" style={{backgroundImage: 'url(' + @detailsHelper.getSourceImage(@currentAnime)+ ')' }}>
                    <h5 className="noSpace">Source</h5>
                    <h4 className="noSpace" id="cardInfo">{@currentAnime.misc_source}</h4>
                </div>
                <div className="detailCard cardInfo card-twoLine" id="card3">
                    <h5 className="noSpace">Duration</h5>
                    <h4 className="noSpace" id="cardInfo">{@currentAnime.duration}</h4>
                </div>
                <div className="detailCard cardInfo card-twoLine" id="card4">
                    <h5 className="noSpace">Studio</h5>
                    <h4 className="noSpace" id="cardInfo">{if @currentAnime.misc_studio?
                     @currentAnime.misc_studio.name}</h4>
                </div>
            </div>
            <div className="cardColumn" id="col2">
                <div className="detailCard" id="scoreCard">
                    <div id="malScore">
                        <h5 className="noSpace">SCORE</h5>
                        <h4 className="noSpace">{@currentAnime.misc_score}</h4>
                    </div>
                    <div id="userScore" className="why">
                        <h5 className="noSpace">RATE</h5>
                        <div className="dropdown" id="scoreDropdown">
                          <button type="button" className="scoreButton dropdown-toggle" id="dropdownMenu1" data-toggle="dropdown" aria-haspopup="true" aria-expanded="true">
                              <h4 className="noSpace">{@currentAnime.my_score}</h4>
                              <span className="caret"></span>
                          </button>
                          <ul className="dropdown-menu scoreDd" aria-labelledby="dropdownMenu1">
                          {[0,1,2,3,4,5,6,7,8,9,10].map((score, i) =>
                            <li key={i}>
                              {
                                s = score
                                if score == 0
                                  s = "-"
                                if score == parseInt(@currentAnime.my_score)
                                  (<div id="selected" onClick={@updateScore}>{s}</div>)
                                else
                                  (<div onClick={@updateScore}>{s}</div>)
                                }
                            </li>)}
                          </ul>
                        </div>
                    </div>
                </div>
                <div className="detailCard" id="episodeCard">
                    <div id="epTotal">
                        <h5 className="noSpace">Episodes</h5>
                        <h4 className="noSpace">{@currentAnime.series_episodes}</h4>
                    </div>
                    <div id="epWatched">
                        <h5 className="noSpace" id="watched">Watched</h5>
                        <div className="inputArea">
                            <i className=" fa  fa-minus-square" id="progressMinus" onClick={@minusProgress}></i>
                            <div className="input-group">
                              <input id="episodeWatchedInput" type="text" className="episodeInput" aria-describedby="basic-addon1" />
                            </div>
                            <i className="fa fa-plus-square" id="progressPlus" onClick={@plusProgress}></i>
                        </div>
                    </div>
                </div>
                <div className="detailCard" id="statusCard">
                    <div id="userScore" className="why">
                        <h5 className="noSpace">STATUS</h5>
                        <div className="dropdown" id="statusDropdown">
                          <button type="button" className="statusButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="true">
                              <h4 className="noSpace">{@detailsHelper.getStatus(@currentAnime)}</h4>
                              <span className="caret"></span>
                          </button>
                          <ul className="dropdown-menu statusDd">
                              {
                                @detailsHelper.statusTextMap.map((status,i) =>
                                  <li key={i}>
                                    <div onClick={@updateStatus} data-status={status.status}>{status.text}</div>
                                  </li>
                              )}
                          </ul>
                        </div>
                    </div>
                </div>
                <div id="seasonId" className={@detailsHelper.getSeasonClass(@currentAnime)}>
                    <h3 className="noSpace seasonInfo">{@detailsHelper.getSeason(@currentAnime)}</h3>
                </div>
            </div>
        </div>
        <div className="row" id="buttonRow">
            <div className="buttonConatiner">
                <button type="button" className="chiika-button" id="btn-play">Play Next Episode</button>
                <button type="button" className="chiika-button" id="btn-folder">Open Folder</button>
                <button type="button" className="chiika-button" id="btn-torrent">Check for Torrent</button>
                <button onClick={this.openMalLink} type="button" className="chiika-button" id="btn-mal">Open on MAL</button>
            </div>
        </div>
        <div className="row" id="synopsisRow">
            <div className="synopsisContainer">
              <div className="leftColumn">
                  <div className="synopsisColumn">
                      <h3>Alternative Titles</h3>
                      <p>
                          <b>English:</b> {@currentAnime.series_english}
                      </p>

                      <p>
                          <b>Synonyms:</b> {@currentAnime.series_synonyms}
                      </p>
                      <p>
                          <b>Japanese:</b> {@currentAnime.japanese}
                      </p>
                  </div>
                  <div className="synopsisColumn">
                      <h3>synopsis</h3>
                      <p id="synopsisText" dangerouslySetInnerHTML={{ __html: @detailsHelper.getSynopsis(@currentAnime) }}></p>
                  </div>
                </div>
                <div className="characterColumn">
                    <h3>characters</h3>
                        {
                          if @currentAnime.characters?
                            @currentAnime.characters.map((ch,i) =>
                              <div key={i} className="characterRow">
                                <span className="characterInfo">
                                    <h4>{ch.name}</h4>
                                    <h5>{ch.voiceActors[0].name}</h5>
                                </span>
                                <span className="characterImage">
                                    <img src={ch.image} onClick={@detailsHelper.openCharacterPage} data-ch-id={ch.id} width="50px"/>
                                </span>
                              </div>
                        )}
                </div>
            </div>
        </div>
      </div>)
