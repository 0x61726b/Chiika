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
    searchState: 'loading'
    searchResults: []
    searchAnime: true
    searchManga: true
    searchList : false

  setSearchParams: (searchString,searchMode,searchType,searchSource) ->
    if searchString.length > 0 && searchMode?
      console.log "Creating search request for #{searchString} - #{searchMode} - #{searchType} - #{searchSource}"

      @setState { searchString: searchString, searchMode: searchMode, searchType: searchType, searchSource: searchSource, searchState: 'searching' }

  componentDidUpdate: ->
    if @state.searchAnime && @state.searchManga
      searchType = 'anime-manga'

    if @state.searchAnime && !@state.searchManga
      searchType = 'anime'

    if @state.searchManga && !@state.searchAnime
      searchType = 'manga'

    if @state.searchList
      searchMode = "list"
    else
      searchMode = 'list-remote'


    if !@state.searchAnime && !@state.searchManga
      return

    if @state.searchState == 'searching'
      console.log "#{@state.searchString} - #{searchMode} - #{searchType} - #{@state.searchSource}"
      chiika.toastLoading("Searching #{@state.searchString}...",'infinite')

      chiika.searchManager.search @state.searchString,searchMode,searchType,@state.searchSource, (results) =>
        chiika.closeToast()
        @setState { searchResults: results, searchState: 'completed' }
    #
    # if @state.searchString.length > 0 && @state.searchMode?
    #   console.log "Creating search request for #{@state.searchString} - #{@state.searchMode} - #{@state.searchType} - #{@state.searchSource}"
    #
    #   chiika.searchManager.search @state.searchString,@state.searchType,@state.searchSource, (results) =>
    #     @setState { searchString: '', searchResults: results }

  componentDidMount: ->
    console.log "Mount #{@props.params.searchString}"

    if @props.params.searchString != ":"
      @setSearchParams(@props.params.searchString,@props.location.query.searchMode,@props.location.query.searchType,@props.location.query.searchSource)

  componentWillReceiveProps: (props) ->
    console.log props

    if props.params.searchString == ":"
      lastResults = chiika.searchManager.getLastResults()
      if lastResults?
        $("#gridSearch").val(lastResults.searchString)
        @setState { searchResults: lastResults.results, searchState: 'completed' }
    else
      @setSearchParams(props.params.searchString,props.location.query.searchMode,props.location.query.searchType,props.location.query.searchSource)
      chiika.searchManager.search value,'list','myanimelist_animelist', (results) =>
        @setState { searchResults: results, searchState: 'completed' }

  componentWillUnmount: ->
    $("#gridSearch").val('')
    chiika.ipc.disposeListeners('make-search-response')

  onTypeChange: (type,e) ->
    value = $(e.target).prop('checked')

    if type == 'anime'
      @setState { searchAnime: value, searchState: 'searching' }

    if type == 'manga'
      @setState { searchManga: value, searchState: 'searching' }




  onSourceChange: (source,e) ->
    value = $(e.target).prop('checked')
    if source == 'list'
      @setState { searchList: value, searchState: 'searching' }

  onCoverClick: (sourceView,id,title) ->
    window.location = "##{sourceView}_details/#{id}?title=#{title}"

  resultItem: (sr,i) ->
      <div className="result-cover" title="#{sr.title}" key={i}>
        <div className="result-cover-img" onClick={() => @onCoverClick(sr.sourceView,sr.id,sr.title)}>
          <img src="#{sr.image}" width="150" height="225" alt="" />
        </div>
        <div className="result-meta">
          <div className="meta">
            { sr.entryType }
          </div>
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
            <label className="checkbox">
              <input type="checkbox" name="name" checked={@state.searchAnime} onChange={ (e) => @onTypeChange('anime',e)} /> Anime
            </label>
            <label className="checkbox">
              <input type="checkbox" name="name" checked={@state.searchManga} onChange={ (e) => @onTypeChange('manga',e)} /> Manga
            </label>
          </div>
        </div>
        <div className="filter-item">
          <h1>Source</h1>
          <div className="filter-dropdown">
            <label className="checkbox">
              <input type="checkbox" name="name" value="" onChange={ () => @onSourceChange('myanimelist_animelist')} /> Myanimelist
            </label>
            <label className="checkbox">
              <input type="checkbox" name="name" checked={@state.searchList} onChange={ (e) => @onSourceChange('list',e)} /> Local List
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
        if @state.searchState == 'searching' or @state.searchState == 'loading'
          <Loading />
      }
      {
        if @state.searchState != 'searching' && @state.searchState != 'loading' && @state.searchResults.length > 0
          <div className="search-results">
          {
            @state.searchResults.map (sr,i) =>
              @resultItem(sr,i)
          }
          </div>
      }
    </div>
