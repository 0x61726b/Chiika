(function() {
  var Parser, S, XmlParser, _;

  XmlParser = require("xml2js");

  _ = require('lodash');

  S = require('string');

  module.exports = Parser = (function() {
    function Parser() {}

    Parser.prototype.parseXml = function(data) {
      return new Promise(function(resolve) {
        return XmlParser.parseString(data, {
          explicitArray: false
        }, function(err, result) {
          if (result) {
            return resolve(result);
          }
        });
      });
    };

    Parser.prototype.parseAnimeDetailsMalPage = function(arg) {
      var aired, airedMatch, airedRegex, animeDetails, broadcast, broadcastMatch, broadcastRegex, chId, chIdLink, chIdLinkMatch, chImage, chImageMatch, chMatch, character, characterName, characters, charactersAndIdsRegex, charactersStep1Regex, charactersStep2Image, counter, duration, durationMatch, durationRegex, japaneseTranslation, japaneseTranslationMatch, japaneseTranslationRegex, parseStudioId, source, sourceMatch, sourceRegex, step2Data, studioId, studioIdToBeParsed, studioName, studiosMatch, studiosRegex, synopsis, synopsisMatch, synopsisRegex, va, vaIdLink, vaImage, vaImageMatch, vaMatch, vaName, vaStep2Image, vas, voiceActorsAndIdsRegex;
      studiosRegex = /(Studios:<\/span>\s*).*f="\/anime\/producer\/(.*"\s)title="(.*)">/;
      sourceRegex = /(Source:<\/span>\s*)(.*)\s*<\/div>/;
      japaneseTranslationRegex = /(Japanese:<\/span>\s*)(.*)\s*<\/div>/;
      broadcastRegex = /(Broadcast:<\/span>\s*)(.*)\s*<\/div>/;
      durationRegex = /(Duration:<\/span>\s*)(.*)\s*<\/div>/;
      airedRegex = /(Aired:<\/span>\s*)(.*)\s*<\/div>/;
      synopsisRegex = /itemprop="description">([^]+?)(?=<\/span)/;
      charactersStep1Regex = /(<div class="picSurround"><a href="\/character\/)([^]+?)(?=\/table>)/g;
      charactersStep2Image = /data-src="(.*?)"\s/;
      charactersAndIdsRegex = /\s<a href="\/character\/(.*)">(.*)<\/a>/;
      voiceActorsAndIdsRegex = /<a href="\/people\/(.*)">(.*)<\/a><br>/g;
      vaStep2Image = /\w"><img src="\/images\/spacer.gif"\sdata-src="(.*?)"\s/g;
      studiosMatch = arg.match(studiosRegex);
      if (studiosMatch != null) {
        studioName = studiosMatch[3];
        studioIdToBeParsed = studiosMatch[2];
        parseStudioId = studioIdToBeParsed.split('/');
        studioId = parseStudioId[0];
      }
      sourceMatch = arg.match(sourceRegex);
      if (sourceMatch != null) {
        source = sourceMatch[2];
      }
      synopsisMatch = arg.match(synopsisRegex);
      if (synopsisMatch != null) {
        synopsis = synopsisMatch[1];
      }
      japaneseTranslationMatch = arg.match(japaneseTranslationRegex);
      if (japaneseTranslationMatch != null) {
        japaneseTranslation = japaneseTranslationMatch[2];
      }
      broadcastMatch = arg.match(broadcastRegex);
      if (broadcastMatch != null) {
        broadcast = broadcastMatch[2];
      }
      durationMatch = arg.match(durationRegex);
      if (durationMatch != null) {
        duration = durationMatch[2];
      }
      airedMatch = arg.match(airedRegex);
      if (airedMatch != null) {
        aired = airedMatch[2];
      }
      characters = [];
      while (chMatch = charactersStep1Regex.exec(arg)) {
        step2Data = chMatch[0];
        chIdLinkMatch = step2Data.match(charactersAndIdsRegex);
        chIdLink = chIdLinkMatch[1];
        characterName = chIdLinkMatch[2];
        chId = (chIdLink.split('/'))[0];
        chImageMatch = step2Data.match(charactersStep2Image);
        chImage = chImageMatch[1];
        character = {
          id: chId,
          name: characterName,
          image: chImage
        };
        vas = [];
        while (vaMatch = voiceActorsAndIdsRegex.exec(step2Data)) {
          va = {};
          vaIdLink = vaMatch[1];
          vaName = vaMatch[2];
          va = {
            idLink: vaIdLink,
            name: vaName
          };
          vas.push(va);
        }
        counter = 0;
        while (vaImageMatch = vaStep2Image.exec(step2Data)) {
          vaImage = vaImageMatch[1];
          _.assign(vas[counter], {
            image: vaImage
          });
          counter = counter + 1;
        }
        _.assign(character, {
          voiceActors: vas
        });
        characters.push(character);
      }
      animeDetails = {
        studio: {
          id: studioId,
          name: studioName
        },
        source: source,
        synopsis: synopsis,
        japanese: japaneseTranslation,
        broadcast: broadcast,
        duration: duration,
        aired: aired,
        characters: characters
      };
      return animeDetails;
    };

    Parser.prototype.parseMyAnimelistExtendedSearch = function(body) {
      var animeDetails, genre, genreMatch, genreRegexp, popularity, popularityExp, popularityMatch, rank, rankExp, rankMatch, score, scoreExp, scoreMatch, scoredBy, scoredByExp, scoredByMatch, synopsis, synopsisExp, synopsisMatch;
      genreRegexp = /(Genres:<\/span> )(.*)(<br \/>)/;
      scoreExp = /Score:<\/span>\s(.*)\s<small>/;
      rankExp = /Ranked:<\/span>\s#(.*)<br \/>/;
      popularityExp = /Popularity:<\/span>\s#(.*)<br \/>/;
      synopsisExp = /margin-bottom: 10px;">(.*)<a href=/;
      scoredByExp = /scored\sby\s(.*[0-9])/;
      genreMatch = body.match(genreRegexp);
      if (genreMatch != null) {
        genre = (body.match(genreRegexp))[2];
      } else {
        genre = "Unknown";
      }
      scoreMatch = body.match(scoreExp);
      if (scoreMatch != null) {
        score = (body.match(scoreExp))[1];
      } else {
        score = "-";
      }
      rankMatch = body.match(rankExp);
      if (rankMatch != null) {
        rank = rankMatch[1];
      } else {
        rank = "Unknown";
      }
      popularityMatch = body.match(popularityExp);
      if (popularityMatch != null) {
        popularity = popularityMatch[1];
      } else {
        popularity = "Unknown";
      }
      synopsisMatch = body.match(synopsisExp);
      if (synopsisMatch != null) {
        synopsis = synopsisMatch[1];
      } else {
        synopsis = "-";
      }
      scoredByMatch = body.match(scoredByExp);
      if (scoredByMatch != null) {
        scoredBy = scoredByMatch[1];
      } else {
        scoredBy = "0";
      }
      animeDetails = {
        genres: genre.split(',').map((function(_this) {
          return function(str) {
            return S(str).trimLeft().s;
          };
        })(this)),
        score: score,
        rank: rank,
        popularity: popularity,
        synopsis: synopsis,
        scoredBy: scoredBy
      };
      return animeDetails;
    };

    return Parser;

  })();

}).call(this);
