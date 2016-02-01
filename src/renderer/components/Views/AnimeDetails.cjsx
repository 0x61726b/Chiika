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
#(<div><div>Anime ID: {@props.params.animeId} </div><br /><br /><a href="#" onClick={this.history.goBack}>Back</a></div>);
#----------------------------------------------------------------------------
# <div style={{backgroundColor:"white"}}>
#   <div className="detailsTop">
#     <div className="detailsTitle">
#       <a href="#" className="gobackLink" onClick={this.history.goBack}><i className="fa fa-arrow-left detailsArrow"></i></a>{@props.anime.anime.series_title}
#     </div>
#     <div className="rightIcons">
#       <i className="fa fa-folder"></i>
#       <i className="fa fa-play-circle"></i>
#     </div>
#   </div>
#   <div className="detailsGenres">
#     {@props.anime.Misc.genres.map((tab, i) =>
#           <span key={i} className="label label-default">{tab.genre}</span>
#           )}
#   </div>
#   <div className="detailsMain">
#     main stuff here {@props.anime.anime.series_title} <div onClick={@requestUpdate}>Trigger me </div>
#   </div>
# </div>
React = require 'react'
h = require './../Helpers'
Router = require 'react-router'
Chiika = require './../../ChiikaNode'
History = Router.History

AnimeDetails = React.createClass
  mixins: [ History ]
  anime:null
  componentWillMount:->
    console.log @props.params.animeId
    @anime = Chiika.getAnimeById(@props.params.animeId)
    console.log @anime
  componentWillReceiveProps:(nextProps)->
    @anime = Chiika.getAnimeById(@props.params.animeId)
    console.log "Refreshed"
  requestUpdate: ->
    Chiika.testListener()
  render: () ->
    (<div>{@anime.anime.series_title}<div onClick={@requestUpdate}>Trigger me </div></div>)

module.exports = AnimeDetails
