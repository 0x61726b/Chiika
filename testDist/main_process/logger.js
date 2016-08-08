(function() {
  var Logger, moment, stringjs, winston;

  moment = require('moment');

  winston = require('winston');

  stringjs = require('string');

  module.exports = Logger = (function() {
    Logger.prototype.logger = null;

    function Logger(loglevel) {
      var transport;
      transport = new winston.transports.Console({
        level: loglevel,
        colorize: true,
        timestamp: function() {
          return Date.now();
        },
        formatter: (function(_this) {
          return function(options) {
            return _this.format(options);
          };
        })(this)
      });
      this.logger = new winston.Logger({
        transports: [transport],
        levels: {
          error: 0,
          warn: 1,
          info: 2,
          verbose: 3,
          script: 2,
          renderer: 2,
          debug: 4,
          silly: 5
        }
      });
      winston.addColors({
        error: 'red',
        warn: 'yellow',
        info: 'green',
        verbose: 'cyan',
        script: 'cyan',
        renderer: 'cyan',
        debug: 'blue',
        silly: 'magenta'
      });
    }

    Logger.prototype.format = function(options) {
      var appendToStr, chMatch, color, colorObj, fullMatch, msg, regex, string, text;
      string = moment().format('DD/MM HH:mm:ss') + ' ' + winston.config.colorize(options.level) + ' ';
      regex = /\[(red|green|blue|yellow|cyan|magenta|)\]\((.*?)\)/g;
      appendToStr = '';
      fullMatch = '';
      while (chMatch = regex.exec(options.message)) {
        fullMatch = chMatch[0];
        color = chMatch[1];
        text = chMatch[2];
        colorObj = {};
        colorObj[text] = color;
        winston.addColors(colorObj);
        appendToStr += winston.config.colorize(text);
      }
      string += appendToStr;
      if (fullMatch !== '') {
        msg = options.message;
        msg = stringjs(msg).replace(fullMatch, '').s;
        string += msg;
      } else {
        string += options.message;
      }
      return string;
    };

    return Logger;

  })();

}).call(this);
