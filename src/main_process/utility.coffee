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

_                   = require 'lodash'
path                = require 'path'
fs                  = require 'fs'
mkdirp              = require 'mkdirp'
ncp                 = require 'ncp'


module.exports = class Utility

  #
  # Checks if a file exist given an absolute path
  # @param {String} absolutePath An absolute path of a file
  # @return {Boolean}
  fileExists: (absolutePath) ->
    #Initialize settings file
    try
      file = fs.statSync absolutePath
    catch e
      file = undefined
    if _.isUndefined file
      return false
    else
      return true

  #
  # Checks if a file exist given a relative path to the app home
  # @param {String} path A path relative to the appHome
  # @example fileExistsSmart('Config/Config.json')
  # @return {Boolean}
  fileExistsSmart: (relativePath) ->
    @fileExists path.join chiika.getAppHome(),relativePath



  #
  # Reads file sync given an absolute path
  # @param {String} absolutePath An absolute path of a file
  # @return {String} contents of the file
  readFileSync: (absolutePath) ->
    fs.readFileSync absolutePath, 'utf-8'

  #
  # Checks if a file exist given a relative path to the app home
  # @param {String} path A path relative to the appHome
  # @example readFileSmart('Config/Config.json')
  # @return {String} contents of the file
  readFileSmart: (relativePath) ->
    @readFileSync path.join(chiika.getAppHome(),relativePath)

  #
  # Opens a file for writing sync
  # @param {String} absolutePath An absolute path of a file
  # @example readFileSmart('Config/Config.json')
  # @return
  openFileWSync: (absolutePath) ->
    fs.openSync absolutePath, 'w'

  #
  # Closes a file
  # @param {String} absolutePath An absolute path of a file
  # @example readFileSmart('Config/Config.json')
  # @return
  closeFileSync: (fd) ->
    fs.closeSync fd

  #
  # Opens a file for writing sync
  # @param {String} path A path relative to the appHome
  # @example openFileWSmart('Config/Config.json')
  # @return
  openFileWSmart: (relativePath) ->
    @openFileWSync path.join(chiika.getAppHome(),relativePath)

  #
  # Writes to a file sync
  # @param {String} absolutePath An absolute path of a file
  # @param {String} write What to write
  # @return
  writeFileSync: (absolutePath,write) ->
    fs.writeFileSync absolutePath,write,'utf-8'

  #
  # Opens a file for writing sync
  # @param {String} A path relative to the appHome
  # @param {String} write What to write
  # @example writeFileSmart('Config/Config.json')
  # @return
  writeFileSmart: (relativePath,write) ->
    @writeFileSync path.join(chiika.getAppHome(),relativePath),write

  #
  # Creates an empty folder
  # @param {String} absolutePath An absolute path of folder
  # @return
  createFolder: (absolutePath) ->
    new Promise (resolve) =>
      mkdirp absolutePath, ->
        resolve()

  #
  # Creates an empty folder
  # @param {String} A path relative to the appHome
  # @return
  createFolderSmart: (relativePath) ->
    @createFolder path.join(chiika.getAppHome(),relativePath)


  copyFileToDestination: (fileAbsolute,destinationAbsolute) ->
    fs.createReadStream(fileAbsolute)
      .pipe(fs.createWriteStream(destinationAbsolute))


  copyDirectoryToDestination: (dirAbsolute,destinationAbsolute) ->
    ncp dirAbsolute,destinationAbsolute, (err) =>
      if err
        chiika.logger.error "Error copying directory! #{err}"
        throw err
