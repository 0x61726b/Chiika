request           = require 'request'
xml2js            = require 'xml2js'
_                 = require 'lodash'

animePageUrl = 'http://myanimelist.net/anime/21'

pageContents = ""


describe 'MyAnimelist',->
  beforeEach (done) =>
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

  it 'Find Studio', (done) ->
    studiosMatch = pageContents.match studiosRegex
    if studiosMatch?
      studioName = studiosMatch[3]
      studioIdToBeParsed = studiosMatch[2]
      parseStudioId = studioIdToBeParsed.split('/')
      studioId = parseStudioId[0]
      expect(studioName).toBe("Toei Animation")

    done()

  it 'Find Source', (done) ->
    sourceMatch = pageContents.match sourceRegex
    if sourceMatch?
      source = sourceMatch[2]
      expect(source).toBe("Manga")
    done()

  it 'Find Japanese', (done) ->
    japaneseTranslationMatch = pageContents.match japaneseTranslationRegex
    if japaneseTranslationMatch?
      japaneseTranslation = japaneseTranslationMatch[2]
      expect(japaneseTranslation).toBe("ONE PIECE")
    done()

  it 'Find Broadcast', (done) ->
    broadcastMatch = pageContents.match broadcastRegex
    if broadcastMatch?
      broadcast = broadcastMatch[2]
      expect(broadcast).toBe("Sundays at 09:30 (JST)")
    done()

  it 'Find Duration', (done) ->
    durationMatch = pageContents.match durationRegex
    if durationMatch?
      duration = durationMatch[2]
      expect(duration).toBe("24 min.")
    done()

  it 'Find Aired', (done) ->
    airedMatch = pageContents.match airedRegex
    if airedMatch?
      aired = airedMatch[2]
      expect(aired).toBe("Oct 20, 1999 to ?")
    done()

  it 'Find Synopsis', (done) ->
    synMatch = pageContents.match synopsisRegex
    if synMatch?
      synopsis = synMatch[1]
      expect(synopsis.length).toBeGreaterThan(5)
    done()

  it 'Find Characters', (done) ->
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

    expect(characters.length).toBeGreaterThan(1)

    _.forEach characters, (v,k) =>
      expect(v.voiceActors.length).toBeGreaterThan(0)
    done()


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
