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
    @state.items = []
    dataSource = @state.data.dataSource.items

    if @state.data.dataSource.items? && dataSource.length > 0

      for i in [0...5]
        @state.items.push dataSource[i]

    if @state.items.length > 0
      @state.state = 1


  onExternalUrl: (e,url) ->
    e.preventDefault()
    chiika.openShellUrl(url)

  render: ->
    <div className="card grid indigo #{if @state.state == 0 then 'blur'}" id="card-news">
      <div className="home-inline title">
        <h1>{ @state.properties.cardTitle }</h1>
        <button type="button" onClick={(e) => @onExternalUrl(e,@state.properties.redirect)} className="button indigo raised" id="btn-play">View more on {@state.properties.redirectTitle}</button>
      </div>
      <ul className="yui-list news divider">
      {
        @state.items.map (item,i) =>
          <li key={i}>
            <a href="#{item.link}" onClick={(e) => @onExternalUrl(e,item.link)} alt={item[@state.properties.alt]}>
              {
                if @state.properties.displayCategory
                  <span className="label raised">
                    { item.category }
                  </span>
              }
              <span dangerouslySetInnerHTML={{__html: item[@state.properties.display] }} />
            </a>
          </li>
      }
      </ul>
    </div>
