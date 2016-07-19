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
#Date: 31.1.2016
#authors: arkenthera
#Description:
#
fs = require 'fs'
path = require 'path'
React = require 'react'
Router = require 'react-router'
Chiika = require './../../ChiikaNode'
shell = require 'shell'
History = Router.History

AnimeDetails = React.createClass
  mixins: [ History ]
  anime:null
  coverPath:""
  coverExists:false
  statusTextMap:[
    { status:1,text:"Watching" },
    { status:6,text:"Plan to Watch" },
    { status:2,text:"Completed" },
    { status:3,text:"On Hold" },
    { status:4,text:"Dropped" }
  ]
  componentWillMount:-> #We can't put jQuery here because DOM is not constructed yet.
    @anime = chiika.chiika.getAnimeById(@props.params.animeId)
    console.log @anime

    animeCover = path.join(chiika.appOptions.imagePath,"Anime", @anime.series_animedb_id + ".jpg")

    try
      file = fs.statSync(animeCover)
      @coverExists = true
    catch error
      @coverExists = false

    chiika.chiika.addRequestListener 'AnimeDetails',this
  componentDidMount:->
    $("#seasonId").addClass @getSeasonClass()

    $("#episodeWatchedInput").val(@anime.my_watched_episodes)
    @getCoverImage()
    @getBroadcastTime()
    @getSynopsis()
    @getSource()

    @handleProgressEnter()

    chiika.appDel.requestAnimeDetails(@anime.series_animedb_id)
  componentWillUnmount: ->
    console.log "Unmount"
    chiika.chiika.removeRequestListener 'AnimeDetails',this

  onRequest: (request) ->
    @anime = chiika.chiika.getAnimeById(@props.params.animeId)

    @getSource()
    @getSynopsis()
    @getBroadcastTime()
    @forceUpdate()
  refreshImage: () ->
    @getCoverImage()
    @forceUpdate()

  refreshMinorInfo: () ->
    @anime = chiika.chiika.getAnimeById(@props.params.animeId)

    @getSource()
    @getSynopsis()
    @getBroadcastTime()
    @forceUpdate()

    console.log "Refresh anime Info"

  getCharacters: () ->
    @anime.Misc.characters
  openCharacterPage: (e) ->
    id = $(e.target).attr("data-ch-id")
    url = "http://myanimelist.net/character/" + id
    shell.openExternal(url)
  getGenres: () ->
    @anime.Misc.genres
  getBroadcastTime: () ->
    if @anime.anime.series_status == "0"
      $(".airingStatsuDiv span").text("Not aired")
    if @anime.anime.series_status == "1"
      if @anime.Misc.broadcast_time != "broadcast_time" || @anime.Misc.broadcast_time != "Unknown" || @anime.Misc.broadcast_time != ""
        $(".airingStatsuDiv span").text("Airing " + @anime.Misc.broadcast_time)
    if @anime.anime.series_status == "2"
      $(".airingStatsuDiv span").text("Finished Airing")
  getCoverImage: () ->
    animeCover = path.join(chiika.appOptions.imagePath,"Anime",@anime.series_animedb_id + ".jpg")
    try
      file = fs.statSync(animeCover)
      @coverExists = true
    catch error
      @coverExists = false
    if @coverExists
      animeCover = path.join(chiika.appOptions.imagePath,"Anime",@anime.series_animedb_id + ".jpg")
      $("#coverImg").attr("src",animeCover)
      $("#coverImg").removeClass("loadingSomething")
      $(".cIm").removeClass("rotateLogo")
    else
      $("#coverImg").addClass("loadingSomething")
      $(".cIm").addClass("rotateLogo")
  getStatus:() ->
    id = @anime.my_status
    status = ""
    if id == "1"
      status = "Watching"
    if id == "2"
      status = "Completed"
    if id == "3"
      status = "On Hold"
    if id == "4"
      status = "Dropped"
    if id == "6"
      status = "Plan to Watch"

    status
  getType:() ->
    type = @anime.anime.series_type
    animeType = ""
    bgImage = ""

    if type == "0"
      animeType = "Unknown"
    if type == "1"
      animeType = "TV"
      bgImage = "./../assets/images/detailsCards/type/alt-tv.png"
    if type == "2"
      animeType = "OVA"
      bgImage = "./../assets/images/detailsCards/type/alt-ova.png"
    if type == "3"
      animeType = "Movie"
      bgImage = "./../assets/images/detailsCards/type/alt-movie.png"
    if type == "4"
      animeType = "Special"
      bgImage = "./../assets/images/detailsCards/type/alt-special.png"
    if type == "5"
      animeType = "ONA"
      bgImage = "./../assets/images/detailsCards/type/alt-ona.png"
    if type == "6"
      animeType = "Music"
      bgImage = "./../assets/images/detailsCards/type/alt-music.png"

    $("#typeCard").css('background-image',"url('"+bgImage+"')")
    animeType
  getSource:() ->
    source = @anime.Misc.source

    if source == "source"
      source = "Unknown"

    bgImage = ""
    if source == "Manga"
      bgImage = "./../assets/images/detailsCards/source/manga-50.png"
    if source == "Original"
      bgImage = "./../assets/images/detailsCards/source/original-50.png"
    if source == "Unknown"
      bgImage = "./../assets/images/detailsCards/source/unknown-50.png"
    if source == "Light novel"
      bgImage = "./../assets/images/detailsCards/source/light-novel-50.png"
    if source == "Novel"
      bgImage = "./../assets/images/detailsCards/source/novel-50.png"
    if bgImage != ""
      $("#sourceCard").css('background-image',"url('"+bgImage+"')")
    source
  getDuration: ->
    duration = @anime.Misc.duration

    if duration == "duration"
      duration = "24 min. per ep."
    duration
  getStudio: () ->
    studio = null
    firstStudioName = "Unknown"
    if @anime.Misc.studios != null
      studio = @anime.Misc.studios[0]
      if studio != undefined
        firstStudioName = studio.studio_name

    firstStudioName
  getSeason: () ->
    startDate = @anime.anime.series_start

    parts = startDate.split("-");
    year = parts[0];
    month = parts[1];

    iMonth = parseInt(month);

    season = ""
    sClass = ""
    if iMonth > 0 && iMonth < 4
      season =  "Winter " + year
      sClass = "season-winter"
    if iMonth > 3 && iMonth < 7
      season =  "Spring " + year
      sClass = "season-spring"
    if iMonth > 6 && iMonth < 10
      season =  "Summer " + year
      sClass = "season-summer"
    if iMonth > 9 && iMonth <= 12
      season = "Fall " + year
      sClass = "season-fall"
    season
  getSeasonClass: ->
    startDate = @anime.anime.series_start

    parts = startDate.split("-");
    year = parts[0];
    month = parts[1];

    iMonth = parseInt(month);

    season = ""
    sClass = ""
    if iMonth > 0 && iMonth < 4
      season =  "Winter " + year
      sClass = "season-winter"
    if iMonth > 3 && iMonth < 7
      season =  "Spring " + year;
      sClass = "season-spring"
    if iMonth > 6 && iMonth < 10
      season =  "Summer " + year;
      sClass = "season-summer"
    if iMonth > 9 && iMonth <= 12
      season = "Fall " + year;
      sClass = "season-fall"
    sClass
  getScore: ->
    score = @anime.Misc.avg_score

    if score == 'avg_score'
      score = "-"
    score
  getEpisodeCount: ->
    episodeCount = @anime.anime.series_episodes

    if episodeCount == "0"
      episodeCount = "-"
    episodeCount
  getSynopsis: ->
    synopsis = @anime.anime.synopsis
    synopsisInMisc = @anime.Misc.synopsis

    synopsis = synopsis.replace(/\[i\]/g,"<i>")
    synopsis = synopsis.replace(/\[\/i\]/g,'</i>')

    synInAnime = false
    if @anime.anime.synopsis == "synopsis"
      synInAnime = false
    else
      synInAnime = true

    synInMisc = false
    if @anime.Misc.synopsis == "synopsis"
      synInMisc = false
    else
      synInMisc = true

    if !synInMisc && !synInAnime
      $("#synopsisText").html("Loading...")
    else
      if synInMisc
        $("#synopsisText").html(synopsisInMisc)
      if synInAnime
        $("#synopsisText").html(synopsis)
  openMalLink: ->
    shell.openExternal("http://myanimelist.net/anime/" + @anime.anime.series_animedb_id)
  updateScore: (e) ->
    score = $(e.target).text()
    if score == "-"
      score = "0"
    console.log "Updating score to " + score + " for " + @anime.anime.series_animedb_id
    $("#scoreDropdown button h4").text(score)
    Chiika.requestAnimeUpdate(@anime.anime.series_animedb_id,parseInt(score),-1,-1)
  updateStatus: (e) ->
    status = $(e.target).attr("data-status")
    console.log "Updating status to " + status + " for " + @anime.anime.series_animedb_id

    res = $.grep @statusTextMap, (e) ->
      e.status == parseInt(status)


    $("#statusDropdown button h4").text(res[0].text)
    Chiika.requestAnimeUpdate(@anime.anime.series_animedb_id,-1,-1,parseInt(status))
  plusProgress: (e) ->
    currentWatched = $("#episodeWatchedInput").val()
    totalEps = @anime.anime.series_episodes
    totalEps = parseInt(totalEps)
    currentWatched = parseInt(currentWatched)

    plusOne = currentWatched + 1
    if plusOne <= totalEps
      console.log "Updating progress from " + currentWatched + "/" + totalEps + " to " + plusOne + "/" + totalEps;
      $("#episodeWatchedInput").val(plusOne)
      Chiika.requestAnimeUpdate(@anime.anime.series_animedb_id,-1,plusOne,-1)
  minusProgress: (e) ->
    currentWatched = $("#episodeWatchedInput").val()
    totalEps = @anime.anime.series_episodes
    totalEps = parseInt(totalEps)
    currentWatched = parseInt(currentWatched)

    minusOne = currentWatched - 1

    if minusOne >= 0
      console.log "Updating progress from " + currentWatched + "/" + totalEps + " to " + minusOne + "/" + totalEps;
      $("#episodeWatchedInput").val(minusOne)
      Chiika.requestAnimeUpdate(@anime.anime.series_animedb_id,-1,minusOne,-1)
  handleProgressEnter: ->
    anime = @anime
    $("#episodeWatchedInput").keyup (e) ->
      if e.keyCode == 13 #Enter
        newProgress = $(this).val()
        newProgress = parseInt(newProgress)
        totalEps = anime.anime.series_episodes
        totalEps = parseInt(totalEps)
        if newProgress >= 0 && newProgress <= totalEps
          console.log "Updating progress to " + newProgress + "/" + totalEps;
          Chiika.requestAnimeUpdate(anime.anime.series_animedb_id,-1,newProgress,-1)


  render: () ->
    (<div id="animeDetails"><div className="" id="animeTitle">
            <div className="backButtonDiv" onClick={this.history.goBack}>
                <i className="centerMe fa fa-angle-left fa-2x" id="backButton"></i>
            </div>
            <div className="titleDiv">
              <h2 className="centerMe noSpace" id="animeName">{@anime.anime.series_title}</h2>
            </div>
            <div className="airingStatsuDiv">
                <span className="label label-primary" id="airingStatus"></span>
            </div>

        </div>
        <div className="vCenter" id="animeGenre">
                <h4 className="vCenter">
                {@getGenres().map((tab, i) =>
                  <span key={i} className="label label-default animeGenreChip">{tab.genre}</span>)}
                </h4>
        </div>
        <div className="row" id="detailsRow">
            <div className="coverImage">
                <div className="cIm"><img id="coverImg" onClick={@openMalLink} src="./../assets/images/topLeftLogo.png" /></div>
            </div>
            <div className="cardColumn" id="col1">
                <div className="detailCard cardInfo card-twoLine" id="typeCard">
                    <h5 className="noSpace">Type</h5>
                    <h4 className="noSpace" id="cardInfo">{@getType()}</h4>
                </div>
                <div className="detailCard cardInfo card-twoLine" id="sourceCard">
                    <h5 className="noSpace">Source</h5>
                    <h4 className="noSpace" id="cardInfo">{@getSource()}</h4>
                </div>
                <div className="detailCard cardInfo card-twoLine" id="card3">
                    <h5 className="noSpace">Duration</h5>
                    <h4 className="noSpace" id="cardInfo">{@getDuration()}</h4>
                </div>
                <div className="detailCard cardInfo card-twoLine" id="card4">
                    <h5 className="noSpace">Studio</h5>
                    <h4 className="noSpace" id="cardInfo">{@getStudio()}</h4>
                </div>
            </div>
            <div className="cardColumn" id="col2">
                <div className="detailCard" id="scoreCard">
                    <div id="malScore">
                        <h5 className="noSpace">SCORE</h5>
                        <h4 className="noSpace">{@getScore()}</h4>
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
                        <h4 className="noSpace">{@getEpisodeCount()}</h4>
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
                              <h4 className="noSpace">{@getStatus()}</h4>
                              <span className="caret"></span>
                          </button>
                          <ul className="dropdown-menu statusDd">
                              {
                                @statusTextMap.map((status,i) =>
                                  <li key={i}>
                                    <div onClick={@updateStatus} data-status={status.status}>{status.text}</div>
                                  </li>
                              )}
                          </ul>
                        </div>
                    </div>
                </div>
                <div id="seasonId" className='detailCard card-season'>
                    <h3 className="noSpace seasonInfo">{@getSeason()}</h3>
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
                          <b>English:</b> {@anime.anime.series_english}
                      </p>

                      <p>
                          <b>Synonyms:</b> {@anime.anime.series_synonyms}
                      </p>
                      <p>
                          <b>Japanese:</b> {@anime.Misc.japanese}
                      </p>
                  </div>
                  <div className="synopsisColumn">
                      <h3>synopsis</h3>
                      <p id="synopsisText">Loading...</p>
                  </div>
                </div>
                <div className="characterColumn">
                    <h3>characters</h3>
                        {
                          @getCharacters().map((ch,i) =>
                            <div key={i} className="characterRow">
                              <span className="characterInfo">
                                  <h4>{ch.character_name}</h4>
                                  <h5>{ch.character_va}</h5>
                              </span>
                              <span className="characterImage">
                                  <img src={ch.character_image_link} onClick={@openCharacterPage} data-ch-id={ch.character_id} width="50px"/>
                              </span>
                            </div>
                        )}
                </div>
            </div>
        </div>
        </div>)

module.exports = AnimeDetails
