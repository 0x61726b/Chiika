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
    searchResults: []
    searchAnime: false
    searchManga: false
    searchList : false
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

    if @state.searchList
      searchMode = "list"
    else
      searchMode = 'list-remote'



    if !@state.searchAnime && !@state.searchManga
      return
    #
    if @state.searchState == 'searching'
      chiika.toastLoading("Searching #{@state.searchString}...",'infinite')
    #
      chiika.searchManager.search @state.searchString,searchMode,searchType,@state.services, (results) =>
        chiika.closeToast()
        @setState { searchResults: results, searchState: 'completed' }


  componentWillMount: ->
    searchString = @props.params.searchString
    searchType = @props.location.query.searchType

    if searchString != ":"
      @state.searchState = 'searching'
      @state.searchString = searchString

      if searchType == 'default'
        @state.searchAnime = true
        @state.searchManga = true
      else if searchType == 'anime'
        @state.searchAnime = true
      else if searchType == 'manga'
        @state.searchManga = true
      else if searchType == 'list'
        @state.searchList = true


      @doSearch()


  getSearchType: (type) ->
    searchAnime = false
    searchManga = false
    searchList = false
    if type == 'default' or type == 'anime-manga'
      searchAnime = true
      searchManga = true
    else if type == 'anime'
      searchAnime = true
    else if type == 'manga'
      searchManga = true
    else if type == 'list'
      searchList = true

    return { searchAnime: searchAnime,searchManga:searchManga,searchList:searchList }





    # if @props.params.searchString != ":"
    #   @setSearchParams(@props.params.searchString,@props.location.query.searchMode,@props.location.query.searchType,@props.location.query.searchSource)

  componentWillReceiveProps: (props) ->
    # console.log props

    if props.params.searchString == ":"
      lastResults = chiika.searchManager.getLastResults()
      if lastResults?
        $("#gridSearch").val(lastResults.searchString)

        searchType = @getSearchType(lastResults.searchType)
        @setState { searchResults: lastResults.results, searchState: 'completed',searchAnime:searchType.searchAnime, searchManga: searchType.searchManga, searchList:searchType.searchList,searchSource: lastResults.searchSource }
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

  onTypeChange: (type,e) ->
    value = $(e.target).prop('checked')

    if type == 'anime'
      @setState { searchAnime: value, searchState: 'searching' }

    if type == 'manga'
      @setState { searchManga: value, searchState: 'searching' }




  onSourceChange: (source,e) ->
    value = $(e.target).prop('checked')
    source.useInSearch = value
    @setState { }


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
      <div className="detailsPage-back" onClick={this.props.history.goBack}>
        <i className="mdi mdi-arrow-left"></i>
        Back
      </div>
      <div className="search-filter">
        <label className="checkbox">
          <input type="checkbox" name="name" checked={@state.searchAnime} onChange={ (e) => @onTypeChange('anime',e)} /> Anime
        </label>
        <label className="checkbox">
          <input type="checkbox" name="name" checked={@state.searchManga} onChange={ (e) => @onTypeChange('manga',e)} /> Manga
        </label>
        {
          chiika.services.map (service,i) =>
            <label className="checkbox" key={i}>
              <input type="checkbox" name="name" checked={service.useInSearch} onChange={ (e) => @onSourceChange(service,e)} /> {service.description}
            </label>
        }
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
            if @state.searchResults.length == 0
              <div className="search-results-no-entry">
                <div>We couldnt find anything whoops..</div>
                <img src="http://i.imgur.com/wNl0LHE.jpg"></img>
              </div>
            else if @state.searchResults.length > 0
              @state.searchResults.map (sr,i) =>
                @resultItem(sr,i)
          }
          </div>
      }
    </div>
