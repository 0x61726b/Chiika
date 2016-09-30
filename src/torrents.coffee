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

Chart                               = require 'chart.js'
ReactList                           = require 'react-list'
Loading                             = require './loading'
_forEach                            = require 'lodash/collection/forEach'
_filter                             = require 'lodash/collection/filter'
_find                               = require 'lodash/collection/find'
#Views

module.exports = React.createClass
  getInitialState: ->
    data: []
    loading: true

  componentDidMount: ->
    deferTorrentData = =>
      @setState { data: @refreshData(), loading: false }

    setTimeout(deferTorrentData,0)

    @refreshView = chiika.emitter.on 'view-refresh', (view) =>
      if view.view == 'torrents_feeds'
        @setState { data: @refreshData(), loading: false }

  componentWillUnmount: ->
    @refreshView.dispose()

  refreshData: ->
    libraryData =  _find chiika.viewData, (o) -> o.name == 'torrents_feeds'
    if libraryData?
      libraryData = libraryData.dataSource
      libraryData
    else
      return []

  refreshTorrents: ->
    chiika.ipc.refreshViewByName('torrents_feeds','torrent',{ feedName: 'Nyaa1'})
    @setState { data: [], loading: true }

  renderSingleItem: (index,key) ->
    <div key={key}>
      <div className="list-item">
        <div className="col-list col-torrentCheck">
          <label className="checkbox danger">
            <input type="checkbox" checked={@state.data[index].filterResult.pass} onChange={@onListItemCheck} />
          </label>
        </div>
        <div className="col-list col-animeTitle">
          {
            @state.data[index].animeTitle
          }
        </div>
        <div className="col-list col-animeScore">
          {
            @state.data[index].episode
          }
        </div>
        <div className="col-list col-animeScore">
          {
            @state.data[index].group
          }
        </div>
        <div className="col-list col-animeScore">
          {
            @state.data[index].size
          }
          Mb
        </div>
        <div className="col-list col-animeScore">
          {
            @state.data[index].video
          }
        </div>
        <div className="col-list col-animeScore">
          {
            @state.data[index].desc
          }
        </div>
      </div>
    </div>
  renderHeader: () ->
    <div className="chiika-header">
      <div className="header-title col-animeTitle"><span>Title</span></div>
      <div className="header-title col-animeScore"><span>Episode</span></div>
      <div className="header-title col-animeScore"><span>Group</span></div>
      <div className="header-title col-animeScore"><span>Size</span></div>
      <div className="header-title col-animeScore"><span>Video</span></div>
      <div className="header-title col-animeScore"><span>Description</span></div>
    </div>
  render: ->
    <div>
      <button type="button" className="button raised primary" onClick={@refreshTorrents}>Refresh Torrents..</button>
      {
        if @state.loading
          <Loading />
        else
          <div>
            {
              @renderHeader()
            }
            {
              <div style={{height: '100%'}} id="chiika-torrent">
                <ReactList itemRenderer={@renderSingleItem} length={@state.data.length} type='simple' />
              </div>
            }
          </div>
      }
      <div className="fab-container active fab-right">
        <div className="fab fab-main fab-refresh" title="Refresh">
          <i className="mdi mdi-refresh"></i>
        </div>
        <div className="fab fab-main fab-download" title="Download">
          <i className="mdi mdi-download"></i>
        </div>
        <div className="fab fab-little fab-discard" title="Discard">
          <i className="mdi mdi-close"></i>
        </div>
        <p>
        If nothing is selected, only first fab will be visible,<br/>
        after selecting torrents, first fab will be download and second discard will be visible
        </p>
      </div>
    </div>
