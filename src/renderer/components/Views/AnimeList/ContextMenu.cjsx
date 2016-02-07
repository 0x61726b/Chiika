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
  activeMap:[

  ]
  onSelect: (gridName) ->
    @currentGrid = gridName
    console.log @currentGrid
  getIfActive: (col) ->
    res = $.grep @activeMap, (e) -> e.key == col
    ret = false
    if res[0] == undefined
      ret = false
    else
      ret = res[0].value
    ret
  constructor: (mixin,gridName,activeMap)->
    @currentGrid = gridName
    @activeMap = activeMap

    $.contextMenu({
                  selector: '.w2ui-head',
                  items: {
                    typeWithIcon: {
                      name:"Type Icon"
                      type:"checkbox"
                      selected:@getIfActive 'typeWithIcon'
                      events:{
                        click: (e) =>
                          if e.currentTarget.checked == true
                            mixin.addTypeWithIconColumn()
                            mixin.refresh()
                          else
                            mixin.removeColumn 'typeWithIcon'
                      }
                    }
                    typeWithText: {
                      name:"Type with Text"
                      type:"checkbox"
                      selected:@getIfActive 'typeWithText'
                      events:{
                        click: (e) =>
                          if e.currentTarget.checked == true
                            mixin.addTypeWithTextColumn()
                            mixin.refresh()
                          else
                            mixin.removeColumn 'typeWithText'
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
