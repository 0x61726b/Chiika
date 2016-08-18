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

React = require('react')
anime = require 'animejs'

#Views

module.exports = React.createClass
  componentDidMount: () ->
    anime({
      targets: '.anime'+name,
      scale: [0.5,0.7],
      duration: 800,
      direction: 'alternate'
      easing: 'easeInQuart',
      loop: true,
      delay: (el,index) ->
        return index*200
    })

  render: () ->
    (<div className="loading-screen">
      <div>
        <img src="#{__dirname}/assets/images/logo.svg" style={{width: 72,height:72}} className="anime" alt="" />
        <img src="#{__dirname}/assets/images/logo.svg" style={{width: 72,height:72}} className="anime" alt="" />
        <img src="#{__dirname}/assets/images/logo.svg" style={{width: 72,height:72}} className="anime" alt="" />
        <img src="#{__dirname}/assets/images/logo.svg" style={{width: 72,height:72}} className="anime" alt="" />
        <img src="#{__dirname}/assets/images/logo.svg" style={{width: 72,height:72}} className="anime" alt="" />
      </div>
    </div>)
