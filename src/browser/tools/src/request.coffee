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
path = require 'path'
fs = require 'fs'

class RequestAPI
  #Verify user credentials on MyAnimeList
  verifyCredentials: (args,callback) ->
    _self = this

    request.post({
      url:"http://" + args.userName + ":" + args.password + "@myanimelist.net/api/account/verify_credentials.xml"},(error,response,body) ->
        _self.onVerifyCredentials(error,response,body,callback))

  #Uses http://myanimelist.net/includes/ajax.inc.php?id=<id>&t=64 64 for anime 65 for manga
  getAnimeDetailsSmall: (animeId,callback) ->
    request 'http://myanimelist.net/includes/ajax.inc.php?id=' + animeId + '&t=64', (error,response,body) => @onGetAnimeDetailsSmall error,response,body,callback

  getAnimeDetailsMalPage: (animeId,callback) ->
    options = { headers: { 'User-Agent': 'ChiikaDesktopApplication' }, url: 'http://myanimelist.net/anime/' + animeId }
    request options, (error,response,body) => @onGetAnimeDetailsMalPage error,response,body,callback
  searchAnime: (user,q,callback) ->
    postObj = {
      url:"http://" + user.userName + ":" + user.password + "@myanimelist.net/api/anime/search.xml?q=" + q }
    request postObj.url,(error,response,body) =>
       @onSearch error,response,body,callback
  searchManga: (q,callback) ->
    request 'http://myanimelist.net/api/manga/search.xml?q=' + q, (error,response,body) -> _self.onSearch error,response,body,callback
  #Get animelist of a user
  getAnimelist:(userName,callback) ->
    _self = this
    request 'http://myanimelist.net/malappinfo.php?u=' + userName + '&type=anime&status=all', (error,response,body) -> _self.onGetList error,response,body,callback

  #Get mangalist of a user
  getMangalist:(userName,callback) ->
    _self = this
    request 'http://myanimelist.net/malappinfo.php?u=' + userName + '&type=manga&status=all', (error,response,body) -> _self.onGetList error,response,body,callback

  downloadImage: (url,fileName,ext,cb) ->
    downloadPath = path.join(application.chiikaHome,'Data','Images',fileName + '.' + ext)
    request.head url, (error,response,body) ->
      request(url).pipe(fs.createWriteStream(downloadPath)).on('close',cb)

  onGetAnimeDetailsMalPage: (error,response,body,callback) ->
    if response.statusCode == 200 & !error
      callback { success: true, animeDetails: Parser.ParseAnimeDetailsMalPage(body), statusCode: response.statusCode }


    @handleRequestResult error,response,body,callback
  onGetAnimeDetailsSmall: (error,response,body,callback) ->
    if response.statusCode == 200 & !error
      callback { success: true, animeDetails: Parser.ParseAnimeDetailsSmall(body), statusCode: response.statusCode }

    @handleRequestResult error,response,body,callback

  onSearch: (error,response,body,callback) ->
    if response.statusCode == 200 && !error
      Parser.ParseSync(body)
            .then (result) ->
              callback { success: true, anime: result.anime , statusCode: response.statusCode }
    @handleRequestResult error,response,body,callback
  #getAnimelist or getMangalist callback, also includes user info
  onGetList: (error,response,body,callback) ->
    if !error && response?
      if response.statusCode == 200
        Parser.ParseSync(body)
              .then (result) ->
                result = (result)
                callback { success: true,list: result, statusCode: response.statusCode }



    @handleRequestResult(error,response,body,callback)

  #verifycredentials callback
  onVerifyCredentials: (error,response,body,callback) ->
    if response.statusCode == 200 && !error
      Parser.ParseSync(body)
            .then (result) ->
              callback { success: true,user: result.user, statusCode: response.statusCode }


    @handleRequestResult(error,response,body,callback)

  handleRequestResult: (error,response,body,callback) ->
    if !response?
      @onError error,response,body,callback
    else if response.statusCode != 200
      @onError error,response,body,callback
    else if error
      @onError error,response,"No connection probably.",callback
  onError: (error,response,body,callback) ->
    if !response?
      callback { success:false, statusCode: -1, body: body ,errorMessage: "Something went wrong. Whoops.." + body}
    else
      callback { success:false, statusCode: response.statusCode, body: body, errorMessage: "Something went wrong. Whoops.." + body}



module.exports = new RequestAPI()
