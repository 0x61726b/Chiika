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
React = require 'react'

class Home extends React.Component
  utility:null
  constructor: (props) ->
    super props

  onLoading: =>

  render: () ->
    (<div className="container">
      <div className="row">
          <div className="col-sm-6 col-md-4 col-md-offset-4">
              <h1 className="text-center login-title">MyAnimeList Login</h1>
                <div className="account-wall">
                    <img className="profile-img" src="https://lh5.googleusercontent.com/-b0-k99FZlyE/AAAAAAAAAAI/AAAAAAAAAAA/eu7opA4byxI/photo.jpg?sz=120" />
                    <form className="form-signin">
                    <input type="text" className="form-control" placeholder="Email" required autofocus />
                    <input type="password" className="form-control" placeholder="Password" required />
                    <button className="btn btn-lg btn-primary btn-block" type="submit">Sign in</button>
                    </form>
                </div>
          </div>
      </div>
</div>);

React = require("React");
ReactDOM = require("react-dom");

ReactDOM.render(React.createElement(Home), document.getElementById('malLogin'))
