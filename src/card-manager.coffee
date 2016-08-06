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
CardViews                           = require './cards'

module.exports = class CardManager
  cards: []


  constructor: ->
    @views = new CardViews()

  #
  # All cards must have a unique name
  #
  addCard: (card) ->
    find = _.find @cards, (o) -> o.name == card.name
    index = _.indexOf @cards,find
    if find?
      @cards.splice(index,1,find)
    else
      @cards.push card


  getCard: (name) ->
    find = _.find @cards, (o) -> o.name == name
    if find?
      find
    else
      null

  renderCard: (card,i) ->
    if card.type == 'miniCard'
      @views.miniCard(card,i)
