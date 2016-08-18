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


module.exports = class CardViews
  #
  # @param {Object} card
  # @option card {Object} title
  # @option card {Object} value
  #
  miniCard: (card,i) ->
    <div className="card purple" key={i}>
      <div className="title">
        <p className="mini-card-title">{ card.title }</p>
      </div>
      <p>{ card.content }</p>
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
