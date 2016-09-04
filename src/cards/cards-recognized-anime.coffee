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

React                                     = require('react')
CardMixin                                 = require './card-view'
_find                                     = require 'lodash/collection/find'
_indexOf                                  = require 'lodash/array/indexOf'
_forEach                                  = require 'lodash.foreach'

module.exports = React.createClass
  mixins: [CardMixin]

  updateDataSource: ->
    @state.anime = @state.data.dataSource.layout
    @state.title = @state.data.dataSource.title

  render: ->
    <div className="card grid currently-watching" id="card-cw" key={i}>
        <div className="title">
          <div className="home-inline">
            <h1>{@state.title}</h1>
            <button type="button" onClick={@navigateButtonUrl} href="##{@state.properties.viewName}_details/#{@state.anime.id}" className="button raised red">Details</button>
          </div>
          <span id="watching-genre">
            <ul>
              {
                if @state.anime.genres?
                  @state.anime.genres.split(',').map (genre,i) =>
                    <li key={i}>{genre}</li>
              }
            </ul>
          </span>
        </div>
        <div className="currently-watching-info">
          <div className="watching-cover">
            <img src={@state.anime.cover} width="150" height="225" alt="" />
            <button type="button" className="button raised lightblue">Share</button>
          </div>
          <div className="watching-info">
            <span className="info-miniCards">
              {
                if @state.anime.miniCards? && @state.anime.miniCards.length != 0
                  @state.anime.miniCards.map (card,i) =>
                    chiika.cardManager.renderCard(card,i)
              }
            </span>
            <p>
              {@state.anime.synopsis}
            </p>
          </div>
        </div>
    	</div>
