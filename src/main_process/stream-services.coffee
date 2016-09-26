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


stringjs                = require 'string'
_forEach                = require 'lodash/collection/forEach'

#
# Adapted from erengy/Taiga https://github.com/erengy/taiga
# Huge thanks to him for his wonderful work.
#
module.exports = class StreamServices
  streamServices:[
    { name: 'AnimeLab', identifiers: ['animelab.com/player/'] },
    { name: 'ANN', identifiers: [ /animenewsnetwork.com\/video\/[0-9]+/i ] },
    { name: 'Crunchyroll', identifiers: [ /crunchyroll\.[a-z.]+\/[^\/]+\/.*-movie-[0-9]+/i, /crunchyroll\.[a-z.]+\/[^\/]+\/episode-[0-9]+.*-[0-9]+/i ] },
    { name: 'Daisuki', identifiers: [ /daisuki\.net\/[a-z]+\/[a-z]+\/anime\/watch/i ] },
    { name: 'Plex', identifiers: [ /(?:(?:localhost|\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}):32400|plex.tv)\/web\//i] },
    { name: 'Veoh', identifiers: [ /veoh.com\/watch\//i] },
    { name: 'Viz', identifiers: [ /viz.com\/anime\/streaming\/[^\/]+-episode-[0-9]+\//i,/viz.com\/anime\/streaming\/[^\/]+-movie\//i] },
    { name: 'Wakanim', identifiers: [ /wakanim\.tv\/video(-premium)?\/[^\/]+\//i] },
    { name: 'Youtube', identifiers: [ /youtube.com\/watch/i ]}
  ]
  getStreamServiceFromUrl: (url) ->
    streamService = undefined
    _forEach @streamServices, (v,k) =>
      _forEach v.identifiers, (vi,ki) =>
        match = url.match vi
        if match?
          streamService = v
    streamService
  cleanStreamServiceTitle: (ss,title) ->
    if ss.name == 'AnimeLab'
      title = stringjs(title).chompLeft('AnimeLab - ').s
    if ss.name == 'ANN'
      title = stringjs(title).chompRight(' - Anime News Network').replace(' (d)','').replace(' (s)','').s
    if ss.name == 'Crunchyroll'
      title = stringjs(title).chompLeft('Crunchyroll - Watch ').s
      title = stringjs(title).chompRight(' - Movie - Movie').s
    if ss.name == 'Daisuki'
      title = stringjs(title).chompRight(' - DAISUKI').s
      pos = title.lastIndexOf ' - '

      if pos != -1
        title = title.substring( pos + 3 ) + " - " + title.substring(1,pos)
    if ss.name == 'Plex'
      title = stringjs(title).chompLeft('Plex').s
      title = stringjs(title).chompLeft('\u25B6 ').replace(' \u00B7 ','').s
    if ss.name == 'Veoh'
      title = stringjs(title).chompLeft('Watch Videos Online | ').chompRight(' | Veoh.com').s
    if ss.name == 'Viz'
      title = stringjs(title).chompLeft('VIZ.com - NEON ALLEY - ').s
    if ss.name == 'Wakanim'
      title = stringjs(title).chompRight(' - Wakanim.TV').chompRight(' / Streaming').replace(' de ',' ').replace(' en VOSTFR',' VOSTFR').s
    if ss.name == 'Youtube'
      title = stringjs(title).chompLeft('\u25B6 ').chompRight(' - YouTube').s
    title
