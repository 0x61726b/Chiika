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
#Date: 24.1.2016
#authors: arkenthera
#Description:
#----------------------------------------------------------------------------
React = require 'react'

test = {
    name   : 'gridPlantoWatchList',
    columns: [
        { field: 'title', caption: 'Title', size: '30%' },
        { field: 'progress', caption: 'Progress', size: '30%' },
        { field: 'Score', caption: 'Score', size: '40%',
        render: (record) ->
          '<div class="progress">
  <div class="progress-bar" role="progressbar" aria-valuenow="100"
  aria-valuemin="0" aria-valuemax="100" style="width:100%">
    '+record.Score*10+'%
  </div>
</div>' },
        { field: 'Season', caption: 'Season', size: '120px' },
    ],
    records: [
        { recid: 1, title: 'Senjougahara', progress: 'Hitagi', Score: '10', Season: '4/3/2012' },
    ],
    onDestroy: ->
      console.log "destroy"
    onRefresh: ->
      console.log "refresh"
}
test.records.push({ recid: 1, title: 'Senjougahara', progress: 'Hitagi', Score: '10', Season: '4/3/2012' }) for i in [0..150] by 1


#Plan to Watch List
class PlantoWatchList extends React.Component
  componentDidMount: ->
    $ ->
      $("#gridPlantoWatchList").w2grid(test)
  componentWillUnmount: ->
    $('#gridPlantoWatchList').w2destroy();
  render: () ->
    (<div id="gridPlantoWatchList" className="listCommon"></div>);

module.exports = PlantoWatchList
