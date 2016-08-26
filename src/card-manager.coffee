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
_forEach                            = require 'lodash.foreach'
CardViews                           = require './cards'

module.exports = class CardManager
  cards: []
  maxCardListItem: 6


  constructor: ->
    @views = new CardViews()

  #
  # All cards must have a unique name
  #
  addCard: (card) ->
    find = _find @cards, (o) -> o.name == card.name
    index = _indexOf @cards,find
    if find?
      @cards.splice(index,1,card)
    else
      @cards.push card


  getCard: (name) ->
    find = _find @cards, (o) -> o.name == name
    if find?
      find
    else
      null

  refreshCards: ->
    @cards = []

    if chiika.uiData.length > 0
      _forEach chiika.uiData, (uiItem) =>
        if !uiItem?
          console.log uiItem
          return
        if uiItem?
          if uiItem.type == 'card-list-item' || uiItem.type == 'card-list-item-upcoming'
            items = []
            view = _find chiika.viewData, (o) => o.name == uiItem.name
            if view?
              dataSource = view.dataSource
              if dataSource.items? && dataSource.items.length > 0
                for i in [0...@maxCardListItem]
                  items.push dataSource.items[i]
              else if dataSource.length > 0
                items = dataSource
              @addCard {
                name: uiItem.name,
                type: uiItem.type,
                properties: uiItem.cardProperties,
                title: dataSource.provider,
                items: items}
            else
              console.log "Couldnt find view with the name #{uiItem.name}"

          else if uiItem.type == 'card-full-entry'
            dataSource = uiItem.name
            view = _find chiika.viewData, (o) => o.name == dataSource

            if view?
              @addCard {
                name: uiItem.name
                type: uiItem.type
                properties: uiItem.cardProperties,
                anime: view.dataSource.layout
                title: view.dataSource.title
              }
            else
              console.log "Couldnt find view with the name #{uiItem.name}"

          else if uiItem.type == 'card-statistics'
            dataSource = uiItem.name
            view = _find chiika.viewData, (o) => o.name == dataSource

            if view?
              @addCard {
                name: uiItem.name
                type: uiItem.type
                properties: uiItem.cardProperties,
                statistics: view.dataSource
              }
            else
              console.log "Couldnt find view with the name #{uiItem.name}"

          else if uiItem.type == 'card-item-continue-watching'
            dataSource = uiItem.name
            view = _find chiika.viewData, (o) => o.name == dataSource

            if view?
              @addCard {
                name: uiItem.name
                type: uiItem.type
                properties: uiItem.cardProperties
                items: view.dataSource
                owner: view.owner
              }
            else
              console.log "Couldnt find view with the name #{uiItem.name}"

          else if uiItem.type == 'card-item-not-recognized'
            dataSource = uiItem.name
            view = _find chiika.viewData, (o) => o.name == dataSource

            if view?
              @addCard {
                name: uiItem.name
                type: uiItem.type
                properties: uiItem.cardProperties
                items: view.dataSource
                owner: view.owner
              }
            else
              console.log "Couldnt find view with the name #{uiItem.name}"

  renderCard: (card,i) ->
    if card.type == 'miniCard'
      @views.miniCard(card,i)
    else if card.type == 'card-list-item'
      @views.cardList(card,i)
    else if card.type == 'card-full-entry'
      @views.cardAnime(card,i)
    else if card.type == 'card-list-item-upcoming'
      @views.cardListUpcoming(card,i)
    else if card.type == 'card-statistics'
      @views.cardStatistics(card,i)
    else if card.type == 'card-item-continue-watching'
      @views.cardContinueWatching(card,i)
    else if card.type == 'card-item-not-recognized'
      @views.cardNotRecognized(card,i)
