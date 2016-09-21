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
LoadingScreen                       = require './loading-screen'
Loading                             = require './loading'
{dialog}                            = require('electron').remote


module.exports = class CardViews
  colors: [
    "red",
    "purple",
    "indigo",
    "orange",
    "grey"
  ]

  openListItemUrl: (e) ->
    e.preventDefault()
    link = $(e.target).parent().attr("href")
    chiika.openShellUrl(link)

  openButtonUrl: (e) ->
    link = $(e.target).attr('href')
    if !link?
      link = $(e.target).parent().attr('href')
    chiika.openShellUrl(link)


  navigateButtonUrl: (e) ->
    link = $(e.target).attr('href')
    if !link?
      link = $(e.target).parent().attr('href')

    window.location = link

  cntWatchingCardClick: (e) ->
    clicked = $(e.target).parent().parent()

    removed = false
    if @lastToggle? && @lastToggle.hasClass('expanded')
      @lastToggle.removeClass 'expanded'
      removed = true

    if !removed or @lastToggle.attr('id') != clicked.attr('id')
      clicked.toggleClass 'expanded'

    @lastToggle = clicked






  #
  # @param {Object} card
  # @option card {Object} title
  # @option card {Object} value
  #
  miniCard: (card,i) ->
    <div className="sticker purple" key={i}>
      <div className="title">
        { card.title }
      </div>
      <div className="text">
        { card.content }
      </div>
    </div>

  #
  # @param {Object} card
  # @option card {Object} items
  # @option items {Object} title
  # @option items {Object} content
  # @example
  # card = { items: [ { type: 'text', title: '', content:'' }]}
  # card = { items: [ { type: 'miniCard', card: {} }]}
  # @return
  cardWithItems: (card) ->
    <div className="card">
    {
      card.items.map (item,i) =>
        if item.type == 'text'
          <div className="detailsPage-card-item">
            <div className="title">
              <h2>{ item.title }</h2>
            </div>
            <div className="content">
              { item.content }
            </div>
          </div>
        else if item.type == 'miniCard'
          <div className="detailsPage-card-item">
            @miniCard(item.card)
          </div>
    }
    </div>

  cardList: (card,i) ->
    <div className="card grid indigo #{if card.state == 0 then 'blur'}" id="card-news" key={i}>
      <div className="home-inline title">
        <h1>{ card.properties.cardTitle }</h1>
        <button type="button" href={card.properties.redirect} onClick={@openButtonUrl} className="button indigo raised" id="btn-play">View more on {card.properties.redirectTitle}</button>
      </div>
      <ul className="yui-list news divider">
      {
        card.items.map (item,i) =>
          <li key={i}>
            <a href="#{item.link}" onClick={@openListItemUrl} alt={item[card.properties.alt]}>
              {
                if card.properties.displayCategory
                  <span className="label raised #{@colors[i % 5]}">
                    { item.category }
                  </span>
              }
              { item[card.properties.display] }
            </a>
          </li>
      }
      </ul>
    </div>


  cardListUpcoming: (card,i) =>
    <div className="card grid pink" id="card-soon" key={i}>
      <div className="home-inline title">
        <h1>Soon™</h1>
        <button type="button" className="button raised pink" name="button">Calendar <i className="ion-android-calendar"></i></button>
      </div>
      <ul className="yui-list divider">
        {
          card.items.map (item,i) =>
            <li key={i}><span className="label #{item.color}">{ item.time }<p className="detail">{ item.day }</p></span> { item.title} </li>
        }
      </ul>
    </div>


  cardAnime: (card,i) ->
    <div className="card grid currently-watching" id="card-cw" key={i}>
        <div className="title">
          <div className="home-inline">
            <h1>{card.title}</h1>
            <button type="button" onClick={@navigateButtonUrl} href="##{card.properties.viewName}_details/#{card.anime.id}" className="button raised red">Details</button>
          </div>
          <span id="watching-genre">
            <ul>
              {
                if card.anime.genres?
                  card.anime.genres.split(',').map (genre,i) =>
                    <li key={i}>{genre}</li>
              }
            </ul>
          </span>
        </div>
        <div className="currently-watching-info">
          <div className="watching-cover">
            <img src={card.anime.cover} width="150" height="225" alt="" />
            <button type="button" className="button raised lightblue">Share</button>
          </div>
          <div className="watching-info">
            <span className="info-miniCards">
              {
                if card.anime.miniCards? && card.anime.miniCards.length != 0
                  card.anime.miniCards.map (card,i) =>
                    chiika.cardManager.renderCard(card,i)
              }
            </span>
            <p>
              {card.anime.synopsis}
            </p>
          </div>
        </div>
    	</div>


  cardStatistics: (card,i) ->
    <div className="card grid teal" id="card-thisWeek" key={i}>
      <div className="grid-sizer"></div>
        <div className="home-inline title">
          <h1>This week</h1>
          <button type="button" onClick={@navigateButtonUrl} href="#History" className="teal raised button" name="button">History</button>
        </div>
        <ul className="yui-list floated divider">
          {
            card.statistics.map (item,i) =>
              <li key={i}>{item.title} <span className="label raised green">{ item.count }</span></li>
          }
        </ul>
    </div>


  cardNotRecognized: (card,i) ->
    <div className="card grid continue-watching" id="card-cnw" key={i}>
      <div className="title home-inline">
        <h1>{ card.items.title }</h1>
        <button type="button" onClick={@navigateButtonUrl} href="#myanimelist_animelist" className="button raised lightblue" name="button">Anime List <i className="ion-ios-list"></i></button>
      </div>
      <div className="recent-images">
      {
          card.items.values.map (item,i) =>
            <div className="card image-card" id="cnt-#{item.id}" onClick={@cntWatchingCardClick} key={i}>
              <div className="watch-img">
                <img src="#{item.image}" width="120" height="180" alt="" />
                <a>{ item.title}</a>
              </div>
            </div>
      }
      </div>
    </div>

  cardContinueWatching: (card,i) ->
    <div className="card grid continue-watching" id="card-cnw" key={i}>
      <div className="title home-inline">
        <h1>Continue Watching</h1>
        <button type="button" onClick={@navigateButtonUrl} href="#myanimelist_animelist" className="button raised lightblue" name="button">Anime List <i className="ion-ios-list"></i></button>
      </div>
      <div className="recent-images">
      {
          card.items.map (item,i) =>
            <div className="card image-card" id="cnt-#{item.id}" onClick={@cntWatchingCardClick} key={i}>
              <div className="watch-img">
                <img src="#{item.layout.image}" width="120" height="180" alt="" />
                <a>{ item.layout.title}</a>
              </div>
              <div className="watch-info">
                <p>{ item.layout.title }</p>
                <span className="label indigo">Episode { item.layout.watchedEpisodes} out of { item.layout.totalEpisodes}</span>
                <span>
                  <span className="label red">{ item.layout.typeText}</span>
                  <span className="label teal">{ item.layout.averageScore }</span>
                  <span className="label orange">{ item.layout.totalEpisodes } EPS</span>
                </span>
                <button type="button" onClick={@navigateButtonUrl} href="#myanimelist_animelist_details/#{item.id}" className="button raised indigo" name="button">Details</button>
                <button type="button" className="button raised teal" onClick={() => @handleNextEpisode(card,item)} name="button">Play Next Episode</button>
                <button type="button" className="button raised green" onClick={() => @handleOpenFolder(card,item)} name="button">Open Folder</button>
              </div>
            </div>
      }
      </div>
    </div>
