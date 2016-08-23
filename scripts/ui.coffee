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


_forEach      = scriptRequire 'lodash.forEach'
moment        = scriptRequire 'moment'
string        = scriptRequire 'string'

module.exports = class UI
  name: "ui"
  displayDescription: "UI"
  isService: false
  isActive: true
  order: 1

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


  # After the constructor run() method will be called immediately after.
  # Use this method to do what you will
  #
  run: (chiika) ->
    #This is the first event called here to let user do some initializing
    @on 'initialize',=>


    @on 'post-init', (init) =>
      @chiika.logger.script("[yellow](#{@name}) post-init")
      calendarData = @chiika.viewManager.getViewByName('calendar_senpai')

      if calendarData? && calendarData.getData().length == 0
        @chiika.requestViewUpdate 'calendar_senpai',@name, (response) =>
          init.defer.resolve()
      else
        init.defer.resolve()

    # This method will be called if there are no UI elements in the database
    # or the user wants to refresh the views
    # @todo Implement reset
    @on 'reconstruct-ui', (update) =>
      @chiika.logger.script("[yellow](#{@name}) reconstruct-ui")

      calendarView =
        name: 'calendar_senpai'
        owner: @name
        displayName: ''
        displayType: 'none'
        noUpdate: true
      @chiika.viewManager.addView calendarView

    @on 'get-view-data', (args) =>
      @chiika.logger.script("[yellow](#{@name}) get-view-data")

    @on 'view-update', (update) =>
      @chiika.logger.script("[yellow](#{@name}) view-update")

      if update.view.name == 'calendar_senpai'
        calendarFile = "D:/Arken/C++/ElectronProjects/Chiika/src/assets/prettifiedSenpai.json"
        calendarData = @chiika.utility.readFileSync(calendarFile)
        seasonData = JSON.parse(calendarData)
        parsedCalendarData = { season: '2016 Sumner', senpai: seasonData }
        update.view.setData(parsedCalendarData, 'season').then (args) =>
          update.return()




  requestViewRefresh: ->
    @chiika.sendMessageToWindow 'main','refresh-data'
