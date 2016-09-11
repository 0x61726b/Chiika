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
  componentWillMount: ->
    @refreshData()

    @refreshView = chiika.emitter.on 'view-refresh', (view) ->
      if view == 'chiika_library'
        @refreshData()

  componentWillUnmount: ->
    @refreshView.dispose()

  refreshData: ->
    libraryData =  _find chiika.viewData, (o) -> o.name == 'chiika_library'
    console.log libraryData


  renderSingleItem: (item,index) ->
    <div className="day-series" key={index}>
      <div className="series-hour">
        {item.time}
      </div>
      <div className="series-episode">
        Ep. 3
      </div>
      <div className="series-title">
        {item.name} | {item.simulcast}
      </div>
      <div className="series-buttons">
        <button type="button" className="button lightblue">Details</button>
        <button type="button" className="button lightblue">Library</button>
      </div>
    </div>

  render: ->
    <div className="bookshelf" id="library">
      <div className="bookshelf-item"><img src="img/cover1.jpg" />test</div>
      <div className="bookshelf-item"><img src="img/cover1.jpg" />test123</div>
      <div className="bookshelf-item"><img src="img/cover1.jpg" /></div>
      <div className="bookshelf-item"><img src="img/cover1.jpg" /></div>
      <div className="bookshelf-item"><img src="img/cover1.jpg" /></div>
      <div className="bookshelf-item"><img src="img/cover1.jpg" /></div>
      <div className="bookshelf-item"><img src="img/cover1.jpg" /></div>
      <div className="bookshelf-item"><img src="img/cover1.jpg" /></div>
      <div className="bookshelf-item"><img src="img/cover1.jpg" /></div>
      <div className="bookshelf-item"><img src="img/cover1.jpg" /></div>
      <div className="bookshelf-item"><img src="img/cover1.jpg" /></div>
      <div className="bookshelf-item"><img src="img/cover1.jpg" /></div>
    </div>
