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

request                       = require 'request'
_assign                       = require 'lodash.assign'
{RequestErrorException}       = require './exceptions'

module.exports = class RequestManager
  constructor: ->
    @defaultHeaders = {
      'User-Agent': 'ChiikaDesktopApplication',
      'Content-Type' : 'application/x-www-form-urlencoded'
    }
  makeGetRequest: (url,headers,callback) ->

    if headers?
      _assign headers, @defaultHeaders

    onRequestReturn = (error,response,body) ->
      if error
        chiika.logger.warn("Request has failed with status code: #{response.statusCode}")
      else
        if response?
          if response.statusCode != 200
            chiika.logger.warn("Request returned successful but the status code is #{response.statusCode}")
          else
            chiika.logger.info("Request complete! Return code: #{response.statusCode}")
        else
          chiika.logger.error("Somehow response is null. WTF ?")
          chiika.logger.error(body)

      callback(error,response,body)

    chiika.logger.verbose("GET request on #{url}")
    request { url: url, headers: headers },onRequestReturn


  makePostRequest: (url,headers,callback) ->

    if headers?
      _assign headers, @defaultHeaders

    onRequestReturn = (error,response,body) ->
      if error
        chiika.logger.warn("Request has failed with status code: #{response.statusCode}")
      else
        if response?
          if response.statusCode != 200
            chiika.logger.warn("Request returned successful but the status code is #{response.statusCode}")
          else
            chiika.logger.info("Request complete! Return code: #{response.statusCode}")
        else
          chiika.logger.error("Somehow response is null. WTF ?")
          chiika.logger.error(body)

      callback(error,response,body)

    chiika.logger.verbose("POST request on #{url}")
    request.post { url: url, headers: headers },onRequestReturn



  makeGetRequestAuth: (url,user,headers,callback) ->
    form = { username: user.userName, password: user.password }
    auth = { user: user.userName, password: user.password }

    if headers?
      _assign headers, @defaultHeaders


    chiika.logger.info("Creating a GET request to URL #{url}")
    onRequestReturn = (error,response,body) ->
      if error
        chiika.logger.warn("Request has failed with status code: #{response.statusCode}")
      else
        if response?
          if response.statusCode != 200
            chiika.logger.warn("Request returned successful but the status code is #{response.statusCode}")
          else
            chiika.logger.info("Request complete! Return code: #{response.statusCode}")
        else
          chiika.logger.error("Somehow response is null. WTF ?")
          chiika.logger.error(body)

      callback(error,response,body)

    request { url: url, form: form, headers:headers, auth: auth }, onRequestReturn



  makePostRequestAuth: (url,user,headers,body,callback) ->
    form = { username: user.userName, password: user.password }
    auth = { user: user.userName, password: user.password }

    defaultHeaders = {
      'User-Agent': 'ChiikaDesktopApplication',
      'Content-Type' : 'application/x-www-form-urlencoded'
    }

    if body?
      contentLength = Buffer.byteLength(body)
      _assign form, { data: body }


    if headers?
      _assign headers, defaultHeaders
    else
      headers = defaultHeaders

    onRequestReturn = (error,response,body) ->
      if error
        chiika.logger.warn("Request has failed with status code: #{response.statusCode}")
      else
        if response?
          if response.statusCode != 200
            chiika.logger.warn("Request returned successful but the status code is #{response.statusCode}")
          else
            chiika.logger.info("Request complete! Return code: #{response.statusCode}")
        else
          chiika.logger.error("Somehow response is null. WTF ?")
          chiika.logger.error(body)
      callback(error,response,body)
    chiika.logger.info("Creating a POSTAUTH request to URL #{url}")
    chiika.logger.verbose("Creating a POSTAUTH request to URL #{url} - #{user.userName} - #{user.password} - Content length #{contentLength}")

    request.post { url: url, form: form, headers:headers, auth: auth }, onRequestReturn
