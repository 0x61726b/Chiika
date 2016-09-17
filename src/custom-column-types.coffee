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
_find         = require 'lodash/collection/find'

window.sortFunctions = {}
###########
#
# TYPE ICON
#
###########
myanimelist_animelist_animeTypeText = (item) ->
  val = item.animeTypeText
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

myanimelist_animelist_animeProgress = (item,actions) ->
  <div title="#{item.animeProgress}">
    <span className="prevent-expand list-progress-minus" onClick={() =>
      actions('progress-update',{id:item.id,current: parseInt(item.animeWatchedEpisodes) - 1, total: item.animeTotalEpisodes, owner: 'myanimelist', column: 'animeWatchedEpisodes'})
      }></span>
    <span>
      <span className="prevent-expand list-progress-user">{item.animeWatchedEpisodes}</span>
      <span className="list-progress-total">/{item.animeTotalEpisodes}</span>
    </span>
    <span className="prevent-expand list-progress-plus" onClick={() =>
      actions('progress-update',{id:item.id,current: parseInt(item.animeWatchedEpisodes) + 1, total: item.animeTotalEpisodes, owner: 'myanimelist', column: 'animeWatchedEpisodes'})
      }></span>
  </div>

myanimelist_mangalist_mangaProgress = (item,actions) ->
  <div title="#{item.mangaProgress}">
    <span className="prevent-expand list-progress-minus" onClick={() =>
      actions('progress-update',{id:item.id,current: parseInt(item.mangaUserReadChapters) - 1, total: item.mangaSeriesChapters, owner: 'myanimelist', column: 'animeWatchedEpisodes'})
      }></span>
    <span>
      <span className="prevent-expand list-progress-user">{item.mangaUserReadChapters}</span>
      <span className="list-progress-total">/{item.mangaSeriesChapters}</span>
    </span>
    <span className="prevent-expand list-progress-plus" onClick={() =>
      actions('progress-update',{id:item.id,current: parseInt(item.mangaUserReadChapters) + 1, total: item.mangaSeriesChapters, owner: 'myanimelist', column: 'animeWatchedEpisodes'})
      }></span>
  </div>

hummingbird_animelist_animeProgress = (item,actions) ->
  <div title="#{item.animeProgress}">
    <span className="prevent-expand list-progress-minus" onClick={() =>
      actions('progress-update',{id:item.id,current: parseInt(item.animeWatchedEpisodes) - 1, total: item.animeTotalEpisodes, owner: 'hummingbird', column: 'animeWatchedEpisodes'})
      }></span>
    <span>
      <span className="prevent-expand list-progress-user">{item.animeWatchedEpisodes}</span>
      <span className="list-progress-total">/{item.animeTotalEpisodes}</span>
    </span>
    <span className="prevent-expand list-progress-plus" onClick={() =>
      actions('progress-update',{id:item.id,current: parseInt(item.animeWatchedEpisodes) + 1, total: item.animeTotalEpisodes, owner: 'hummingbird', column: 'animeWatchedEpisodes'})
      }></span>
  </div>

myanimelist_animelist_expanded = (item,actions) ->
  playEpisode = (e) ->
    ep = parseInt($(e.target).attr("data-ep"))
    chiika.playEpisodeByNumber(item.animeTitle,ep)

  <div className="hidden list-item-expanded">
    <div className="card">
      <img className="expanded-cover" src="#{item.animeImage}"></img>
      <div className="expanded-meta">
        <div className="meta-row">
          <h5>Rate</h5>
          <div className="expanded-rate">
            {
              [1,2,3,4,5,6,7,8,9,10].map (score,i) =>
                <span key={i} className="#{if item.animeScore == score then 'selected'}" onClick={(e) =>
                  actions('score-update',{ e: e, score: score,id: item.id, column: 'animeScore',owner: 'myanimelist'})
                  }>{score}</span>
            }
          </div>
        </div>
        <div className="meta-row">
          <h5>Watch</h5>
          <div className="expanded-watch">
            {
              for i in [1...parseInt(item.animeTotalEpisodes)+1]
                watched = false
                exists = false
                if parseInt(item.animeWatchedEpisodes) >= i
                  watched = true

                if !watched && item.animeEpisodes?
                  findInEpisodes = _find item.animeEpisodes, (o) -> parseInt(o.episode) == i

                  if findInEpisodes?
                    exists = true
                <span className="#{if watched then 'watched' else (if exists then 'aired_exists' else 'aired_not_exists')}"
                key={i}
                data-ep = i
                onClick={ (e) -> playEpisode(e) }
                >{i}</span>
            }
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

