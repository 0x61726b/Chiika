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

_find                                     = require 'lodash/collection/find'
_indexOf                                  = require 'lodash/array/indexOf'
_forEach                                  = require 'lodash/collection/forEach'

module.exports =
  prepare: (props) ->
    state =
      properties: props.card.cardProperties
      card: props.card
      state: props.state

    # Find view data
    cardName          = state.card.name

    find = _find chiika.viewData, (o) -> o.name == cardName

    if !find?
      chiika.logger.error("View data for #{cardName} does not exist.")
    else
      state.data = find

    if @isMounted()
      @setState state
    else
      @state = state

  componentWillMount: ->
    @prepare(@props)
    @updateDataSource()

    chiika.emitter.on 'view-refresh', (item) =>
      if item.view == @state.card.name
        @prepare(@props)
        @updateDataSource()

  
