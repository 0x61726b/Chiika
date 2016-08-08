(function() {
  var AppDelegate, BrowserWindow, Menu, Tray, app, globalShortcut, ipcMain, _ref, _when;

  _ref = require('electron'), BrowserWindow = _ref.BrowserWindow, ipcMain = _ref.ipcMain, globalShortcut = _ref.globalShortcut, Tray = _ref.Tray, Menu = _ref.Menu, app = _ref.app;

  _when = require('when');

  module.exports = AppDelegate = (function() {
    function AppDelegate() {}

    AppDelegate.prototype.readyPromise = [];

    AppDelegate.prototype.run = function() {
      this.readyPromise.push(this.onReady());
      this.windowsClosed();
      return this.willQuit();
    };

    AppDelegate.prototype.ready = function(callback) {
      return _when.all(this.readyPromise).then((function(_this) {
        return function() {
          return callback();
        };
      })(this));
    };

    AppDelegate.prototype.onReady = function() {
      var defer;
      defer = _when.defer();
      app.on('ready', (function(_this) {
        return function() {
          return chiika.settingsManager.initialize().then(function() {
            var loginWindow;
            defer.resolve();
            chiika.logger.verbose("Electron app is ready");
            loginWindow = chiika.windowManager.createWindowAndOpen({
              name: 'login',
              width: 1600,
              height: 900,
              title: 'Huehueheuehueheu',
              icon: "resources/icon.png",
              url: "file://" + __dirname + "/../static/LoginWindow.html",
              show: true,
              loadImmediately: true
            });
            return chiika.settingsManager.applySettings();
          });
        };
      })(this));
      return defer.promise;
    };

    AppDelegate.prototype.windowsClosed = function() {
      return app.on('window-all-closed', function() {
        chiika.logger.info("All windows are closed. Preparing exit...");
        return app.quit();
      });
    };

    AppDelegate.prototype.willQuit = function() {
      return app.on('will-quit', (function(_this) {
        return function() {
          globalShortcut.unregisterAll();
          return chiika.apiManager.clearCache();
        };
      })(this));
    };

    return AppDelegate;

  })();

}).call(this);
