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


RunEventHandlers = () ->
    $(".chiikaLogo").hover ->
      RotateLogo()

    $("div.navigation ul li").click ->
      $("div.navigation ul li").removeClass "active"
      $(this).toggleClass "active"

    $("a.userArea").click ->
      $("div.navigation ul li").removeClass "active"

RotateLogo = () ->
   $(".chiikaLogo").toggleClass "rotateLogo"

module.exports =
  EventHandlers: RunEventHandlers
  RotateLogo: RotateLogo
