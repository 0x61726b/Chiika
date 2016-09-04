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

React                                     = require('react')
CardMixin                                 = require './card-view'
_find                                     = require 'lodash/collection/find'
_indexOf                                  = require 'lodash/array/indexOf'
_forEach                                  = require 'lodash.foreach'

module.exports = React.createClass
  mixins: [CardMixin]

  updateDataSource: ->
    @state.items = @state.data.dataSource

    console.log @state.properties

  cntWatchingCardClick: (e) ->
    clicked = $(e.target).parent().parent()

    removed = false
    if @lastToggle? && @lastToggle.hasClass('expanded')
      @lastToggle.removeClass 'expanded'
      removed = true

    if !removed or @lastToggle.attr('id') != clicked.attr('id')
      clicked.toggleClass 'expanded'

    @lastToggle = clicked

  navigateButtonUrl: (url) ->
    window.location = url

  onActionCompleteCommon: (item,args) ->
    if args.state == 'not-found'
      chiika.notificationManager.folderNotFound =>
        folders = dialog.showOpenDialog({
          properties: ['openDirectory','multiSelections']
        })

        if folders?
          chiika.scriptAction('media','set-folders-for-entry', { id: item.id,folders: folders })

  handleNextEpisode: (card,item) ->
    nextEpisode = parseInt(item.layout.watchedEpisodes) + 1
    onActionCompete = (args) ->
      console.log args
      if args.state == 'episode-not-found'
        chiika.notificationManager.episodeNotFound(item.layout.title,nextEpisode)

      if args.state == 'not-found'
        chiika.notificationManager.folderNotFound =>
          folders = dialog.showOpenDialog({
            properties: ['openDirectory','multiSelections']
          })

          if folders?
            chiika.scriptAction('media','set-folders-for-entry', { id: item.id,folders: folders })

    chiika.mediaAction 'cards','play-next-episode', { nextEpisode: parseInt(item.layout.watchedEpisodes) + 1, id: item.id }, onActionCompete

  handleOpenFolder: (card,item) ->
    chiika.mediaAction 'cards','open-folder', { id: item.id }, (args) => @onActionCompleteCommon(item,args)

  render: ->
    <div className="card grid continue-watching" id="card-cnw">
      <div className="title home-inline">
        <h1>Continue Watching</h1>
        <button type="button" onClick={() => @navigateButtonUrl("##{@state.properties.view}")} className="button raised lightblue" name="button">Anime List <i className="ion-ios-list"></i></button>
      </div>
      <div className="recent-images">
      {
          @state.items.map (item,i) =>
            <div className="card image-card" id="cnt-#{item.id}" onClick={@cntWatchingCardClick} key={i}>
              <div className="watch-img">
                <img src="#{item.layout.image}" width="120" height="180" alt="" />
                <a>{ item.layout.title}</a>
              </div>
              <div className="watch-info">
                <p>{ item.layout.title }</p>
                <span className="label indigo">Episode { item.layout.watchedEpisodes} out of { item.layout.totalEpisodes}</span>
                <span>
                  <span className="label red">{ item.layout.typeText}</span>
                  <span className="label teal">{ item.layout.averageScore }</span>
                  <span className="label orange">{ item.layout.totalEpisodes } EPS</span>
                </span>
                <button type="button" onClick={(e) => @navigateButtonUrl("#myanimelist_animelist_details/#{item.id}")} className="button raised indigo" name="button">Details</button>
                <button type="button" className="button raised teal" onClick={() => @handleNextEpisode(@state.card,item)} name="button">Play Next Episode</button>
                <button type="button" className="button raised green" onClick={() => @handleOpenFolder(@state.card,item)} name="button">Open Folder</button>
              </div>
            </div>
      }
      </div>
    </div>