myanimelist_mangalist_expanded = (item,actions) ->
  <div className="hidden list-item-expanded">
    <div>
      <img className="expanded-cover" src="#{item.mangaImage}"></img>
      <div className="expanded-meta">
        <div className="meta-row">
          <h5>Rate</h5>
          <div className="expanded-rate">
            {
              [1,2,3,4,5,6,7,8,9,10].map (score,i) =>
                <span key={i} className="#{if item.mangaScore == score then 'selected'}" onClick={(e) =>
                  actions('score-update',{ e: e, score: score,id: item.id, column: 'mangaScore',owner: 'myanimelist'})
                  }>{score}</span>
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
            <span className="button indigo" onClick={ () => chiika.openShellUrl("https://myanimelist.net/manga/#{item.id}")}>View on Web</span>
            <span className="button red" onClick={() => window.location="#myanimelist_mangalist_details/#{item.id}"}>Open Details</span>
          </div>
        </div>
      </div>
    </div>
  </div>

hummingbird_animelist_expanded = (item,actions) ->
  <div className="hidden list-item-expanded">
    <div>
      <img className="expanded-cover" src="#{item.animeImage}" onClick={ () => chiika.openShellUrl(item.animeUrl)}></img>
      <div className="expanded-meta">
        <div className="meta-row">
          <h5>Rate</h5>
          <div className="expanded-rate">
            {
              [0.5,1,1.5,2,2.5,3,3.5,4,4.5,5].map (score,i) =>
                <span key={i} className="#{if item.animeScore == score then 'selected'}" onClick={(e) =>
                  actions('score-update',{ e: e, score: score,id: item.id, column: 'animeScore', owner: 'hummingbird'})
                  }>{score}</span>
            }
          </div>
        </div>
        <div className="meta-row">
          <textarea className="text-input" name="description" onChange={@onNotesChange} defaultValue={if item.animeNotes? then item.animeNotes else "Notes on #{item.animeTitle}"} />
          <button type="button" className="button raised primary" >Save</button>
        </div>
        <div className="meta-row">
          <h5>Watch</h5>
          <div className="expanded-watch">
            {
              for i in [1...parseInt(item.animeTotalEpisodes)+1]
                watched = false
                exists = false
                if parseInt(item.animeWatchedEpisodes) >= i
                  watched = true

                if !watched && item.animeEpisodes?
                  findInEpisodes = _find item.animeEpisodes, (o) -> parseInt(o.episode) == i

                  if findInEpisodes?
                    exists = true
                <span className="#{if watched then 'watched' else (if exists then 'aired_exists' else 'aired_not_exists')}"
                key={i}
                data-ep = i
                onClick={ (e) -> playEpisode(e) }
                >{i}</span>
            }
          </div>
        </div>
        <div className="meta-row">
          <h5>More</h5>
          <div className="expanded-more">
            <span className="button orange">Check Torrents</span>
            <span className="button indigo" onClick={ () => chiika.openShellUrl(item.animeUrl)}>View on Web</span>
            <span className="button green">Open Library</span>
            <span className="button red" onClick={() => window.location="#hummingbird_animelist_details/#{item.id}"}>Open Details</span>
          </div>
        </div>
      </div>
    </div>
  </div>

myanimelist_animelist_contextMenu = (item) ->
  totalEpisodes = parseInt(item.animeTotalEpisodes)
  currentEpisode = parseInt(item.animeWatchedEpisodes)

  statusMap = ["Watching","Completed","Plan to Watch","On Hold","Dropped"]
  statusIds = ["1","2","6","3","4"]

  onDeleteFromList = (menuItem,browserWindow,event) =>
    chiika.listManager.deleteFromList('anime',item.id,'myanimelist')

  onSearch = (menuItem,browserWindow,event) =>
    chiika.searchManager.searchAndGo(item.animeTitle,'list-remote','anime-manga')

  onOpenFolder = (menuItem,browserWindow,event) =>
    chiika.openFolderByEntry(item.animeTitle)

  onSetFolder = (menuItem,browserWindow,event) =>
    chiika.setFolderByEntry(item.animeTitle)

  playEpisodeByNumber = (episode) =>
    chiika.logger.renderer("Play episode #{episode} - #{item.animeTitle}")
    chiika.playEpisodeByNumber(item.animeTitle,episode)

  onEpisodeNumber = (menuItem,browserWindow,event) =>
    episode = menuItem.label.substring(1,menuItem.label.length)
    playEpisodeByNumber(parseInt(episode))

  onNextEpisode = (menuItem,browserWindow,event) =>
    playEpisodeByNumber(currentEpisode + 1)

  onLastEpisode = (menuItem,browserWindow,event) =>
    playEpisodeByNumber(currentEpisode - 1)

  onStatusChange = (menuItem,browserWindow,event) =>
    statusId = "-1"
    for i in [0...5]
      if statusMap[i] == menuItem.label
        statusId = statusIds[i]

    if statusId != "-1"
      chiika.listManager.updateStatus("anime",item.id,'myanimelist',
      { identifier: statusId },"myanimelist_animelist")

  menuItems = []
  menuItems.push ( { type: 'normal', label: "#{item.id}", enabled: false })
  menuItems.push ( { type: 'separator'})
  statusMap.map (status,i) =>
    checked = false
    if item.animeUserStatus == statusIds[i]
      checked = true
    menuItems.push ( { type: 'radio', label: "#{status}",checked:checked,click: onStatusChange })
  menuItems.push ( { type: 'separator'})
  menuItems.push ( { type: 'normal', label: "Delete from list", click: onDeleteFromList })
  menuItems.push ( { type: 'normal', label: "Search", click: onSearch })
  menuItems.push ( { type: 'separator'})
  menuItems.push ( { type: 'normal', label: "Open Folder", click: onOpenFolder, accelerator: 'O' })
  menuItems.push ( { type: 'normal', label: "Set Folder", click: onSetFolder })
  menuItems.push ( { type: 'separator'})
  episodes = []
  for i in [1...totalEpisodes+1]
    checked = false
    if i <= currentEpisode
      checked = true
    episodes.push ( { type: 'checkbox', label: "##{i}", checked: checked, click: onEpisodeNumber })

  menuItems.push ( { label: 'Play Episode',submenu: episodes})
  menuItems.push ( { label: "Play Next Episode ##{currentEpisode+1}",type: 'normal', click: onNextEpisode})
  menuItems.push ( { label: "Play Last Episode ##{currentEpisode-1}", type: 'normal', click: onLastEpisode})

  chiika.popupContextMenu(menuItems)

hummingbird_animelist_contextMenu = (item) ->
  onDeleteFromList = (menuItem,browserWindow,event) =>
    chiika.listManager.deleteFromList('anime',item.id,'hummingbird')

  onSearch = (menuItem,browserWindow,event) =>
    chiika.searchManager.searchAndGo(item.animeTitle,'list-remote','anime-manga')

  onOpenFolder = (menuItem,browserWindow,event) =>
    chiika.openFolderByEntry(item.animeTitle)

  onSetFolder = (menuItem,browserWindow,event) =>
    chiika.setFolderByEntry(item.animeTitle)

  playEpisodeByNumber = (episode) =>
    chiika.logger.renderer("Play episode #{episode} - #{item.animeTitle}")
    chiika.playEpisodeByNumber(item.animeTitle,episode)

  onEpisodeNumber = (menuItem,browserWindow,event) =>
    episode = menuItem.label.substring(1,menuItem.label.length)
    playEpisodeByNumber(parseInt(episode))

  onNextEpisode = (menuItem,browserWindow,event) =>
    playEpisodeByNumber(currentEpisode + 1)

  onLastEpisode = (menuItem,browserWindow,event) =>
    playEpisodeByNumber(currentEpisode - 1)

  totalEpisodes = parseInt(item.animeTotalEpisodes)
  currentEpisode = parseInt(item.animeWatchedEpisodes)

  menuItems = []
  menuItems.push ( { type: 'normal', label: "#{item.id}", enabled: false })
  menuItems.push ( { type: 'separator'})
  menuItems.push ( { type: 'normal', label: "Delete from list", click: onDeleteFromList })
  menuItems.push ( { type: 'normal', label: "Search", click: onSearch })
  menuItems.push ( { type: 'separator'})
  menuItems.push ( { type: 'normal', label: "Open Folder", click: onOpenFolder, accelerator: 'O' })
  menuItems.push ( { type: 'normal', label: "Set Folder", click: onSetFolder })
  menuItems.push ( { type: 'separator'})
  episodes = []
  for i in [0...totalEpisodes]
    checked = false
    if i <= currentEpisode
      checked = true
    episodes.push ( { type: 'checkbox', label: "##{i}", checked: checked, click: onEpisodeNumber })

  menuItems.push ( { label: 'Play Episode',submenu: episodes})
  menuItems.push ( { label: "Play Next Episode ##{currentEpisode+1}",type: 'normal', click: onNextEpisode})
  menuItems.push ( { label: "Play Last Episode ##{currentEpisode-1}", type: 'normal', click: onLastEpisode})

  chiika.popupContextMenu(menuItems)


myanimelist_animelist_library = (entry) ->
  close = (e) =>
    $(".bookshelf-book").removeClass "open"
  <div>
  {
    if entry?
      <div className="bookshelf-book">
        <div className="book-cover">
          <img src={entry.anime.animeImage} width="200" height="300" onClick={close} />
          <div className="book-meta">
            <h3>{entry.anime.animeTitle}</h3>
            <label className="checkbox">
              <input type="checkbox" name="name" value="" /> Rewatching
            </label>
            <form>
              <label>Folder</label>
              <input type="text" className="text-input" />
              <button type="button" className="button raised lightblue" id="folder-button"></button>
            </form>
            <form>
              <label>Tags</label>
              <input type="text" className="text-input" />
              <button type="button" className="button raised lightblue" id="folder-button"></button>
            </form>
          </div>
        </div>

        <div className="book-inside">
          <h5>Total Episodes: {entry.files.length}</h5>
          <ul className="book-index">
          {
            entry.files.map (file,i) =>
              <li className="book-chapter exists" data-ep={file.episode} key={i}></li>
          }
          </ul>
        </div>
        <div className="bookshelf-back"></div>
      </div>
  }
  </div>
# Uncomment next line to see how icons impact performance
window.myanimelist_animelist_animeTypeText = myanimelist_animelist_animeTypeText

# Repeat pattern of (viewName)_(columnName) = function (column_item)
# to modify contents of each cell
window.myanimelist_animelist_animeProgress = myanimelist_animelist_animeProgress
window.hummingbird_animelist_animeProgress = hummingbird_animelist_animeProgress
window.myanimelist_mangalist_mangaProgress = myanimelist_mangalist_mangaProgress

window.myanimelist_animelist_expanded = myanimelist_animelist_expanded
window.myanimelist_mangalist_expanded = myanimelist_mangalist_expanded
window.hummingbird_animelist_expanded = hummingbird_animelist_expanded

window.myanimelist_animelist_contextMenu = myanimelist_animelist_contextMenu
window.hummingbird_animelist_contextMenu = hummingbird_animelist_contextMenu

window.myanimelist_animelist_library = myanimelist_animelist_library
