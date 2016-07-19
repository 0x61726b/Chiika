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
React = require("react")
ReactDOM = require("react-dom")

path = require 'path'


module.exports = class AnimeDetailsHelper
  statusTextMap:[
    { status:1,text:"Watching" },
    { status:6,text:"Plan to Watch" },
    { status:2,text:"Completed" },
    { status:3,text:"On Hold" },
    { status:4,text:"Dropped" }
  ],
  getType: (anime) ->
    type = anime.series_type
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
    animeType
  getTypeImage: (anime) ->
    type = anime.series_type
    bgImage = ""
    if type == "1"
      bgImage = "./../assets/images/detailsCards/type/alt-tv.png"
    if type == "2"
      bgImage = "./../assets/images/detailsCards/type/alt-ova.png"
    if type == "3"
      bgImage = "./../assets/images/detailsCards/type/alt-movie.png"
    if type == "4"
      bgImage = "./../assets/images/detailsCards/type/alt-special.png"
    if type == "5"
      bgImage = "./../assets/images/detailsCards/type/alt-ona.png"
    if type == "6"
      bgImage = "./../assets/images/detailsCards/type/alt-music.png"
    bgImage
  getStatus: (anime) ->
    id = anime.my_status
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
  getSeason: (anime) ->
    startDate = anime.series_start

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
  getSeasonClass: (anime) ->
    startDate = anime.series_start

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
    "detailCard card-season " + sClass
  getSynopsis: (anime) ->
    synopsis = anime.misc_synopsis

    if !synopsis?
      return

    synopsis = synopsis.replace(/\[i\]/g,"<i>")
    synopsis = synopsis.replace(/\[\/i\]/g,'</i>')
    synopsis = synopsis.replace(/&quot;/g,"'")

    synopsis
  getSourceImage: (anime) ->
    source = anime.misc_source

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
    bgImage
  openCharacterPage: (e) ->
    id = $(e.target).attr("data-ch-id")
    url = "http://myanimelist.net/character/" + id
    shell.openExternal(url)
  checkCoverImage: (id) ->
    coverPath = path.join('Data','Images',id + '.jpg')
    if chiika.checkIfFileExists coverPath
      return path.join(chiika.chiikaHome,coverPath)
    else
      return undefined
