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
    (<div className="loading-small">
      <div>
        <svg version="1.1" id="Layer_1" x="0px" y="0px" width="512px" height="512px" viewBox="0 0 512 512" enableBackground="new 0 0 512 512">
          <path fillRule="evenodd" clipRule="evenodd" fill="#EEEEEE" d="M0,0v512h512V0H0z M355.139,280.353
        	c-11.02,3.582-25.281,3.927-39.57,2.407c12.687,7.187,24.247,15.92,31.141,25.412c20.7,28.5,23.278,62.693,15.251,68.527
        	c-6.886,5.005-23.1-1.003-27.572-2.813c0.37,5.22,0.974,21.733-5.66,26.554c-7.914,5.752-39.385-7.364-60.04-35.803
        	c-5.63-7.752-9.84-18.296-12.809-29.664c-2.946,11.886-7.236,22.951-13.078,30.995c-20.7,28.5-52.412,41.519-60.438,35.686
        	c-6.886-5.005-6.184-22.287-5.845-27.101c-4.85,1.964-20.361,7.642-26.995,2.82c-7.915-5.752-5.169-39.746,15.485-68.185
        	c7.138-9.829,19.247-18.875,32.405-26.239c-14.618,1.695-29.264,1.456-40.52-2.203c-33.493-10.886-55.67-37.033-52.604-46.472
        	c2.63-8.098,19.279-12.771,23.959-13.936c-3.366-4.006-13.558-17.01-11.024-24.811c3.023-9.307,36.19-17.2,69.611-6.338
        	c9.087,2.954,18.664,8.986,27.726,16.412c-4.25-10.836-7.012-21.717-7.012-31.205c0-35.228,18.006-64.407,27.927-64.407
        	c8.512,0,18.099,14.395,20.653,18.488c2.769-4.441,11.982-18.155,20.182-18.155c9.782,0,27.536,29.116,27.536,64.268
        	c0,9.553-2.773,20.522-7.029,31.432c9.354-7.866,19.308-14.278,28.746-17.346c33.493-10.886,66.798-2.772,69.864,6.667
        	c2.63,8.098-8.093,21.667-11.195,25.362c5.077,1.262,20.962,5.79,23.496,13.59C410.754,243.603,388.559,269.49,355.139,280.353z"/>
        </svg>
      </div>
    </div>)
