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


path                    = require 'path'
fs                      = require 'fs'
_                       = require 'lodash'
_when                   = require 'when'
coffee                  = require 'coffee-script'
string                  = require 'string'
{Emitter}               = require 'event-kit'
moment                  = require 'moment'
rimraf                  = require 'rimraf'


module.exports = class APIManager
  compiledUserScripts: []
  scriptInstances: []
  scriptsDirs: []
  emitter: null
  activeScripts: []
  compiledScripts: []

  constructor: () ->
    global.api = this
    @emitter = new Emitter

    @scriptsCacheDir = path.join(chiika.getAppHome(),"cache","scripts")


    @scriptsDirs.push path.join(process.cwd(),"scripts")

  getScriptByName: (name) ->
    instance = _.find @activeScripts, { name: name }
    if !_.isUndefined instance
      return instance
    else
      chiika.logger.error("You are trying to access #{name} but it doesnt exist!")
      return undefined

  getScripts: ->
    @activeScripts

  initializeScript: (name) ->
    chiika.chiikaApi.emit 'initialize', { calling: name }

  postInit: () ->
    _.forEach @activeScripts, (script) =>
      @initializeScript(script.name)

  postCompile: () ->
    _.forEach @activeScripts, (v,k) =>
      instance = v
      index = _.indexOf @activeScripts,_.find @activeScripts, (o) -> o.name == v.name

      scriptName = instance.name
      scriptDesc = instance.displayDescription ? ""
      logo       = instance.logo ? ""
      loginType  = instance.loginType ? "default"
      isService  = instance.isService ? false
      isActive   = instance.isActive ? false

      localInstance =
        name: scriptName
        description: scriptDesc
        logo: logo
        instance: instance
        loginType: loginType
        isService: isService
        isActive: isActive
        instance: instance

      @activeScripts.splice(index,1,localInstance)

    if !chiika.runningTests
      @runScripts()

    if chiika.chiikaApi
      _.forEach @activeScripts, (script) =>
        @initializeScript(script.name)

  runScript: (run) ->
    run()

  runScripts: () ->
    _.forEach @activeScripts, (v,k) =>
      instance = v
      instance.instance.run()

  clearScripts: ->
    @activeScripts = []
    @compiledScripts = []



  # Compile everything
  # then filter out
  preCompile: ->
    new Promise (resolve) =>
      chiika.logger.info "[magenta](Api-Manager) Pre-Compiling user scripts..."

      @activeScripts = []
      processedFiles = 0

      for scriptDir in @scriptsDirs
        fs.readdir scriptDir,(err,files) =>
          fileCount = files.length

          _.forEach files, (v,k) =>
            disabled = false

            stripExtension = string(v).chompRight('.coffee').s

            if stripExtension[0] == "_"
              disabled = true

            fs.readFile path.join(scriptDir,v),'utf-8', (err,data) =>
              jsCode = data

              if err
                resolve()
                throw err

              @compileScript jsCode,v,true, (err,script) =>
                processedFiles = processedFiles + 1
                if err
                  resolve()
                  throw err

                rScript = require(script)
                try
                  instance = new rScript(chiika.chiikaApi)
                catch error
                  chiika.logger.error("There is a problem with script #{script}")

                  if processedFiles == fileCount
                    resolve()
                  return false

                isService  = instance.isService
                isActive = instance.isActive

                if isActive && !disabled
                  @activeScripts.push instance

                if !disabled
                  @compiledScripts.push instance

                if processedFiles == fileCount
                  resolve()



  #
  # Compiles javascript code
  #
  compileScript: (js,file,cache,callback) ->
    stripExtension = string(file).chompRight('.coffee').s
    try
      compiledString = coffee.compile js
      chiika.logger.info "[magenta](Api-Manager) Compiled " + file
    catch e
      chiika.logger.error("[magenta](Api-Manager) Error compiling user-script " + file)
      callback(e)
      throw e

    cachedScriptPath = path.join(@scriptsCacheDir,stripExtension + moment().valueOf() + '.chiikaJS')
    if cache
      fs.writeFile cachedScriptPath,compiledString, (err) =>
        if err
          chiika.logger.error "[magenta](Api-Manager) Error occured while writing compiled script to the file."
          chiika.logger.error "#{cachedScriptPath}"
          callback(err,cachedScriptPath)
          throw err
        chiika.logger.verbose("[magenta](Api-Manager) Cached " + file + " " + moment().format('DD/MM/YYYY HH:mm'))

        callback(null,cachedScriptPath)


  clearCache: ->
    new Promise (resolve) =>
      rimraf = require 'rimraf'
      rimraf @scriptsCacheDir,{ }, ->
        chiika.logger.info("[magenta](Api-Manager) Cleared scripts cache.")
        resolve()



  on: (message,callback) ->
    @emitter.on(message,callback)
  emit: (message,args...) ->
    @emitter.emit(message,args...)
