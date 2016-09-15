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
Loading                             = require './loading'
_forEach                            = require 'lodash.foreach'
_indexOf                            = require 'lodash/array/indexOf'
_find                               = require 'lodash/collection/find'


module.exports = React.createClass
  getInitialState: ->
    library: []
    selectedLibraryEntry: null

  componentWillMount: ->
    @state.library = @refreshData()

    @refreshView = chiika.emitter.on 'view-refresh', (view) =>
      if view.view == 'chiika_library'
        @setState { library: @refreshData() }

  componentWillUnmount: ->
    @refreshView.dispose()

  componentDidUpdate: ->
    $(".bookshelf-book").addClass "open"

  onLibraryEntryClick: (e,item) ->
    if $(".bookshelf-book").hasClass "open"
      # Change entry
      @setState { selectedLibraryEntry: { anime: item.entries[0].entry, files: item.files } }
    else
      @setState { selectedLibraryEntry: { anime: item.entries[0].entry, files: item.files } }


  refreshData: ->
    libraryData =  _find chiika.viewData, (o) -> o.name == 'chiika_library'
    libraryData = libraryData.dataSource

    # _forEach libraryData, (lib) =>
    #   entries = lib.entries
    #
    #   _forEach entries, (entry) =>
    #     owner = entry.owner
    #     anime = entry.entry

    libraryData

  renderSingleItem: (lib,i) ->
    <div className="bookshelf-item" key={i}>
      <img src="#{lib.entries[0].entry.animeImage}" onClick={(e) => @onLibraryEntryClick(e,lib) }></img>
      <span className="bookshelf-title">{lib.entries[0].entry.animeTitle}</span>
      <span className="service-list">
        <span className="service-label myanimelist">MAL</span>
        <span className="service-label anilist">ANI</span>
      </span>
    </div>
  render: ->
    <div className="bookshelf" id="library">
      <div>
        {
          @state.library.map (lib,i) =>
            @renderSingleItem(lib,i)
        }
        {
          window.myanimelist_animelist_library(@state.selectedLibraryEntry)
        }
      </div>
    </div>
