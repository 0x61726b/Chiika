request           = require 'request'
xml2js            = require 'xml2js'
_                 = require 'lodash'
GlobalSetup               = require './global-setup'

animePageUrl = 'http://myanimelist.net/anime/21'

pageContents = ""


describe 'Myanimelist Anime Page Parsing',->
  this.timeout(10000)

  before (done) =>
    if pageContents.length == 0
      request {url: animePageUrl},(error,response,body) =>
        pageContents = body
        done()
    else
      done()
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

  it 'Find Studio', () ->
    studiosMatch = pageContents.match studiosRegex
    if studiosMatch?
      studioName = studiosMatch[3]
      studioIdToBeParsed = studiosMatch[2]
      parseStudioId = studioIdToBeParsed.split('/')
      studioId = parseStudioId[0]
      studioName.should.be.equal("Toei Animation")
  #
  #
  it 'Find Source', () ->
    sourceMatch = pageContents.match sourceRegex
    if sourceMatch?
      source = sourceMatch[2]

      source.should.be.equal("Manga")

  #
  it 'Find Japanese', () ->
    japaneseTranslationMatch = pageContents.match japaneseTranslationRegex
    if japaneseTranslationMatch?
      japaneseTranslation = japaneseTranslationMatch[2]
      japaneseTranslation.should.be.equal("ONE PIECE")

  #
  it 'Find Broadcast', () ->
    broadcastMatch = pageContents.match broadcastRegex
    if broadcastMatch?
      broadcast = broadcastMatch[2]
      broadcast.should.be.equal("Sundays at 09:30 (JST)")

  #
  it 'Find Duration', () ->
    durationMatch = pageContents.match durationRegex
    if durationMatch?
      duration = durationMatch[2]
      duration.should.be.equal("24 min.")


  #
  it 'Find Aired', () ->
    airedMatch = pageContents.match airedRegex
    if airedMatch?
      aired = airedMatch[2]
      aired.should.be.equal("Oct 20, 1999 to ?")

  #
  it 'Find Synopsis', () ->
    synMatch = pageContents.match synopsisRegex
    if synMatch?
      synopsis = synMatch[1]
      synopsis.length.should.be.at.least(5)

  #
  it 'Find Characters', () ->
    characters = []
    while chMatch = charactersStep1Regex.exec pageContents
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

    characters.length.should.be.at.least(1)

    _.forEach characters, (v,k) =>
      v.voiceActors.length.should.be.at.least(0)



  #
  #
  #
  # it('Find Studio', function(){
  #   request({url: animePageUrl},function(error,response,body) {
  #     var studiosMatch = body.match studiosRegex
  #     if _.isUndefined(studiosMatch) || _.isNull(studiosMatch) {
  #
  #     } else {
  #       studioName = studiosMatch[3]
  #       studioIdToBeParsed = studiosMatch[2]
  #       parseStudioId = studioIdToBeParsed.split('/')
  #       studioId = parseStudioId[0]
  #       expect(studioName).toBe("Toei Animation");
  #     }
  #   })
  #
  # });
