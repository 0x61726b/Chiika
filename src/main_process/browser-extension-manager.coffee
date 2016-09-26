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

_forEach                = require 'lodash/collection/forEach'
_assign                 = require 'lodash.assign'
_find                   = require 'lodash/collection/find'
_remove                 = require 'lodash/array/remove'
StreamServices          = require './stream-services'
AnitomyNode             = require '../vendor/anitomy-node/AnitomyNode'


module.exports = class BrowserExtensionManager
  tabs: []
  constructor: ->
    @streamServices = new StreamServices()
    @anitomy = new AnitomyNode.Root()

  #
  #
  #
  onSocketMessage: (connection,message) ->
    origin = connection.origin
    origin = @parseOrigin(origin)
    browserMessage = @parseMessage(message)
    event = browserMessage.event

    if event == 'tab-activated' or event == 'tab-updated'
      title = browserMessage.data.title
      url = browserMessage.data.url

      # Check if the page is blank
      if title == 'New Tab'
        return

      # Check if the tab with same title/url already exists
      findInTabs = _find @tabs, (o) -> o.title == title && o.url == url

      if findInTabs?
        chiika.logger.info("The activated tab already exists.")
        return

      currentTab = { title: title, url: url }
      @tabs.push currentTab
      chiika.logger.info("Current tab for #{origin} - #{title}")

      streamService = @streamServices.getStreamServiceFromUrl(url)

      if streamService?
        #Check if there was something last activate/update
        streamTitle = @streamServices.cleanStreamServiceTitle(streamService,title)
        # Run through anitomy
        parse = @anitomy.Parse streamTitle
        @currentStreamingService = { tab: title, stream: streamService }

        chiika.emitter.emit 'md-detect',{ parse: parse,detectionSource: 'browser' }

    if event == 'tab-closed'
      title = browserMessage.data.title
      url = browserMessage.data.url

      findInTabs = _find @tabs, (o) -> o.title == title && o.url == url

      if findInTabs?
        _remove @tabs, findInTabs
        chiika.logger.info("Closed tab for #{origin} - #{title}")

        if @currentStreamingService && @currentStreamingService.tab == title
          chiika.emitter.emit 'md-close'


      # streamService = @streamServices.getStreamServiceFromUrl(url)
      #
      # if streamService?
      #   #Check if there was something last activate/update
      #   @currentTab = browserMessage.data
      #   title = @streamServices.cleanStreamServiceTitle(streamService,title)
      #   # Run through anitomy
      #   parse = @anitomy.Parse title
      #   @currentStreamingService = streamService
      #
      #   chiika.emitter.emit 'md-detect',{ parse: parse,detectionSource: 'browser' }
      # else
      #   # This tab isnt a stream service, but the tab might still be open.
      #   chiika.mediaManager.broadcastToExtension(origin,{ state: 'get-tabs' })

    #chiika.logger.info("#{origin} - #{browserMessage.event}")

  #
  #
  #
  parseMessage: (data) ->
    # Message structure
    # event/sJSONDATA e.g. tab-activated { title: 'New Tab',url: '' }
    split = data.indexOf ' '
    event = data.substring(0,split)
    jsonData = data.substring(split,data.length)
    try
      jsonData = JSON.parse(jsonData)
    catch error
      chiika.logger.error(error)

    { event: event, data: jsonData }


  parseOrigin: (origin) ->
    if origin.indexOf('chrome-extension') > -1
      return 'chrome'
    else
      return 'firefox'
