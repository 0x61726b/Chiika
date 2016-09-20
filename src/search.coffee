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
#Views

module.exports = React.createClass
  getInitialState: ->
    searchState: 'no-input'
    searchString: @props.params.searchString
    searchType: 'default'
    searchSource: chiika.users[0].owner
    searchResults: []
    searchAnime: true
    searchManga: false
    services: chiika.services

  componentDidUpdate: ->
    if @state.searchState != 'no-input'
      @doSearch()



  doSearch: ->
    if @state.searchAnime && @state.searchManga
      searchType = 'anime-manga'

    if @state.searchAnime && !@state.searchManga
      searchType = 'anime'

    if @state.searchManga && !@state.searchAnime
      searchType = 'manga'


    if !@state.searchAnime && !@state.searchManga
      return
    #
    if @state.searchState == 'searching'
      chiika.toastLoading("Searching #{@state.searchString}...",'infinite')
    #
      chiika.searchManager.search @state.searchString,searchType,@state.searchSource, (response) =>
        chiika.closeToast()
        results = []

        if response.results?
          results = response.results
        @setState { searchResults: results, searchSuccess: response.success, searchError: response.error, searchState: 'completed' }


  componentWillMount: ->
    searchString = @props.params.searchString
    searchType = @props.location.query.searchType

    if searchString != ":"
      @state.searchState = 'searching'
      @state.searchString = searchString
      @state.searchType = searchType

      if searchType == 'default'
        @state.searchAnime = true
        @state.searchManga = false
      else if searchType == 'anime'
        @state.searchAnime = true
      else if searchType == 'manga'
        @state.searchManga = true
      else if searchType == 'picking'
        @state.searchAnime = true


      @doSearch()

      $("#gridSearch").val(searchString)


  getSearchType: (type) ->
    searchAnime = false
    searchManga = false
    if type == 'default' or type == 'anime-manga'
      searchAnime = true
      searchManga = true
    else if type == 'anime'
      searchAnime = true
    else if type == 'manga'
      searchManga = true

    return { searchAnime: searchAnime,searchManga:searchManga }





    # if @props.params.searchString != ":"
    #   @setSearchParams(@props.params.searchString,@props.location.query.searchMode,@props.location.query.searchType,@props.location.query.searchSource)

  componentWillReceiveProps: (props) ->
    # console.log props

    if props.params.searchString == ":"
      lastResults = chiika.searchManager.getLastResults()
      if lastResults?
        $("#gridSearch").val(lastResults.searchString)

        searchType = @getSearchType(lastResults.searchType)
        @setState {searchString: $("#gridSearch").val(), searchSuccess: true,searchResults: lastResults.results, searchState: 'completed',searchAnime:searchType.searchAnime, searchManga: searchType.searchManga,searchSource: lastResults.searchSource }
    # else
    #   @setSearchParams(props.params.searchString,props.location.query.searchMode,props.location.query.searchType,props.location.query.searchSource)
    #   chiika.searchManager.search value,'list','myanimelist_animelist', (results) =>
    #     @setState { searchResults: results, searchState: 'completed' }

  componentWillUnmount: ->
    $("#gridSearch").val('')
    chiika.ipc.disposeListeners('make-search-response')
    @formInputSub.dispose()

  componentDidMount: ->
    @formInputSub = chiika.searchManager.on 'form-input-enter', (input) =>
      @setState { searchString: input, searchState: 'searching' }

  onTypeChange: (e) ->
    value = $(e.target).val()

    startSearch = false

    if @state.searchString != ":"
      startSearch = true



    if value == 'Anime'
      @setState { searchAnime: true, searchManga:false, searchState: if startSearch then 'searching' else 'no-input' }

    if value == 'Manga'
      @setState { searchAnime: false, searchManga:true, searchState: if startSearch then 'searching' else 'no-input' }




  onServiceChanged: (e) ->
    value = $(e.target).val()

    if @state.searchString != ":"
      @setState { searchSource: value, searchState: 'searching' }
    else
      @setState { searchSource: value }



  onCoverClick: (sr) ->
    window.location = "##{sr.sourceView}_details/#{sr.id}?title=#{sr.title}&cover=#{sr.image}"


  pickAnime: (sr) ->


  resultItem: (sr,i) ->
    <div className="search-result" key={i} onClick={() => @onCoverClick(sr)}>
      <div className="result-cover">
        <img src="#{sr.image}" alt="" />
      </div>
      <div className="result-meta">
        <h2>{sr.title}</h2>
        <ul>
          <li className="result-medium">{sr.entryType}</li>
          <li className="result-type">{sr.type}</li>
          <li className="result-score">{sr.averageScore}</li>
          <li className="result-season">{ sr.airing }</li>
          <li>{ sr.status }</li>
        </ul>
      </div>
    </div>

  resultItemPick: (sr,i) ->
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
        <div className="meta raised indigo" onClick={() => @pickAnime(sr)}>
          Pick
        </div>
      </div>
    </div>

  renderPicking: ->
    <div style={{height: '100%'}}>
      <div className="detailsPage-back" onClick={this.props.history.goBack}>
        <i className="mdi mdi-arrow-left"></i>
        Back
      </div>
      {
        if @state.searchState == 'searching'
          <Loading />
        else if @state.searchState == 'no-input'
          <div>Type something in the input box to search!</div>
      }
      {
        if @state.searchState != 'searching' && @state.searchState != 'loading'
          <div className="search-results">
          {
            if @state.searchSuccess && @state.searchResults.length == 0
              <div className="search-results-no-entry">
                <div>Type in search box to identify the anime you are watching.</div>
                <img src="http://i.imgur.com/wNl0LHE.jpg"></img>
              </div>
            else if @state.searchResults.length > 0
              @state.searchResults.map (sr,i) =>
                @resultItemPick(sr,i)
          }
          </div>
      }
    </div>

  renderSearch: ->
    <div className="search-page">
      <div className="search-filter">
        <select className="button red" name="Type" onChange={@onTypeChange}>
          <option value="Anime">Anime</option>
          <option value="Manga">Manga</option>
        </select>
        <select className="button red" name="Type" value={@state.searchSource} onChange={(e) => @onServiceChanged(e)}>
          {
            chiika.services.map (service,i) =>
              <option value="#{service.name}" key={i}>{service.description}</option>
          }
        </select>
        <select className="button red" name="Type">
          <option value="option">Title</option>
          <option value="option">Score</option>
        </select>
      </div>
      {
        if @state.searchState == 'searching'
          <Loading />
        else if @state.searchState == 'no-input'
          <div>Type something in the input box to search!</div>
      }
      {
        if @state.searchState != 'searching' && @state.searchState != 'loading'
          <div className="search-result-list">
          {
            if @state.searchSuccess && @state.searchResults.length == 0
              <div className="search-results-no-entry">
                <div>We couldnt find anything whoops..</div>
                <img src="http://i.imgur.com/wNl0LHE.jpg"></img>
              </div>
            else if @state.searchSuccess && @state.searchResults.length > 0
              <div>
                <h1>In List</h1>
                {
                  @state.searchResults.map (sr,i) =>
                    if sr.status != "Not In List"
                      @resultItem(sr,i)
                }
                <h1>Not In List</h1>
                {
                  @state.searchResults.map (sr,i) =>
                    if sr.status == "Not In List"
                      @resultItem(sr,i)
                }
              </div>
            else if !@state.searchSuccess
              <div>
                <div>Search request has failed.</div>
                <div>{@state.searchError}</div>
              </div>
          }
          </div>
      }
    </div>
  render: ->
    if @state.searchType == 'default' or @state.searchType == 'anime-manga'
      @renderSearch()
    else
      @renderPicking()
