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
  setProgress: (progress) ->
    $(".progress-bar").children().css("width",progress + "%");
  addNewGridDhtmlX: (type,name,status) ->
    dhtmlGrid = new dhtmlXGridObject(name)
    columns = []
    if type == 'anime'
      columns = chiika.gridManager.animeListColumns
    if type == 'manga'
      columns = chiika.gridManager.mangaListColumns

    columns = _.sortBy columns, (o) ->
      return o.order

    gridConf = { data: [] }
    @configureGrid columns,dhtmlGrid
    requestedListData = chiika.getAnimeListByType(status)
    _.forEach requestedListData,(v,k) ->
      obj = { }
      obj.id = v.recid
      obj.typeWithIcon = v.icon
      obj.title = v.title
      obj.score = v.score
      obj.animeProgress = v.animeProgress
      obj.season = v.season

      gridConf.data.push obj

    dhtmlGrid.init()
    dhtmlGrid.parse gridConf,"js"
    dhtmlGrid


  configureGrid: (columns,grid) ->
    columnIdsForDhtml = ""
    columnTextForDhtml = ""
    columnInitWidths = ""
    columnSorting = ""

    _.forEach columns, (v,k) ->
      if v.order != -1
        columnIdsForDhtml += v.name + ","
        columnTextForDhtml += v.desc + ","
        columnInitWidths += v.width + ","
        columnSorting += v.sort + ","

    columnIdsForDhtml = columnIdsForDhtml.substring(0,columnIdsForDhtml.length - 1)
    columnTextForDhtml = columnTextForDhtml.substring(0,columnTextForDhtml.length - 1)
    columnInitWidths = columnInitWidths.substring(0,columnInitWidths.length - 1)
    columnSorting = columnSorting.substring(0,columnSorting.length - 1)
    #To-do implement season to be in format of dd/mm/yy

    #grid.setInitWidths( columnInitWidths )
    grid.setColumnIds( columnIdsForDhtml )
    grid.setHeader(columnTextForDhtml,null,["","width: 40%;","width: 10%;","40%;","width: 120px;"])
    grid.setColTypes(columnIdsForDhtml)
    grid.setColSorting(columnSorting)
    grid.enableAutoWidth(true)
    grid.enableMultiselect(true)

  configureGridAlternate: (grid) ->
    grid.setInitWidths( "100,200,400,150" )
    grid.setColumnIds( "cImage,cInfo,cDesc,cButtons" )
    grid.setHeader("image,info,synopsis,buttons")
    grid.setColTypes("cImage,cInfo,cDesc,cButtons")
    grid.enableMultiselect(true)
    grid.setAwaitedRowHeight(150)
    grid.enableAutoHeight(false)

  addNewGrid: (type,name,status) ->
    grid = @addNewGridDhtmlX type,name,status
    grid

  addGridAlternate: (type,name,status) ->
    dhtmlGrid = new dhtmlXGridObject(name)


    gridConf = { data: [] }
    @configureGridAlternate dhtmlGrid
    requestedListData = chiika.getAnimeListByType(status)
    _.forEach requestedListData,(v,k) ->
      obj = { }
      obj.id = v.recid
      obj.cImage = {image: v.image}
      obj.cInfo = {info1: 'test',info2:'test2'}
      obj.synopsis = 'huehue'
      obj.buttons = ''

      gridConf.data.push obj

    dhtmlGrid.init()
    dhtmlGrid.parse gridConf,"js"
    dhtmlGrid


module.exports = ChiikaDomManager
