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
#Date: 25.1.2016
#authors: arkenthera
#Description:
#----------------------------------------------------------------------------
path = require('path')
fs = require('fs')
electron = require 'electron'
ipcMain = electron.ipcMain
BrowserWindow = electron.BrowserWindow
ChiikaNode = require("./../../../chiika-node")

class Chiika
  rootOptions:{
    debugMode:true,
    appMode:true
  }
  @chiika: null
  @root:null
  @db:null
  @request:null
  @modulePath:''
  @mainWinId:-1
  @mainWindow:null
  @malLoginWindow:null
  constructor: (user,pass) ->
    @chiika = ChiikaNode
    @modulePath = path.join(path.dirname(fs.realpathSync(@chiika.path)), '../')
    @rootOptions.modulePath = @modulePath
    @rootOptions.userName = user
    @rootOptions.pass = pass
    @root = @chiika.Root(@rootOptions)
    @db = @chiika.Database()
    @request = @chiika.Request()

    @userInfo = @db.User.UserInfo
    userName = @userInfo.user_name

    console.log "Logged user " + userName


  setMainWindow: (wnd) ->
    @mainWindow = wnd

  sendAsyncMessageToRenderer:(msg,arg) ->
    @mainWindow.webContents.send msg,arg

  #Native Request JS Wrappers
  #These are Native function calls on chiika-node
  #See https://github.com/arkenthera/chiika-node/blob/master/src/RequestWrapper.cc
  #for implementations of the methods below
  #
  #Note: These functions will exit immediately.Since cURL requests run its own
  #thread, success or error callbacks will be called when the request thread finally exists.
  #Native functions and its wrappers start with capitals
  requestSuccess:(ret) =>
    @mainWindow.webContents.send 'browserPing','refreshData'
    @sendAsyncMessageToRenderer('setApiBusy',false)
  requestError:(ret) =>
    @sendAsyncMessageToRenderer('setApiBusy',false)


  verifyRequestSuccess: (ret) =>
    @malLoginWindow.send 'browserPing','close'
    @requestSuccess(ret)

    @sendAsyncMessageToRenderer('loginSuccess',true)
    #@RequestMyAnimelist()
    #@RequestMyMangalist()

  verifyRequestError: (ret) =>
    @malLoginWindow.send 'browserPing','error'
    @requestError(ret)

  RequestVerifyUser: () ->
    @request.VerifyUser(@verifyRequestSuccess,@verifyRequestError)


  RequestMyAnimelist: () =>
    @sendAsyncMessageToRenderer('setApiBusy',true)
    @request.GetMyAnimelist(@requestSuccess,@requestError)

  RequestMyMangalist: ->
    @sendAsyncMessageToRenderer('setApiBusy',true)
    @request.GetMyMangalist(@requestSuccess,@requestError)
  SetUser: (user,pass) ->
    @db.SetUser( { userName: user,password: pass} )
  #Native Database JS Wrappers
  #These synchronous functions will only load related data into v8 structures and send it back.
  #See https://github.com/arkenthera/chiika-node/blob/master/src/DatabaseWrapper.cc for more info.
  getMyAnimelist:() ->
    @db.Animelist
  getMyMangalist:() ->
    @db.Mangalist
  getUserInfo:() ->
    @db.User

chiikaNode = new Chiika

ipcMain.on 'setRootOpts',(event,arg) ->
  userName = arg.user;
  pass     = arg.pass;
  chiikaNode.malLoginWindow = event.sender

  chiikaNode.SetUser userName,pass
  chiikaNode.RequestVerifyUser()
  chiikaNode.sendAsyncMessageToRenderer('setApiBusy',true)





ipcMain.on 'rendererPing',(event,arg) ->
  console.log "Receiving IPC message from renderer process! Args: " + arg

  if arg == 'requestVerify'
    chiikaNode.RequestVerifyUser()


  if arg == 'requestMyAnimelist'
    chiikaNode.RequestMyAnimelist()
    chiikaNode.RequestMyMangalist()

  if arg == 'requestMyMangalist'
    chiikaNode.RequestMyMangalist()

  if arg == 'databaseRequest'
    al = chiikaNode.getMyAnimelist()
    ml = chiikaNode.getMyMangalist()
    ui = data = chiikaNode.getUserInfo()
    db = { animeList: al,mangaList:ml,userInfo:ui}
    event.sender.send arg,db

module.exports = chiikaNode
