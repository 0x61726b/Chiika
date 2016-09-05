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
{Emitter}                   = require 'event-kit'
_when                       = require 'when'


module.exports = class SearchManager
  emitter: null
  constructor: ->
    @emitter = new Emitter

  on: (message,callback) ->
    @emitter.on message,callback

  off: (message) ->
    @emitter.off message

  postInit: ->
    $("#gridSearch").on 'input', (e) =>
      value = e.target.value

      @emitter.emit 'form-input', value

    $("#gridSearch").bind 'keypress', (e) =>
      if e.keyCode == 13
        value = $("#gridSearch").val()
        if value.length > 0
          window.location = "#Search/#{value}?searchMode=list-remote&searchType=anime-manga&searchSource=myanimelist_animelist,myanimelist_mangalist"
        #@emitter.emit 'form-input-enter',$("#gridSearch").val()


  search: (searchString,mode,type,source,callback) ->
    chiika.ipc.sendMessage 'make-search', { searchString:searchString,searchType:type,searchSource:source,searchMode: mode }

    chiika.ipc.receive 'make-search-response', (event,args) =>
      callback?(args)

      chiika.ipc.disposeListeners('make-search-response')