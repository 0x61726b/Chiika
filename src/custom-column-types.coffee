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
    if val == 'TV'
      val = 'fa fa-television'
    @setCValue('<i class="'+val+'"></i>')
  @baka = 42
    #
window.eXcell_animeType = eXcell_typeWithIcon
window.eXcell_animeType.prototype = new eXcell

window.eXcell_mangaType = eXcell_typeWithIcon
window.eXcell_mangaType.prototype = new eXcell


###########
#
# Score
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
window.eXcell_animeScore = eXcell_score
window.eXcell_animeScore.prototype = new eXcell

window.eXcell_mangaScore = eXcell_score
window.eXcell_mangaScore.prototype = new eXcell


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

window.eXcell_mangaProgress = eXcell_animeProgress
window.eXcell_mangaProgress.prototype = new eXcell



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
window.eXcell_animeTitle = eXcell_title
window.eXcell_animeTitle.prototype = new eXcell

window.eXcell_mangaTitle = eXcell_title
window.eXcell_mangaTitle.prototype = new eXcell

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
window.eXcell_animeSeason = eXcell_season
window.eXcell_animeSeason.prototype = new eXcell

window.eXcell_mangaSeason = eXcell_season
window.eXcell_mangaSeason.prototype = new eXcell


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
