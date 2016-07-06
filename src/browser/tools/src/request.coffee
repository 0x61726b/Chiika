##//----------------------------------------------------------------------------
#//Chiika
#//
#//This program is free software; you can redistribute it and/or modify
#//it under the terms of the GNU General Public License as published by
#//the Free Software Foundation; either version 2 of the License, or
#//(at your option) any later version.
#//This program is distributed in the hope that it will be useful,
#//but WITHOUT ANY WARRANTY; without even the implied warranty of
#//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#//GNU General Public License for more details.
#//Date: 9.6.2016
#//authors: arkenthera
#//Description:
#//----------------------------------------------------------------------------


request = require 'request';

Parser = require './parser'

class RequestAPI
  #Verify user credentials on MyAnimeList
  verifyCredentials: (args,callback) ->
    _self = this

    request.post({
      url:"http://" + args.userName + ":" + args.password + "@myanimelist.net/api/account/verify_credentials.xml"},(error,response,body) ->
        _self.onVerifyCredentials(error,response,body,callback))


  #Get animelist of a user
  getAnimelist:(userName,callback) ->
    _self = this
    request 'http://myanimelist.net/malappinfo.php?u=' + userName + '&type=anime&status=all', (error,response,body) -> _self.onGetList error,response,body,callback

  #Get mangalist of a user
  getMangalist:(userName,callback) ->
    _self = this
    request 'http://myanimelist.net/malappinfo.php?u=' + userName + '&type=manga&status=all', (error,response,body) -> _self.onGetList error,response,body,callback

  #getAnimelist or getMangalist callback, also includes user info
  onGetList: (error,response,body,callback) ->
    if response.statusCode == 200 && !error
      Parser.ParseSync(body)
            .then (result) ->
              callback { list: result, statusCode: response.statusCode }



    @handleRequestResult(error,response,body,callback)

  #verifycredentials callback
  onVerifyCredentials: (error,response,body,callback) ->
    if response.statusCode == 200 && !error
      Parser.ParseSync(body)
            .then (result) ->
              callback { success: true,user: result.user, statusCode: response.statusCode }


    @handleRequestResult(error,response,body,callback)

  handleRequestResult: (error,response,body,callback) ->
    if response.statusCode != 200
      @onError error,response,body,callback
    else if error
      @onError error,response,"No connection probably.",callback
  onError: (error,response,body,callback) ->
    callback { success:false, statusCode: response.statusCode, errorMessage: "Something went wrong. Whoops.." + body}



module.exports = new RequestAPI()
