(function() {
  var StreamServices, stringjs, _;

  _ = require('lodash');

  stringjs = require('string');

  module.exports = StreamServices = (function() {
    function StreamServices() {}

    StreamServices.prototype.streamServices = [
      {
        name: 'AnimeLab',
        identifiers: ['animelab.com/player/']
      }, {
        name: 'ANN',
        identifiers: [/animenewsnetwork.com\/video\/[0-9]+/i]
      }, {
        name: 'Crunchyroll',
        identifiers: [/crunchyroll\.[a-z.]+\/[^\/]+\/.*-movie-[0-9]+/i, /crunchyroll\.[a-z.]+\/[^\/]+\/episode-[0-9]+.*-[0-9]+/i]
      }, {
        name: 'Daisuki',
        identifiers: [/daisuki\.net\/[a-z]+\/[a-z]+\/anime\/watch/i]
      }, {
        name: 'Plex',
        identifiers: [/(?:(?:localhost|\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}):32400|plex.tv)\/web\//i]
      }, {
        name: 'Veoh',
        identifiers: [/veoh.com\/watch\//i]
      }, {
        name: 'Viz',
        identifiers: [/viz.com\/anime\/streaming\/[^\/]+-episode-[0-9]+\//i, /viz.com\/anime\/streaming\/[^\/]+-movie\//i]
      }, {
        name: 'Wakanim',
        identifiers: [/wakanim\.tv\/video(-premium)?\/[^\/]+\//i]
      }, {
        name: 'Youtube',
        identifiers: [/youtube.com\/watch/i]
      }
    ];

    StreamServices.prototype.getStreamServiceFromUrl = function(url) {
      var streamService;
      streamService = void 0;
      _.forEach(this.streamServices, (function(_this) {
        return function(v, k) {
          return _.forEach(v.identifiers, function(vi, ki) {
            var match;
            match = url.match(vi);
            if (match != null) {
              return streamService = v;
            }
          });
        };
      })(this));
      return streamService;
    };

    StreamServices.prototype.cleanStreamServiceTitle = function(ss, title) {
      var pos;
      if (ss.name === 'AnimeLab') {
        title = stringjs(title).chompLeft('AnimeLab - ').s;
      }
      if (ss.name === 'ANN') {
        title = stringjs(title).chompRight(' - Anime News Network').replace(' (d)', '').replace(' (s)', '').s;
      }
      if (ss.name === 'Crunchyroll') {
        title = stringjs(title).chompLeft('Crunchyroll - Watch ').s;
        title = stringjs(title).chompRight(' - Movie - Movie').s;
      }
      if (ss.name === 'Daisuki') {
        title = stringjs(title).chompRight(' - DAISUKI').s;
        pos = title.lastIndexOf(' - ');
        if (pos !== -1) {
          title = title.substring(pos + 3) + " - " + title.substring(1, pos);
        }
      }
      if (ss.name === 'Plex') {
        title = stringjs(title).chompLeft('Plex').s;
        title = stringjs(title).chompLeft('\u25B6 ').replace(' \u00B7 ', '').s;
      }
      if (ss.name === 'Veoh') {
        title = stringjs(title).chompLeft('Watch Videos Online | ').chompRight(' | Veoh.com').s;
      }
      if (ss.name === 'Viz') {
        title = stringjs(title).chompLeft('VIZ.com - NEON ALLEY - ').s;
      }
      if (ss.name === 'Wakanim') {
        title = stringjs(title).chompRight(' - Wakanim.TV').chompRight(' / Streaming').replace(' de ', ' ').replace(' en VOSTFR', ' VOSTFR').s;
      }
      if (ss.name === 'Youtube') {
        title = stringjs(title).chompLeft('\u25B6 ').chompRight(' - YouTube').s;
      }
      return title;
    };

    return StreamServices;

  })();

}).call(this);
