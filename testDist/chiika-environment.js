(function() {
  var BrowserWindow, CardManager, ChiikaEnvironment, ChiikaIPC, Emitter, Logger, ViewManager, fs, ipcRenderer, path, remote, _, _ref, _when;

  Emitter = require('event-kit').Emitter;

  _ref = require('electron'), BrowserWindow = _ref.BrowserWindow, ipcRenderer = _ref.ipcRenderer, remote = _ref.remote;

  _ = require('lodash');

  fs = require('fs');

  path = require('path');

  _when = require('when');

  Logger = require('./main_process/Logger');

  ChiikaIPC = require('./chiika-ipc');

  ViewManager = require('./view-manager');

  CardManager = require('./card-manager');

  ChiikaEnvironment = (function() {
    ChiikaEnvironment.prototype.emitter = null;

    function ChiikaEnvironment(params) {
      var episodeCard, seasonCard, sourceCard, studioCard, testCard;
      if (params == null) {
        params = {};
      }
      this.applicationDelegate = params.applicationDelegate, this.window = params.window, this.chiikaHome = params.chiikaHome;
      window.chiika = this;
      this.emitter = new Emitter;
      this.logger = remote.getGlobal('logger');
      this.ipc = new ChiikaIPC();
      this.viewManager = new ViewManager();
      this.cardManager = new CardManager();
      testCard = {
        name: 'typeMiniCard',
        title: 'Type',
        content: 'TV',
        type: 'miniCard'
      };
      seasonCard = {
        name: 'seasonMiniCard',
        title: 'Season',
        content: 'Fall 2014',
        type: 'miniCard'
      };
      episodeCard = {
        name: 'episodeMiniCard',
        title: 'Episode',
        content: '6/24',
        type: 'miniCard'
      };
      studioCard = {
        name: 'studioMiniCard',
        title: 'Studio',
        content: 'Feel',
        type: 'miniCard'
      };
      sourceCard = {
        name: 'sourceMiniCard',
        title: 'Source',
        content: 'Manga',
        type: 'miniCard'
      };
      this.cardManager.addCard(testCard);
      this.cardManager.addCard(seasonCard);
      this.cardManager.addCard(episodeCard);
      this.cardManager.addCard(studioCard);
      this.cardManager.addCard(sourceCard);
      this.ipc.onReconstructUI();
    }

    ChiikaEnvironment.prototype.preload = function() {
      var async, defer;
      defer = _when.defer();
      async = [defer.promise];
      this.ipc.sendMessage('get-ui-data');
      this.ipc.refreshUIData((function(_this) {
        return function(args) {
          var infoStr, uiData, _i, _len, _ref1;
          _this.uiData = args;
          chiika.logger.renderer("UI data is present.");
          infoStr = '';
          _ref1 = _this.uiData;
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            uiData = _ref1[_i];
            infoStr += " " + uiData.displayName + " ( " + uiData.displayType + " )";
          }
          chiika.logger.renderer("Current UI items are " + infoStr);
          defer.resolve();
          return console.log(_this.uiData);
        };
      })(this));
      return _when.all(async);
    };

    ChiikaEnvironment.prototype.onReinitializeUI = function(loading, main) {
      return this.emitter.on('reinitialize-ui', (function(_this) {
        return function(args) {
          loading();
          _this.ipc.disposeListeners('get-ui-data-response');
          return _this.preload().then(function() {
            return setTimeout(main, args.delay);
          });
        };
      })(this));
    };

    ChiikaEnvironment.prototype.sendNotification = function(title, body, icon) {
      var notf;
      if (icon == null) {
        icon = __dirname + "/../assets/images/chiika.png";
      }
      return notf = new Notification(title, {
        body: body,
        icon: icon
      });
    };

    ChiikaEnvironment.prototype.reInitializeUI = function(delay) {
      console.log("Reinitiazing UI");
      if (delay == null) {
        delay = 500;
      }
      return this.emitter.emit('reinitialize-ui', {
        delay: delay
      });
    };

    ChiikaEnvironment.prototype.getWorkingDirectory = function() {
      return process.cwd();
    };

    ChiikaEnvironment.prototype.getResourcesPath = function() {
      return process.resourcesPath;
    };

    ChiikaEnvironment.prototype.getUserTimezone = function() {
      var moment, userTimezone, utcOffset;
      moment = require('moment-timezone');
      userTimezone = moment.tz(moment.tz.guess());
      utcOffset = moment.parseZone(userTimezone).utcOffset() * 60;
      return {
        timezone: userTimezone,
        offset: utcOffset
      };
    };

    return ChiikaEnvironment;

  })();

  module.exports = ChiikaEnvironment;

}).call(this);
