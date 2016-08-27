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
#Views

module.exports = React.createClass
  getInitialState: ->
    searchState: 'searching'
    searchResults: []

  setSearchParams: (props) ->
    searchString = props.params.searchString
    searchMode   = props.location.query.searchMode
    searchType   = props.location.query.searchType
    searchSource   = props.location.query.searchSource

    console.log props
    if searchString.length > 0 && searchMode?
      console.log "Creating search request for #{searchString} - #{searchMode} - #{searchType} - #{searchSource}"

      @setState { searchString: searchString, searchMode: searchMode, searchType: searchType, searchSource: searchSource, searchState: 'searching' }
      chiika.searchManager.search searchString,searchMode,searchType,searchSource, (results) =>
        console.log results
        @setState { searchResults: results, searchState: 'completed' }
  componentDidUpdate: ->
    # console.log "#{@state.searchString} - #{@state.searchMode} - #{@state.searchType} - #{@state.searchSource}"
    #
    # if @state.searchString.length > 0 && @state.searchMode?
    #   console.log "Creating search request for #{@state.searchString} - #{@state.searchMode} - #{@state.searchType} - #{@state.searchSource}"
    #
    #   chiika.searchManager.search @state.searchString,@state.searchType,@state.searchSource, (results) =>
    #     @setState { searchString: '', searchResults: results }

  componentDidMount: ->
    console.log "Mount"
    @setSearchParams(@props)
  componentWillReceiveProps: (props) ->
    console.log props
    @setSearchParams(props)
    # chiika.searchManager.search value,'list','myanimelist_animelist', (results) =>
    #   @setState { searchResults: results, searchState: 'completed' }

  componentWillUnmount: ->


  onTypeChange: (type) ->
    @setState { searchType: type }

  onSourceChange: (source) ->
    @setState { searchSource: source }

  resultItem: (sr,i) ->
      <div className="result-cover" title="#{sr.title}" key={i}>
        <div className="result-cover-img">
          <img src="#{sr.image}" width="150" height="225" alt="" />
        </div>
        <div className="result-meta">
          <div className="meta">
            { sr.type }
          </div>
          <div className="meta">
            { sr.episodes }
          </div>
          <div className="meta">
            { sr.averageScore }
          </div>
          <div className="meta">
            { sr.airing }
          </div>
          <div className="meta raised indigo">
            { sr.status }
          </div>
        </div>
      </div>
  render: ->
    <div style={{height: '100%'}}>
      <div className="search-filter">
        <div className="filter-item">
          <h1>Type</h1>
          <div className="filter-dropdown">
            <label className="radio">
              <input type="radio" name="name" value="" onChange={ () => @onTypeChange('Anime')} /> Anime
            </label>
            <label className="radio">
              <input type="radio" name="name" value="" onChange={ () => @onTypeChange('Manga')} /> Manga
            </label>
          </div>
        </div>
        <div className="filter-item">
          <h1>Source</h1>
          <div className="filter-dropdown">
            <label className="checkbox">
              <input type="checkbox" name="name" value="" onChange={ () => @onSourceChange('myanimelist_animelist')} /> Myanimelist
            </label>
          </div>
        </div>
        <div className="filter-item filter-grid">
          <h1>
            GRID TYPE
          </h1>
        </div>
      </div>
      {
        if @state.searchState == 'searching'
          <Loading />
      }
      {
        if @state.searchResults.length > 0
          <div className="search-results">
          {
            @state.searchResults.map (sr,i) =>
              @resultItem(sr,i)
          }
          </div>
      }
    </div>
