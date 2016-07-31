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
  emitter: null


  constructor: ->
    global.api = this
    @emitter = new Emitter

    @scriptsDir = path.join(chiika.getAppHome(),"Scripts")
    @scriptsCacheDir = path.join(chiika.getAppHome(),"Cache","Scripts")

    @watchScripts()


  #
  # Script compile event
  # @param {String} script The path of compiled script
  # @return
  onScriptCompiled: (script) ->
    rScript = require(script)
    instance = new rScript(chiika.chiikaApi)

    subs = _.where(chiika.chiikaApi.subscriptions,{ receiver: instance.name })

    for sub in subs
      sub.sub.dispose()
      _.remove(chiika.chiikaApi.subscriptions, sub)

    instance.run(chiika.chiikaApi)

    scriptName = instance.name
    scriptDesc = instance.displayDescription
    logo       = instance.logo
    loginType  = instance.loginType
    isService  = instance.isService

    localInstance = { name: scriptName, description: scriptDesc, logo: logo, instance: instance, loginType: loginType, isService: isService }

    if !_.isUndefined @getScriptByName(scriptName)
      #Script with the same name was compiled before, update it
      match = _.find(@scriptInstances,localInstance)

      index = _.indexOf @scriptInstances, _.find(@scriptInstances,localInstance)
      @scriptInstances.splice(index,1,localInstance)


      chiika.logger.info("[magenta](Api-Manager) Updating script instance #{rScript.name}")
    else
      chiika.logger.info("[magenta](Api-Manager) Adding new script instance #{rScript.name}")
      @scriptInstances.push localInstance

    @initializeScript(scriptName)


  getScriptByName: (name) ->
    instance = _.find @scriptInstances, { name: name }
    if !_.isUndefined instance
      return instance
    else
      chiika.logger.error("You are trying to access #{name} but it doesnt exist!")
      return undefined

  getScripts: ->
    @scriptInstances


  initializeScript: (name) ->
    chiika.chiikaApi.emitTo name, 'initialize'

  #
  # Compile user scripts
  # @return
  compileUserScripts: ->
    chiika.logger.info "[magenta](Api-Manager) Compiling user scripts..."
    #Look for coffee files
    @promises = []
    sanityCheck = _when.defer()
    sanityPromise = sanityCheck.promise
    @promises.push sanityPromise

    processedFileCount = 0
    scriptCount = 2


    fs.readdir @scriptsDir,(err,files) =>
      _.forEach files, (v,k) =>
        stripExtension = string(v).chompRight('.coffee').s

        if stripExtension[0] == "_"
          chiika.logger.info "[magenta](Api-Manager) Skipping disabled script " + stripExtension.substring(1,stripExtension.length)
          return
        chiika.logger.info "[magenta](Api-Manager) Compiling " + v

        defer = _when.defer()
        @promises.push defer.promise


        fs.readFile path.join(@scriptsDir,v),'utf-8', (err,data) =>
          jsCode = data

          @compileScript jsCode,v,true, =>
            defer.resolve()
            processedFileCount++

            if processedFileCount == scriptCount
              sanityCheck.resolve()
    _when.all(@promises)





  #
  # Compiles javascript code
  #
  compileScript: (js,file,cache,callback) ->
    stripExtension = string(file).chompRight('.coffee').s
    try
      compiledString = coffee.compile(js)
      chiika.logger.info "[magenta](Api-Manager) Compiled " + file
    catch
      chiika.logger.error("[magenta](Api-Manager) Error compiling user-script " + file)
      throw "Can't continue."

    cachedScriptPath = path.join(@scriptsCacheDir,stripExtension + moment().valueOf() + '.chiikaJS')
    if cache
      fs.writeFile cachedScriptPath,compiledString, (err) =>
        if err
          chiika.error "[magenta](Api-Manager) Error occured while writing compiled script to the file."
          throw err
        chiika.logger.verbose("[magenta](Api-Manager) Cached " + file + " " + moment().format('DD/MM/YYYY HH:mm'))

        @onScriptCompiled cachedScriptPath
        callback()

  #
  # Watch the changes of the scripts and recompile
  #
  watchScripts: ->
    fs.readdir @scriptsDir,(err,files) =>
      _.forEach files, (v,k) =>
        fs.watchFile path.join(@scriptsDir,v), (eventType,filename) =>
          chiika.logger.info "[magenta](Api-Manager) Recompiling..."

          #Move this to utility
          stripExtension = string(v).chompRight('.coffee').s

          fs.readFile path.join(@scriptsDir,v),'utf-8', (err,data) =>
            jsCode = data
            @compileScript(jsCode,v,true, -> )

  clearCache: ->
    rimraf = require 'rimraf'
    rimraf @scriptsCacheDir,{ }, ->
      chiika.logger.info("[magenta](Api-Manager) Cleared scripts cache.")



  on: (message,callback) ->
    @emitter.on(message,callback)
  emit: (message,args...) ->
    @emitter.emit(message,args...)
