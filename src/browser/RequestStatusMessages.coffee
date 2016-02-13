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
#Date: 6.2.2016
#authors: arkenthera
#Description:
#
#----------------------------------------------------------------------------
class RequestKeyHelper
  requestMessageMap:{
      UserVerify:'Verifying user...',
      GetMyAnimelist:'Syncing anime list...',
      GetMyMangalist:'Syncing manga list...',
      GetImage: 'Getting user image...',
      GetMalAjax: '',
      GetAnimePageScrape: 'Getting anime info...',
      GetSearchAnime: 'Getting anime info...'
  },
  requestSuccessfulMap:{
    UserVerifySuccess:'Verifying successful.',
    GetMyAnimelistSuccess:'Synced anime list.',
    GetMyMangalistSuccess:'Synced manga list.',
    GetImageSuccess: 'Synced user profile image.',
    GetMalAjaxSuccess: 'Synced anime info.',
    GetAnimePageScrapeSuccess: 'Synced anime info.',
    FakeRequestSuccess:'Sync not required.',
    GetSearchAnimeSuccess: 'Syncing anime info.'
  },
  requestErrorMap:{
    UserVerify:'Error verifying user!',
    GetMyAnimelistError:'Error syncing anime list!',
    GetMyMangalistError:'Error syncing manga list!',
    GetImageError: 'Error downloading user image!',
    GetMalAjaxError: 'Error getting info of anime!',
    GetAnimePageScrapeError: 'Error getting info of anime!',
    GetSearchAnimeError: 'Error getting info of anime!'
  }
  getRequestMessage: (req) ->
    msg = @requestMessageMap[req]
    msg
  getRequestSuccessMessage: (req) ->
    msg = @requestSuccessfulMap[req]
    msg
  getRequestErrorMessage: (req) ->
    msg = @requstErrorMap[req]
    msg

module.exports = RequestKeyHelper
