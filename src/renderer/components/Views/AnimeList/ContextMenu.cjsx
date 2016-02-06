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
#Date: 6.2.2016
#authors: arkenthera
#Description:
#----------------------------------------------------------------------------
class ContextMenu
  currentGrid:""
  onSelect: (gridName) ->
    @currentGrid = gridName
    console.log @currentGrid
  constructor: (gridName)->
    @currentGrid = gridName
    $.contextMenu({
                  selector: '.w2ui-head',
                  items: {
                    typeWithIcon: {
                      name:"Type Icon"
                      type:"checkbox"
                      selected:true
                      events:{
                        click: (e) =>
                          if e.currentTarget.checked == true
                            w2ui[@currentGrid].showColumn 'typeWithIcon'
                          else
                            w2ui[@currentGrid].hideColumn 'typeWithIcon'
                      }
                    }
                    typeWithText: {
                      name:"Type with Text"
                      type:"checkbox"
                      events:{
                        click: (e) =>
                          if e.currentTarget.checked == true
                            w2ui[@currentGrid].showColumn 'typeWithText'
                          else
                            w2ui[@currentGrid].hideColumn 'typeWithText'
                      }
                    },
                    typeIconsColors: {
                      name:"Type Icon + Airing Status"
                      type:"checkbox"
                      events: {
                        click: (e) =>
                          if e.currentTarget.checked == true
                            w2ui[@currentGrid].showColumn 'typeWithIconColors'
                          else
                            w2ui[@currentGrid].hideColumn 'typeWithIconColors'
                      }
                    },
                    separator1: { type: "cm_seperator" }
                    airingStatus: {
                      name:"Airing Status"
                      type:"checkbox"
                      events: {
                        click: (e) =>
                          if e.currentTarget.checked == true
                            w2ui[@currentGrid].showColumn 'airingStatusText'
                          else
                            w2ui[@currentGrid].hideColumn 'airingStatusText'
                      }
                    }
                  }
              })


module.exports = ContextMenu
