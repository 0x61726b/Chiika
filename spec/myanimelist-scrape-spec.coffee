request           = require 'request'
xml2js            = require 'xml2js'
_                 = require 'lodash'
GlobalSetup               = require './global-setup'

Parser                    = require './../src/main_process/parser'

animePageUrl = 'http://myanimelist.net/anime/21'
mangaPageUrl = 'http://myanimelist.net/manga/25132'
animeAjaxUrl = 'http://myanimelist.net/includes/ajax.inc.php?id=21&t=64'

pageContents = ""


describe 'Parsers', ->

  describe 'Myanimelist Manga Page Parsing', ->
    this.timeout(10000)

    mangaDetails = null
    pageContents = ""

    beforeEach (done) =>
      request {url: mangaPageUrl, headers: { 'UserAgent': 'ChiikaDesktopApplication' }},(error,response,body) =>
        pageContents = body
        mangaDetails = parser.parseMangaDetailsMalPage(pageContents)
        done()

    parser = new Parser()

    # it 'Find Published', ->
    #   publishedRegex = /(Published:<\/span>\s*)(.*)\s*<\/div>/

    it 'MAL Manga Page', ->
      mangaDetails.author.name.should.be.equal('Tashiro, Tetsuya')
      mangaDetails.published.should.be.equal("Apr  22, 2010 to ?")
      mangaDetails.serialization.should.be.equal('Gangan Joker')
      mangaDetails.japanese.length.should.be.at.least(1)
      mangaDetails.characters.length.should.be.at.least(1)

  describe 'Myanimelist Anime Page Parsing',->
    this.timeout(10000)

    animeDetails = null
    pageContents = ""

    beforeEach (done) =>
      request {url: animePageUrl},(error,response,body) =>
        pageContents = body
        animeDetails = parser.parseAnimeDetailsMalPage(pageContents)
        done()

    parser = new Parser()



    it 'MAL Anime Page', () ->
      animeDetails.studio.name.should.be.equal("Toei Animation")
      animeDetails.source.should.be.equal("Manga")
      animeDetails.japanese.should.be.equal("ONE PIECE")
      animeDetails.broadcast.should.be.equal("Sundays at 09:30 (JST)")
      animeDetails.duration.should.be.equal("24 min.")
      animeDetails.aired.should.be.equal("Oct 20, 1999 to ?")
      animeDetails.synopsis.length.should.be.at.least(5)
      animeDetails.characters.length.should.be.at.least(1)


  #Skip this because the data could change everyday
  describe.skip 'That weird ajax.inc thingy', ->
    animeDetails = null

    before (done) =>
      request {url: animeAjaxUrl},(error,response,body) =>
        pageContents = body
        animeDetails = parser.parseMyAnimelistExtendedSearch(pageContents)
        done()

    parser = new Parser()

    it 'Find Genres', ->
      animeDetails.genres.length.should.be.at.least(7)

    it 'Find Score', ->
      animeDetails.score.should.be.equal('8.59')

    it 'Find Popularity', ->
      animeDetails.popularity.should.be.equal('27')

    it 'Find Rank', ->
      animeDetails.rank.should.be.equal('69')

    it 'Find ScoredBy', ->
      animeDetails.scoredBy.should.be.equal('287,515')
