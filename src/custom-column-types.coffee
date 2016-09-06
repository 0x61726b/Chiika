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

moment                        = require 'moment'
string                        = require 'string'
React                               = require('react')

window.sortFunctions = {}
###########
#
# TYPE ICON
#
###########
myanimelist_animelist_animeTypeText = (val) ->
  if val == 'TV'
    val = 'fa fa-television'

  if val == 'OVA'
    val = 'glyphicon glyphicon-cd'

  if val == 'Movie'
    val = 'fa fa-film'

  if val == 'Special'
    val = 'fa fa-star'

  if val == 'ONA'
    val = 'fa fa-chrome'

  if val == 'Music'
    val = 'fa fa-music'

  if val == 'Normal' #Manga
    val = ''

  if val == 'Novel'
    val = ''

  if val == 'Oneshot'
    val = ''

  if val == 'Doujinshi'
    val = ''

  if val == 'Manwha'
    val = ''

  if val == 'Manhua'
    val = ''
  <i className="#{val}"></i>

myanimelist_animelist_animeProgress = (progress) ->
  <div>
    <span className="list-progress-minus"></span>
    <span>
      <span className="list-progress-user">10</span>
      <span className="list-progress-total">/20</span>
    </span>
    <span className="list-progress-plus"></span>
  </div>

myanimelist_animelist_expanded = (item) ->
  <div className="hidden list-item-expanded">
    <div>
      <img className="expanded-cover" src="#{item.animeImage}"></img>
      <div className="expanded-meta">
        <div className="meta-row">
          <h5>Rate</h5>
          <div className="expanded-rate">
            {
              [1,2,3,4,5,6,7,8,9,10].map (score,i) =>
                <span key={i} className="#{if item.animeScore == score then 'selected'}">{score}</span>
            }
          </div>
        </div>
        <div className="meta-row">
          <h5>Watch</h5>
          <div className="expanded-watch">
            <span className="watched">6</span>
            <span className="watched">7</span>
            <span className="watched">8</span>
            <span className="aired">9</span>
          </div>
        </div>
        <div className="meta-row">
          <h5>More</h5>
          <div className="expanded-more">
            <span className="button orange">Check Torrents</span>
            <span className="button indigo" onClick={ () => chiika.openShellUrl("https://myanimelist.net/anime/#{item.id}")}>View on Web</span>
            <span className="button green">Open Library</span>
            <span className="button red" onClick={() => window.location="#myanimelist_animelist_details/#{item.id}"}>Open Details</span>
          </div>
        </div>
      </div>
    </div>
  </div>

# Uncomment next line to see how icons impact performance
#window.myanimelist_animelist_animeTypeText = myanimelist_animelist_animeTypeText

# Repeat pattern of (viewName)_(columnName) = function (column_item)
# to modify contents of each cell
window.myanimelist_animelist_animeProgress = myanimelist_animelist_animeProgress
window.myanimelist_animelist_expanded = myanimelist_animelist_expanded
