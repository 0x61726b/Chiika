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
    @state.statistics = @state.data.dataSource

  render: ->
    <div className="card grid teal" id="card-thisWeek" key={i}>
      <div className="grid-sizer"></div>
        <div className="home-inline title">
          <h1>This week</h1>
          <button type="button" onClick={@navigateButtonUrl} href="#History" className="teal raised button" name="button">History</button>
        </div>
        <ul className="yui-list floated divider">
          {
            @state.statistics.map (item,i) =>
              <li key={i}>{item.title} <span className="label raised green">{ item.count }</span></li>
          }
        </ul>
    </div>
