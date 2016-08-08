(function() {
  var DefaultOptions, SettingsManager, mkdirp, path, _, _when;

  DefaultOptions = require('./options');

  mkdirp = require('mkdirp');

  _ = require('lodash');

  _when = require('when');

  path = require('path');

  module.exports = SettingsManager = (function() {
    SettingsManager.prototype.appOptions = null;

    SettingsManager.prototype.firstLaunch = false;

    function SettingsManager() {
      process.env.CHIIKA_HOME = chiika.getAppHome();
      if (process.env.TEST_MODE != null) {
        chiika.testMode = true;
      } else {
        chiika.testMode = false;
      }
    }

    SettingsManager.prototype.initialize = function() {
      var defer;
      defer = _when.defer();
      this.createFolders().then((function(_this) {
        return function() {
          var cf, configExists, configFile;
          _this.configFilePath = path.join("Config", "Chiika.json");
          configExists = chiika.utility.fileExistsSmart(_this.configFilePath);
          if (configExists) {
            configFile = chiika.utility.readFileSmart(_this.configFilePath);
            _this.appOptions = JSON.parse(configFile);
          } else {
            cf = chiika.utility.openFileWSmart(_this.configFilePath);
            chiika.utility.writeFileSmart(_this.configFilePath, JSON.stringify(DefaultOptions));
            chiika.utility.closeFileSync(cf);
            _this.appOptions = DefaultOptions;
            _this.firstLaunch = true;
          }
          defer.resolve();
          return chiika.logger.info("[cyan](Settings-Manager) Settings initialized");
        };
      })(this));
      return defer.promise;
    };

    SettingsManager.prototype.applySettings = function() {
      if (this.getOption('RememberWindowSizeAndPosition') === true) {
        return chiika.windowManager.rememberWindowProperties();
      }
    };

    SettingsManager.prototype.save = function() {
      var cf;
      cf = chiika.utility.openFileWSmart(this.configFilePath);
      chiika.utility.writeFileSmart(this.configFilePath, JSON.stringify(this.appOptions));
      chiika.utility.closeFileSync(cf);
      return chiika.logger.info("Saving settings...");
    };

    SettingsManager.prototype.createFolders = function() {
      var chiikaHome, folders, promises;
      chiikaHome = chiika.getAppHome();
      folders = ["Config", "Data", "Scripts", "Cache", "Cache/Scripts", "Data/Images"];
      promises = [];
      _.forEach(folders, function(v, k) {
        return promises.push(chiika.utility.createFolderSmart(v));
      });
      promises.push(chiika.utility.createFolder(chiika.getDbHome()));
      return _when.all(promises);
    };

    SettingsManager.prototype.getOption = function(name) {
      if (this.appOptions[name] != null) {
        chiika.logger.warn("The requested option " + this.appOptions[name] + " is not defined!");
        return void 0;
      } else {
        return this.appOptions[name];
      }
    };

    SettingsManager.prototype.setOption = function(name, value) {
      if (!_.isUndefined(name && !_.isUndefined(value))) {
        this.appOptions[name] = value;
      } else {
        chiika.logger.warn("You have supplied incorrect paramters.");
      }
      return this.save();
    };

    SettingsManager.prototype.setWindowProperties = function(windowOptions) {
      return this.setOption('WindowProperties', windowOptions);
    };

    return SettingsManager;

  })();

}).call(this);
