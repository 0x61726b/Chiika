#//----------------------------------------------------------------------------
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

XmlParser = require("xml2js")
_ = require 'lodash'
S = require 'string'
module.exports = class Parser
  parseXml: (data) ->
    new Promise (resolve) ->
      XmlParser.parseString data, { explicitArray: false }, (err,result) ->
        if result
          resolve result
