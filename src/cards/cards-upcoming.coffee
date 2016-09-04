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

  render: ->
    <div className="card grid pink" id="card-soon" key={i}>
      <div className="home-inline title">
        <h1>Soon™</h1>
        <button type="button" className="button raised pink" name="button">Calendar <i className="ion-android-calendar"></i></button>
      </div>
      <ul className="yui-list divider">
        {
          @state.items.map (item,i) =>
            <li key={i}><span className="label #{item.color}">{ item.time }<p className="detail">{ item.day }</p></span> { item.title} </li>
        }
      </ul>
    </div>
