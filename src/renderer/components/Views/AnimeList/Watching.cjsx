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
cn = require './../../../ChiikaNode'

test = {
    name   : 'gridWatchingList',
    reorderColumns:true,
    columns: [
        { field: 'title', caption: 'Title', size: '30%',resizable: true, sortable: true  },
        { field: 'progress', caption: 'Progress', size: '30%',resizable: true, sortable: true  },
        { field: 'Score', caption: 'Score', size: '40%',resizable: true, sortable: true ,
        render: (record) ->
          '<div class="progress">
  <div class="progress-bar" role="progressbar" aria-valuenow="70"
  aria-valuemin="0" aria-valuemax="100" style="width:70%">
    '+record.Score*10+'%
  </div>
</div>' },
        { field: 'Season', caption: 'Season', size: '120px',resizable: true, sortable: true  },
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

Helpers = require('./../../Helpers')
#Watching List
WatchingList = React.createClass
  componentDidMount: ->
    $ ->
       $("#gridWatchingList").w2grid(test)

    @buildData()
  componentWillUnmount: ->
    $('#gridWatchingList').w2destroy();

  buildData: ->
    wholeList = cn.getMyAnimelist()
    # for value in wholeList['AnimeArray']
    #   console.log value


  render: () ->
    (<div id="gridWatchingList" className="listCommon"></div>);

module.exports = WatchingList
