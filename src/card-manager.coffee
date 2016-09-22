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

_find                               = require 'lodash/collection/find'
_indexOf                            = require 'lodash/array/indexOf'
_forEach                            = require 'lodash/collection/forEach'
CardViews                           = require './cards'

module.exports = class CardManager
  cards: []
  maxCardListItem: 6


  constructor: ->
    @views = new CardViews()

  renderCard: (card,i) ->
    if card.type == 'miniCard'
      @views.miniCard(card,i)
