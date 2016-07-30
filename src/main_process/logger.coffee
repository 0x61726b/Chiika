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

moment = require 'moment'
winston = require 'winston'
stringjs = require 'string'

module.exports = class Logger
  logger: null
  constructor: (loglevel) ->
    transport = new (winston.transports.Console)({ level: loglevel,
    colorize: true,
    timestamp: ->  return Date.now(),
    formatter: (options) => @format(options)
    })
    @logger = new (winston.Logger)({
      transports: [transport],
      levels: {
        error: 0,
        warn: 1,
        info: 2,
        verbose: 3,
        script: 2,
        renderer: 2,
        debug: 4,
        silly: 5
      }
    })
    winston.addColors( {
      error: 'red',
      warn: 'yellow',
      info: 'green',
      verbose: 'cyan',
      script: 'cyan',
      renderer: 'cyan',
      debug: 'blue',
      silly: 'magenta'
      })


  #Formats the log string
  # @param options {Object} Options object passed by winston.
  format: (options) ->
    string = moment().format('DD/MM HH:mm:ss') + ' '+  winston.config.colorize(options.level) + ' '

    regex = /\[(red|green|blue|yellow|cyan|magenta|)\]\((.*?)\)/g
    appendToStr = ''
    fullMatch = ''
    while chMatch = regex.exec options.message
      fullMatch = chMatch[0]
      color = chMatch[1]
      text = chMatch[2]

      colorObj = {}
      colorObj[text] = color
      winston.addColors( colorObj )
      appendToStr += winston.config.colorize(text)
    string += appendToStr

    if fullMatch != ''
      msg = options.message
      msg = stringjs(msg).replace(fullMatch,'').s
      string += msg
    else
      string += options.message







    # if options.meta && Object.keys(options.meta).length
    #   string += '\n\t\t\t' + JSON.stringify(options.meta)
    # else
    #   string += ''
    return string
