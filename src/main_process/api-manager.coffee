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
_forEach                = require 'lodash.foreach'
_when                   = require 'when'
coffee                  = require 'coffee-script'
string                  = require 'string'
{Emitter}               = require 'event-kit'
moment                  = require 'moment'
rimraf                  = require 'rimraf'

_find                   = require 'lodash/collection/find'
_indexOf                = require 'lodash/array/indexOf'


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
    instance = _find @activeScripts, { name: name }
    if instance?
      return instance
    else
      chiika.logger.error("You are trying to access #{name} but it doesnt exist!")
      return undefined

  getScripts: ->
    @activeScripts

  initializeScript: (name) ->
    chiika.chiikaApi.emit 'initialize', { calling: name }

  postInit: () ->
    _forEach @activeScripts, (script) =>
      @initializeScript(script.name)

  postCompile: () ->
    _forEach @activeScripts, (v,k) =>
      instance = v
      index = _indexOf @activeScripts,_find @activeScripts, (o) -> o.name == v.name

      scriptName = instance.name
      scriptDesc = instance.displayDescription ? ""
      logo       = instance.logo ? ""
      loginType  = instance.loginType ? "default"
      isService  = instance.isService ? false
      isActive   = instance.isActive ? false
      order      = instance.order ? 0
      views      = instance.views ? []

      localInstance =
        name: scriptName
        description: scriptDesc
        logo: logo
        instance: instance
        loginType: loginType
        isService: isService
        isActive: isActive
        instance: instance
        order: order
        views: views

      @activeScripts.splice(index,1,localInstance)

    @activeScripts.sort (a,b) =>
      if a.isService && !b.isService
        return -1
      if b.isService && !a.isService
        return 1
      return 0

    @activeScripts.sort (a,b) =>
      if a.order > b.order
        return 1
      else
        return -1
      return 0

    if chiika.chiikaApi
      _forEach @activeScripts, (script) =>
        @initializeScript(script.name)

    if !chiika.runningTests
      @runScripts()

  runScript: (run) ->
    run()

  runScripts: () ->
    _forEach @activeScripts, (v,k) =>
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

          _forEach files, (v,k) =>
            disabled = false

            stripExtension = string(v).chompRight('.coffee').s

            if stripExtension[0] == "_"
              disabled = true

            if disabled
              processedFiles++
              return

            fileFullPath = path.join(scriptDir,v)
            fs.readFile fileFullPath,'utf-8', (err,data) =>
              jsCode = data

              if err
                resolve()
                throw err


              @compileScript jsCode,v,fileFullPath, (err,script) =>
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

                if instance?
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
  compileScript: (js,file,fileFullPath,callback) ->
    stripExtension = string(file).chompRight('.coffee').s

    scriptsConfig = chiika.settingsManager.readConfigFile('scripts')

    cachedScriptPath = path.join(@scriptsCacheDir,stripExtension + '_cache.js')

    if scriptsConfig?
      findScript = _find scriptsConfig.scripts,(o) -> o.name == file
      indexScript = _indexOf scriptsConfig.scripts,findScript

      if !chiika.utility.fileExists(cachedScriptPath)
        indexScript = -1

      # Script has been compiled before. Check its timestamp to validate that whether it has changed or not
      if indexScript != -1
        timestamp = findScript.timestamp
        lastModified = chiika.utility.getLastModifiedTime(fileFullPath)

        if moment(lastModified).isAfter(moment(timestamp))
          chiika.logger.info("#{file} has changed since last compilation. Recompiling - Last Modified #{moment(lastModified).format('DD/MM/YYYY HH:mm:ss')}")

          @internalCompile js,file, (error,scriptPath) =>
            findScript.timestamp = moment().add(10,'seconds').valueOf()
            chiika.logger.info("Saving config file scripts")
            chiika.settingsManager.saveConfigFile('scripts',scriptsConfig)
            callback(null,path.join(chiika.getScriptCachePath(),stripExtension + '_cache.js'))
        else
          chiika.logger.info("#{file} did not change since last launch.Skipping...")
          callback(null,path.join(chiika.getScriptCachePath(),stripExtension + '_cache.js'))
      else
        #Script not found. Compile
        @internalCompile js,file, (error,scriptPath) =>
          scriptsConfig.scripts.push { name: file,timestamp: moment().add(10,'seconds').valueOf()}
          chiika.logger.info("Saving config file scripts")
          chiika.settingsManager.saveConfigFile('scripts',scriptsConfig)
          callback(null,path.join(chiika.getScriptCachePath(),stripExtension + '_cache.js'))
    else
      scriptsConfig = { scripts: [] }

      @internalCompile js,file, (error,scriptPath) =>
        scriptsConfig.scripts.push { name: file, timestamp: moment().add(10,'seconds').valueOf()}
        chiika.logger.info("Saving config file scripts")
        chiika.settingsManager.saveConfigFile('scripts',scriptsConfig)
        callback(null,path.join(chiika.getScriptCachePath(),stripExtension + '_cache.js'))




  internalCompile: (js,file,callback) ->
    stripExtension = string(file).chompRight('.coffee').s
    try
      compiledString = coffee.compile js
      chiika.logger.info "[magenta](Api-Manager) Compiled " + file
    catch e
      chiika.logger.error("[magenta](Api-Manager) Error compiling user-script " + file)
      throw e

    cachedScriptPath = path.join(@scriptsCacheDir,stripExtension + '_cache.js')

    fs.writeFile cachedScriptPath,compiledString, (err) =>
      if err
        chiika.logger.error "[magenta](Api-Manager) Error occured while writing compiled script to the file."
        chiika.logger.error "#{cachedScriptPath}"
        callback(err,cachedScriptPath)
        throw err
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
