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

window.sortFunctions = {}
###########
#
# TYPE ICON
#
###########
eXcell_typeWithIcon = (cell)->
  if cell
    @cell = cell
    @grid = @cell.parentNode.grid

  @edit = ->
    #
  @isDisabled = ->
    return true
  @setValue = (val) ->
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
