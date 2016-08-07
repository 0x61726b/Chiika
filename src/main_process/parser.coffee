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

  parseAnimeDetailsMalPage: (arg) ->
    #Parse MAL anime page myanimelist.net/anime/<ID>
    studiosRegex = /(Studios:<\/span>\s*).*f="\/anime\/producer\/(.*"\s)title="(.*)">/
    sourceRegex = /(Source:<\/span>\s*)(.*)\s*<\/div>/
    japaneseTranslationRegex = /(Japanese:<\/span>\s*)(.*)\s*<\/div>/
    broadcastRegex = /(Broadcast:<\/span>\s*)(.*)\s*<\/div>/
    durationRegex = /(Duration:<\/span>\s*)(.*)\s*<\/div>/
    airedRegex = /(Aired:<\/span>\s*)(.*)\s*<\/div>/
    synopsisRegex = /itemprop="description">([^]+?)(?=<\/span)/
    charactersStep1Regex = /(<div class="picSurround"><a href="\/character\/)([^]+?)(?=\/table>)/g
    charactersStep2Image = /data-src="(.*?)"\s/
    charactersAndIdsRegex = /\s<a href="\/character\/(.*)">(.*)<\/a>/
    voiceActorsAndIdsRegex = /<a href="\/people\/(.*)">(.*)<\/a><br>/g
    vaStep2Image = /\w"><img src="\/images\/spacer.gif"\sdata-src="(.*?)"\s/g

    studiosMatch = arg.match studiosRegex
    if studiosMatch?
      studioName = studiosMatch[3]
      studioIdToBeParsed = studiosMatch[2]
      parseStudioId = studioIdToBeParsed.split('/')
      studioId = parseStudioId[0]


    sourceMatch = arg.match sourceRegex
    if sourceMatch?
      source = sourceMatch[2]

    synopsisMatch = arg.match synopsisRegex
    if synopsisMatch?
      synopsis = synopsisMatch[1]


    japaneseTranslationMatch = arg.match japaneseTranslationRegex
    if japaneseTranslationMatch?
      japaneseTranslation = japaneseTranslationMatch[2]


    broadcastMatch = arg.match broadcastRegex
    if broadcastMatch?
      broadcast = broadcastMatch[2]


    durationMatch = arg.match durationRegex
    if durationMatch?
      duration = durationMatch[2]


    airedMatch = arg.match airedRegex
    if airedMatch?
      aired = airedMatch[2]



    characters = []
    while chMatch = charactersStep1Regex.exec arg
      step2Data = chMatch[0]

      chIdLinkMatch = step2Data.match charactersAndIdsRegex
      chIdLink = chIdLinkMatch[1] #Format : /ID/Char_name_shortened , for use in directing to myanimelist.net/character/ID/Char_name
      characterName = chIdLinkMatch[2]

      chId = (chIdLink.split('/'))[0]

      chImageMatch = step2Data.match charactersStep2Image
      chImage = chImageMatch[1]

      character = { id: chId, name: characterName, image: chImage }
      vas = []

      while vaMatch = voiceActorsAndIdsRegex.exec step2Data
        va = { }
        vaIdLink = vaMatch[1] #Format : /ID/Char_name_shortened , for use in directing to myanimelist.net/people/ID/Char_name
        vaName = vaMatch[2]
        va = { idLink : vaIdLink, name: vaName }
        vas.push va

      counter = 0
      while vaImageMatch = vaStep2Image.exec step2Data
        vaImage = vaImageMatch[1]


        _.assign vas[counter], { image: vaImage }
        counter = counter + 1

      _.assign character, { voiceActors: vas }
      characters.push character

    animeDetails = {
       studio: { id: studioId , name: studioName }
       source: source
       synopsis: synopsis
       japanese: japaneseTranslation
       broadcast: broadcast
       duration: duration
       aired: aired
       characters: characters }
    animeDetails
  parseMyAnimelistExtendedSearch: (body) ->
    genreRegexp = /(Genres:<\/span> )(.*)(<br \/>)/
    scoreExp = /Score:<\/span>\s(.*)\s<small>/
    rankExp = /Ranked:<\/span>\s#(.*)<br \/>/
    popularityExp = /Popularity:<\/span>\s#(.*)<br \/>/
    synopsisExp = /margin-bottom: 10px;">(.*)<a href=/
    scoredByExp = /scored\sby\s(.*[0-9])/

    genreMatch = body.match genreRegexp
    if genreMatch?
      genre = (body.match genreRegexp)[2]
    else
      genre = "Unknown"
    #application.logDebug "Genre: " + genre
    scoreMatch = body.match scoreExp
    if scoreMatch?
      score = (body.match scoreExp)[1]
    else
      score = "-"
    #application.logDebug "Score: " + score
    rankMatch = body.match rankExp
    if rankMatch?
      rank = rankMatch[1]
    else
      rank = "Unknown"
    #application.logDebug "Rank: " + rank
    popularityMatch = body.match popularityExp
    if popularityMatch?
      popularity = popularityMatch[1]
    else
      popularity = "Unknown"
    #application.logDebug "Popularity: " + popularity
    synopsisMatch = body.match synopsisExp
    if synopsisMatch?
      synopsis = synopsisMatch[1]
    else
      synopsis = "-"

    scoredByMatch = body.match scoredByExp
    if scoredByMatch?
      scoredBy = scoredByMatch[1]
    else
      scoredBy = "0"
    #application.logDebug "Syn: " + synopsis

    animeDetails =
      genres: genre.split(',').map((str) => S(str).trimLeft().s)
      score: score
      rank: rank
      popularity: popularity
      synopsis: synopsis
      scoredBy: scoredBy

    animeDetails
