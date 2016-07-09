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
{Emitter} = require 'event-kit'
ipcHelpers = require '../ipcHelpers'
{BrowserWindow, ipcRenderer,remote} = require 'electron'

_ = require 'lodash'
class ChiikaDomManager
  setUserInfo: (user) ->
    $("div.userInfo").html(user.userName)
  destroyGrid: (name) ->
    $("#" + name).w2destroy()
    window.chiika.gridManager.removeGrid name
  setProgress: (progress) ->
    $(".progress-bar").children().css("width",progress + "%");
  addNewGrid: (type,name,status) ->
    name = name

    if window.chiika.gridManager.checkIfGridExists name
      return

    localGrid = {
      name:name,
      reorderColumns:true,
      columns:[],
      records:[]
    }

    columns = []
    if type == 'anime'
      columns = window.chiika.gridManager.animeListColumns
    if type == 'manga'
      columns = window.chiika.gridManager.mangaListColumns

    #Sort by order
    columns = _.sortBy columns, (o) ->
      return o.order

    _.forEach columns, (v,k) ->
      findFunction = (fnc) ->
        fncMap = window.chiika.gridManager.fileFuncMap
        _.find fncMap,_.matchesProperty 'column', fnc
      if v.order != -1
        window.chiika.gridManager[findFunction(v.name).fnc](localGrid)
    data = window.chiika.getAnimeListByType(status)

    # if name == "watching"
    #   _.forEach data, (v,k) ->
    #     for i in [0...500]
    #       v.recid = i*100 + v.recid
    #       data.push v

    localGrid.records = data
    window.chiika.gridManager.addGrid localGrid
    $("#" + name).w2grid(localGrid)


module.exports = ChiikaDomManager
