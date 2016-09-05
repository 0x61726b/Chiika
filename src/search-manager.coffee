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
_forEach                    = require 'lodash.foreach'

module.exports = class SearchManager
  emitter: null
  constructor: ->
    @emitter = new Emitter

  on: (message,callback) ->
    @emitter.on message,callback

  off: (message) ->
    @emitter.off message

  getLastResults: ->
    if @lastSearchString?
      return { searchString: @lastSearchString, results: @lastSearchResults }
    else
      return null


  postInit: ->
    $("#gridSearch").on 'input', (e) =>
      value = e.target.value

      @emitter.emit 'form-input', value

    $("#gridSearch").bind 'keypress', (e) =>
      if e.keyCode == 13
        value = $("#gridSearch").val()
        if value.length > 0
          sources = ""

          _forEach chiika.services, (service) =>
            sources += "#{x}," for x in service.views
          sources = sources.substring(0,sources.length - 1)



          window.location = "#Search/#{value}?searchMode=list-remote&searchType=anime-manga&searchSource=#{sources}"
        @emitter.emit 'form-input-enter',$("#gridSearch").val()

  searchAndGo: (searchString,mode,type,source,callback) ->
    console.log source
    window.location = "#Search/#{searchString}?searchMode=#{mode}&searchType=#{type}&searchSource=#{source}"
    $("#gridSearch").val(searchString)

  search: (searchString,mode,type,source,callback) ->
    if source.split(',').length > 1
      source = source.split(',')

    console.log source
    # chiika.ipc.sendMessage 'make-search', { searchString:searchString,searchType:type,searchSource:source,searchMode: mode }
    #
    # chiika.ipc.receive 'make-search-response', (event,args) =>
    #   callback?(args)
    #
    #   chiika.ipc.disposeListeners('make-search-response')
    #
    #   @lastSearchString = searchString
    #   @lastSearchResults = args
