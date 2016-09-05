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

path          = require 'path'
fs            = require 'fs'
{remote}        = scriptRequire 'electron'

_forEach      = scriptRequire 'lodash.forEach'
moment        = scriptRequire 'moment'
string        = scriptRequire 'string'

module.exports = class CustomColumnTypes
  name: "grid-column-types"
  displayDescription: ""
  isService: false
  isActive: true
  order: 99

  # Will be called by Chiika with the API object
  # you can do whatever you want with this object
  # See the documentation for this object's methods,properties etc.
  constructor: (chiika) ->
    @chiika = chiika

  # This method is controls the communication between app and script
  # If you change this method things will break
  #
  on: (event,args...) ->
    @chiika.on @name,event,args...

  renderAnimeTypeText: (val) ->
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
    return "<i class='#{val}'></i>"


  # After the constructor run() method will be called immediately after.
  # Use this method to do what you will
  #
  run: (chiika) ->
    #This is the first event called here to let user do some initializing
    @on 'initialize',=>



    @on 'post-init', (init) =>
      init.defer.resolve()

      global['myanimelist_animelist_animeTypeText'] = @renderAnimeTypeText
