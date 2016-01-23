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
React = require 'React'
ReactDOM = require 'react-dom'
ReactRouter = require 'react-router'
_ReactRouter = ReactRouter;
Router = _ReactRouter.Router;
Route = _ReactRouter.Route;
IndexRoute = _ReactRouter.IndexRoute;
Redirect = _ReactRouter.Redirect;
Link = _ReactRouter.Link;
IndexLink = _ReactRouter.IndexLink;

class CommonComponents
  _React = React
  _ReactDOM = ReactDOM

module.exports =
  React: React
  Router: Router
  Route: Route
  Link: Link
