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

class Utility
  constructor: () ->
    @RunEverything()
  RunEverything: () ->
    @FadeInOnPageLoad()
    @SideMenuClickHandler()
    @RotateLogoOnHover()
  FadeInElement: (element) ->
    element.fadeIn(1000).removeClass "hidden"
  FadeInOnPageLoad: () ->
    $ ->
      $("#app").fadeIn(250).removeClass "hidden"

  SideMenuClickHandler: () ->
    $("div.navigation ul li").click ->
      $("div.navigation ul li").removeClass "active"
      $(this).toggleClass "active"

    $("a.userArea").click ->
      $("div.navigation ul li").removeClass "active"
  RotateLogo: () ->
    $(".chiikaLogo").toggleClass "rotateLogo"
   RotateLogoOnHover: () ->
     $(".chiikaLogo").hover =>
        @RotateLogo()


Util = new Utility()
module.exports = Util
