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

window.eXcell_animeScoreAverage = eXcell_score
window.eXcell_animeScoreAverage.prototype = new eXcell

window.eXcell_mangaScoreAverage = eXcell_score
window.eXcell_mangaScoreAverage.prototype = new eXcell


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
    @setCValue("<div class='progress-bar thin' sort-data=#{val}>
    <div class='indigo' style=width:#{val}%; />
    </div>",val)
  @getValue = ->
    parseInt(this.cell.firstChild.getAttribute('sort-data'))
  @baka = 42
    #
# progress_customSort = (a,b,order) ->
#   if order == "asc"
#     if (b) > (a)
#       1
#     else
#       -1
#   else
#     if (a) > (b)
#       1
#     else
#       -1
#
# window.sortFunctions.progress = progress_customSort

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
