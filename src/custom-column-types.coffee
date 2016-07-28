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
    @setCValue('<i class="'+val+'"></i>')
  @baka = 42
    #
window.eXcell_typeWithIcon = eXcell_typeWithIcon
window.eXcell_typeWithIcon.prototype = new eXcell


###########
#
# Anime List Progress Bar
#
###########
eXcell_animeProgress = (cell)->
  if cell
    @cell = cell
    @grid = @cell.parentNode.grid

  @edit = ->
    #
  @isDisabled = ->
    return true
  @setValue = (val) ->
    @setCValue('<div class="progress-bar thin">
    <div class="indigo" style="width:'+val+'%;" />
    </div>')
  @baka = 42
    #
window.eXcell_animeProgress = eXcell_animeProgress
window.eXcell_animeProgress.prototype = new eXcell


###########
#
# Generic title column
#
###########

eXcell_title = (cell)->
  if cell
    @cell = cell
    @grid = @cell.parentNode.grid

  @edit = ->
    #
  @isDisabled = ->
    return true
  @setValue = (val) ->
    @setCValue(val)
  @baka = 42
    #
window.eXcell_title = eXcell_title
window.eXcell_title.prototype = new eXcell

###########
#
# Generic season column
#
###########

eXcell_season = (cell)->
  if cell
    @cell = cell
    @grid = @cell.parentNode.grid

  @edit = ->
    #
  @isDisabled = ->
    return true
  @setValue = (val) ->
    @setCValue(val)
  @baka = 42
    #
window.eXcell_season = eXcell_season
window.eXcell_season.prototype = new eXcell


###########
#
# Generic score column
#
###########

eXcell_score = (cell)->
  if cell
    @cell = cell
    @grid = @cell.parentNode.grid

  @edit = ->
    #
  @isDisabled = ->
    return true
  @setValue = (val) ->
    @setCValue(val)
  @baka = 42
    #
window.eXcell_score = eXcell_score
window.eXcell_score.prototype = new eXcell

###########
#
# Alternate-anime-list image column
#
###########
eXcell_cImage = (cell)->
  if cell
    @cell = cell
    @grid = @cell.parentNode.grid

  @edit = ->
    #
  @isDisabled = ->
    return true
  @setValue = (val) ->
    @setCValue("<img src='"+ val.image + "' style='height: 100px' />")
  @baka = 42
    #
window.eXcell_cImage = eXcell_cImage
window.eXcell_cImage.prototype = new eXcell
