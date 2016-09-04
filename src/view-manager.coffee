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
#Views

module.exports = class ViewManager

  #
  #
  #
  saveTabGridViewState: (view) ->
    chiika.setUIViewConfig { name:view.name, config: view.displayConfig }

  optionChanged: (option,value) ->
    chiika.logger.renderer("OnOptionChanged #{option} - #{value}")
    if option == 'DisableCardNews'
      view = _find chiika.uiData, (o) -> o.name == 'cards_news'
      if view?
        chiika.emitter.emit 'ui-data-refresh', { item: view }

    if option == 'DisableCardContinueWatching'
      view = _find chiika.uiData, (o) -> o.name == 'cards_continueWatching'
      if view?
        chiika.emitter.emit 'ui-data-refresh', { item: view }

    if option == 'DisableCardUpcoming'
      view = _find chiika.uiData, (o) -> o.name == 'cards_upcoming'
      if view?
        chiika.emitter.emit 'ui-data-refresh', { item: view }


    if option == 'DisableCardStatistics'
      view = _find chiika.uiData, (o) -> o.name == 'cards_statistics'
      if view?
        chiika.emitter.emit 'ui-data-refresh', { item: view }

  #
  #
  #
  getComponent: (name) ->
    if name == 'TabGridView'
      return './view-tabgridview'
