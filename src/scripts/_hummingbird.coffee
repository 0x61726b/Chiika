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

path = require 'path'
fs = require 'fs'

# How to add/update/remove key to/from the database
#
# chiika.custom addKey { name: 'hummingbirdsecret', value: { '1234sdf53fgfd'}}, callback
# chiika.custom.updateKeys { name: 'hummingbirdsecret', value: {}}, callback
# chiika.custom.removeKey [ {name: 'hummingbirdsecret'}],callback #First param must be array
#
# The above applies for adding/removing/updating a user but the object has to have the following structure
# chiika.users.addUser { userName: 'arkenthera', password:''..}

#
# Database system will be ready when this script is executed,therefore you can safely call anything related to databases.
module.exports = (chiika) ->
  urls = [
    { authUrl: 'http://hummingbird.me/api/v1/users/authenticate' }
  ]

  # onAuthComplete = (error,response,body) ->
  #   console.log body
  #
  # hmbUser = chiika.users.getUser('arkenthera')
  #
  # chiika.on 'auth', =>
  #   chiika.makePostRequestAuth( urls[0].authUrl, hmbUser,null, onAuthComplete )
