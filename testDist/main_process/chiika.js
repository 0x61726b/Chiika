(function() {
  var APIManager, AppDelegate, AppOptions, Application, ApplicationWindow, BrowserWindow, ChiikaPublicApi, DbManager, Disposable, Emitter, IpcManager, Logger, Menu, Parser, RequestManager, SettingsManager, Tray, UIManager, Utility, WindowManager, app, fs, globalShortcut, ipcMain, menubar, mkdirp, path, string, yargs, _, _ref, _ref1, _when;

  _ref = require('electron'), BrowserWindow = _ref.BrowserWindow, ipcMain = _ref.ipcMain, globalShortcut = _ref.globalShortcut, Tray = _ref.Tray, Menu = _ref.Menu, app = _ref.app;

  yargs = require('yargs');

  path = require('path');

  fs = require('fs');

  mkdirp = require('mkdirp');

  _ = require('lodash');

  _when = require('when');

  _ref1 = require('event-kit'), Emitter = _ref1.Emitter, Disposable = _ref1.Disposable;

  string = require('string');

  ApplicationWindow = require('./app-window');

  menubar = require('./menubar');

  Logger = require('./logger');

  APIManager = require('./api-manager');

  DbManager = require('./database-manager');

  RequestManager = require('./request-manager');

  SettingsManager = require('./settings-manager');

  WindowManager = require('./window-manager');

  IpcManager = require('./ipc-manager');

  Parser = require('./parser');

  UIManager = require('./ui-manager');

  ChiikaPublicApi = require('./chiika-public');

  Utility = require('./utility');

  AppOptions = require('./options');

  AppDelegate = require('./app-delegate');

  process.on('uncaughtException', function(err) {
    console.log(err);
    // var error, errorFunction, fileLine, i, line, _i, _results;
    // if (err && (err.stack != null)) {
    //   error = err.stack.split("\n");
    //   _results = [];
    //   for (i = _i = 0; _i < 5; i = ++_i) {
    //     line = error[i];
    //     line = string(line).trimLeft().s;
    //     if (i > 0) {
    //       fileLine = line.substring(line.lastIndexOf('\\') + 1, line.length - 1);
    //       errorFunction = line.substring(3, line.indexOf('('));
    //       _results.push(chiika.logger.error(errorFunction + " - " + fileLine));
    //     } else {
    //       _results.push(chiika.logger.error(line));
    //     }
    //   }
    //   return _results;
    // } else {
    //   chiika.logger.error("Hmm....");
    //   return chiika.logger.error(err);
    // }
  });

  module.exports = Application = (function() {
    Application.prototype.window = null;

    Application.prototype.loginWindow = null;

    function Application() {
      global.chiika = this;
      this.chiikaHome = path.join(app.getPath('appData'), "chiika");
      this.logger = new Logger("verbose").logger;
      global.logger = this.logger;
      this.emitter = new Emitter;
      this.utility = new Utility();
      this.settingsManager = new SettingsManager();
      this.apiManager = new APIManager();
      this.dbManager = new DbManager();
      this.requestManager = new RequestManager();
      this.parser = new Parser();
      this.uiManager = new UIManager();
      this.chiikaApi = new ChiikaPublicApi({
        logger: this.logger,
        db: this.dbManager,
        parser: this.parser,
        ui: this.uiManager
      });
      this.windowManager = new WindowManager();
      this.appDelegate = new AppDelegate();
      this.ipcManager = new IpcManager();
      this.ipcManager.handleEvents();
      app.commandLine.appendSwitch('--disable-2d-canvas-image-chromium');
      app.commandLine.appendSwitch('--disable-accelerated-2d-canvas');
      app.commandLine.appendSwitch('--disable-gpu');
      this.appDelegate.run();
    }

    Application.prototype.run = function() {
      var userCount;
      userCount = this.dbManager.usersDb.users.length;
      chiika.logger.verbose("User count " + userCount);
      if (userCount === 0 && this.uiManager.getUIItemsCount() === 0) {
        this.apiManager.compileUserScripts().then((function(_this) {
          return function() {
            return _this.uiManager.preloadUIItems().then(function() {
              return chiika.logger.verbose("Preloading UI complete!");
            });
          };
        })(this));
      }
      if (userCount === 0 && this.uiManager.getUIItemsCount() > 0) {
        this.uiManager.preloadUIItems().then((function(_this) {
          return function() {
            chiika.logger.verbose("Preloading UI complete!");
            return _this.apiManager.compileUserScripts().then(function() {
              return _this.uiManager.checkUIData().then(function() {
                return _this.apiManager.postInit();
              });
            });
          };
        })(this));
      }
      if (userCount > 0) {
        if (this.uiManager.getUIItemsCount() > 0) {
          return this.uiManager.preloadUIItems().then((function(_this) {
            return function() {
              chiika.logger.verbose("Preloading UI complete!");
              return _this.apiManager.compileUserScripts().then(function() {
                return _this.uiManager.checkUIData().then(function() {
                  _this.apiManager.postInit();
                  _this.windowManager.closeLoadingWindow();
                  return _this.windowManager.showMainWindow(true);
                });
              });
            };
          })(this));
        } else {
          return this.apiManager.compileUserScripts().then((function(_this) {
            return function() {
              return _this.uiManager.preloadUIItems().then(function() {
                chiika.logger.verbose("Preloading UI complete!");
                _this.windowManager.closeLoadingWindow();
                return _this.windowManager.showMainWindow(true);
              });
            };
          })(this));
        }
      }
    };

    Application.prototype.getAppHome = function() {
      return this.chiikaHome;
    };

    Application.prototype.getDbHome = function() {
      return path.join(this.chiikaHome, "Data", "Database");
    };

    return Application;

  })();

  app = new Application();

}).call(this);
