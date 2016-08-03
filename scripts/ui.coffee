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


_       = require process.cwd() + '/node_modules/lodash'
string  = require process.cwd() + '/node_modules/string'


module.exports = class UISetup
  name: "uiSetup"
  displayDescription: "UI Setup"
  isService: false
  isActive: true
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

  # Creates a 'view'
  # A view is something which will appear at the side menu which you can navigate to
  # See the documentation for view types
  # This is a 'tabView', the most traditional thing in this app
  #
  crateImageView: (promise) ->
    view = {
      name: 'animeList_myanimelist',
      displayName: 'Anime List',
      displayType: 'tabView',
      owner: @name,
     }
    @chiika.ui.addUIItem view,=>
      @chiika.logger.verbose "Added new view #{view.name}!"
      promise.resolve()


  createHome: (promise) ->
    view = {
      name: 'chiika_home',
      category: 'none',
      displayName: 'Home',
      displayType: 'home',
      owner: @name,
     }
    @chiika.ui.addUIItem view,=>
      @chiika.logger.script("[yellow](#{@name})  Added new view #{view.name}!")
      promise.resolve()



  # After the constructor run() method will be called immediately after.
  # Use this method to do what you will
  #
  run: (chiika) ->
    #This is the first event called here to let user do some initializing
    @on 'initialize',=>

    # This method will be called if there are no UI elements in the database
    # or the user wants to refresh the views
    # @todo Implement reset
    @on 'reconstruct-ui', (update) =>
      @chiika.logger.script("[yellow](#{@name}) reconstruct-ui")
      update.defer.resolve()

    @on 'view-update', (view) =>
