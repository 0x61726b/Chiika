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

path = require 'path'
fs = require 'fs'

# How to add/update/remove key to/from the database
#
# chiika.custom addKey { name: 'hummingbirdsecret', value: { '1234sdf53fgfd'}}, callback
# chiika.custom.updateKeys { name: 'hummingbirdsecret', value: {}}, callback
# chiika.custom.removeKey [ {name: 'hummingbirdsecret'}],callback #First param must be array
#
# The above applies for adding/removing/updating a user but the object has to have the following structure
# chiika.users.addUser { userName: 'arkenthera', password:''..}

#
# Database system will be ready when this script is executed,therefore you can safely call anything related to databases.

urls = [
  'http://myanimelist.net/api/account/verify_credentials.xml',
  'http://myanimelist.net/malappinfo.php?u=arkenthera&type=anime&status=all',
  'http://myanimelist.net/malappinfo.php?u=arkenthera&type=manga&status=all'
]

_ = require process.cwd() + '/node_modules/lodash'

module.exports = (chiika) ->
  malUser = chiika.users.getUser('arkenthera')

  CreateAnimelistData = ->
    #Since 'animeList' is a tabView, we have to return a structure like this
    # [
    # {name: 'watching', data: [] }
    # {name: 'ptw', data: [] }
    # {name: 'dropped', data: [] }
    # {name: 'onhold', data: [] }
    # {name: 'completed', data: [] }
    # ]

    sampleData = [{ id:0 , animeType: 'TV', animeProgress: 50, animeTitle: 'Test', animeScore: 5, animeSeason: '2016-05-05'}]

    animelistData = []
    animelistData.push { name: 'watching',data: sampleData }
    animelistData.push { name: 'ptw',data: sampleData }
    animelistData.push { name: 'dropped',data: sampleData }
    animelistData.push { name: 'onhold',data: sampleData }
    animelistData.push { name: 'completed',data: sampleData }

    return animelistData

  # This method will be called if there are no UI elements in the database
  # or the user wants to refresh the views
  chiika.on 'reconstruct-ui', =>
    view = {
      name: 'animeList',
      displayName: 'Anime List',
      displayType: 'tabView',
      tabView: {
        tabList: [ 'watching','ptw','dropped','onhold','completed'],
        gridColumnList: [
          { name: 'animeType',display: 'Type', sort: 'na', width:'40' },
          { name: 'animeTitle',display: 'Title', sort: 'str', width:'150' },
          { name: 'animeProgress',display: 'Progress', sort: 'int', width:'150' },
          { name: 'animeScore',display: 'Score', sort: 'int', width:'50' },
          { name: 'animeSeason',display: 'Season', sort: 'str', width:'100' },
        ]
      }
     }
    chiika.ui.addUIItem view,=>
      chiika.logger.verbose "Added new view #{view.name}!"

  #console.log chiika.ui.getUIItem('animeList')

  # This event is called each time the associated view needs to be updated then saved to DB
  # Note that its the actual data refreshing. Meaning for example, you need to SYNC your data to the remote one, this event occurs
  # This event won't be called each application launch unless "RefreshUponLaunch" option is ticked
  # You should update your data here
  # This event will then save the data to the view's local DB to use it locally.
  chiika.on 'view-update', (view) =>
    console.log "Requesting view refresh for #{view.name}"
    view.setData(CreateAnimelistData())

  # chiika.makeGetRequestAuth urls[1],malUser,null, (error,response,body) =>
  #   chiika.parser.parseXml(body)
  #                .then (xmlObject) =>
  #                  _.assign malUser, { mal: xmlObject.myanimelist.myinfo }
  #                  chiika.users.updateUser malUser



  #This method is called for each 'view' you created via addUIItem
  #In this context, 'View' means something you can click on the side menu to navigate.
  #There are various types of views, one being 'tabView' which consists of tabs and their respective grids
  #You have to set the data of each grid in this callback using setDataSource() method
  #The data has to have a pre-defined structure to match grid.
  # chiika.on 'uiReconstruct-item',(item) =>
  #   sampleData = [{ id:0 , animeType: 'TV', animeProgress: 50, animeTitle: 'Test', animeScore: 5, animeSeason: '2016-05-05'}]
  #   if item.name == 'animeList'
  #     item.setTabData('watching', sampleData)
  #     item.setTabData('ptw', sampleData)
  #     item.setTabData('dropped', sampleData)
  #     item.setTabData('onhold', sampleData)
  #     item.setTabData('completed', sampleData)
  #
  #     item.save()





  # onAuthComplete = (error,response,body) ->
  #   if response.statusCode == 200
  #     chiika.parser.parseXml(body)
  #                  .then (xmlObject) =>
  #                    userId = xmlObject.user.id
  #                    malUser.id = userId
  #                    chiika.users.updateUser malUser
  # #This function is called once to validate a user's credentials
  # #For example, if you need a token, retrieve it here then store it by calling chiika.custom.addkey
  # chiika.on 'auth', =>
  #   chiika.makeGetRequestAuth( urls[0].authUrl, malUser,null, onAuthComplete )
