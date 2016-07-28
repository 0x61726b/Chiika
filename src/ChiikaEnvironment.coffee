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
#Date: 12.2.2016
#authors: arkenthera
#Description:
#----------------------------------------------------------------------------
{Emitter} = require 'event-kit'
path = require 'path'

module.exports =
  class ChiikaEnvironment
    constructor:(chiika,appDel,routeManager) ->
      @chiika = chiika
      @routeManager = routeManager
      @appDel = appDel

      scribe = require 'scribe-js'
      express = require 'express'

      scribe = scribe()
      console = process.console

      @emitter = new Emitter


      console.addLogger('rendererDebug','red')
      @debug("Renderer initializing...")


    onChiikaReady: (callback) ->
      @emitter.on 'chiika-is-ready',callback
    chiikaReady: ->
      @fadeIn()
      @sideMenuClick()
      @routeManager.startSearching()
      @debug("Chiika is ready.")
      @emitter.emit 'chiika-is-ready'

    setApiBusy: (c) ->
      @chiika.apiBusy = c
      @rotateLogo(c)
    debug: (text) ->
      process.console.tag("chiika-renderer").rendererDebug(text)


    getUserInfo: () ->
      @localUserInfo
    rotateLogo: (cond) ->
      if cond == true
        $(".chiikaLogo").addClass "rotateLogo"
      else
        $(".chiikaLogo").removeClass "rotateLogo"

    setStatusText: (text,fadeout) ->
      $(".statusText").show()
      $(".statusText").html(text)

      if fadeout > 0
        $(".statusText").delay(fadeout).fadeOut fadeout, ->
          $(this).html("")
    setSidebarInfo: () -> #Put user info here
      userName = @getUserInfo().UserInfo.user_name
      userName ?= "user_name"
      if userName == "user_name"
        userName = "Chiika"

      userId = @localUserInfo.UserInfo.user_id

      userId ?= "user_id"
      userImage = "../assets/images/avatar.jpg"
      if userId != "user_id"
        if @appOptions?
          userImage =path.join(@appOptions.imagePath, userId+".jpg")
      else
        userImage = "../assets/images/avatar.jpg"


      $("div.userInfo").html(userName)
      if @appOptions?
        imageUrl = userImage

        $("img#userAvatar").attr('src',imageUrl)
    setActiveMenuItem: (index) ->
      $("div.navigation ul li").removeClass "active"
      $("div.navigation ul li:nth-child(" +(index+1)+ ")").toggleClass "active"
    fadeIn: ->
      $("#app").fadeIn(250).removeClass "hidden"
    sideMenuClick: ->
      $("div.navigation ul li").click ->
        $("div.navigation ul li").removeClass "active"
        $(this).toggleClass "active"

      $("a.userArea").click ->
        $("div.navigation ul li").removeClass "active"
