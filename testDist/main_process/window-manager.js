(function() {
  var BrowserWindow, Emitter, Menu, Tray, WindowManager, globalShortcut, ipcMain, _, _ref;

  _ref = require('electron'), BrowserWindow = _ref.BrowserWindow, ipcMain = _ref.ipcMain, globalShortcut = _ref.globalShortcut, Tray = _ref.Tray, Menu = _ref.Menu;

  Emitter = require('event-kit').Emitter;

  _ = require('lodash');

  module.exports = WindowManager = (function() {
    WindowManager.prototype.mainWindow = null;

    WindowManager.prototype.loginWindow = null;

    WindowManager.prototype.loginWindowInstance = null;

    WindowManager.prototype.emitter = null;

    WindowManager.prototype.windows = [];

    function WindowManager() {
      this.emitter = new Emitter;
    }

    WindowManager.prototype.createWindowAndOpen = function(options) {
      var remember, winProps, window, windowOptions;
      windowOptions = {
        width: options.width,
        height: options.height,
        title: options.title,
        icon: options.icon,
        frame: false,
        show: options.show,
        backgroundColor: '#2e2c29'
      };
      if (options.name === 'main') {
        winProps = chiika.settingsManager.getOption('WindowProperties');
        remember = chiika.settingsManager.getOption('RememberWindowSizeAndPosition');
        if (remember) {
          windowOptions.width = winProps.width;
          windowOptions.height = winProps.height;
          windowOptions.x = winProps.x;
          windowOptions.y = winProps.y;
        }
      }
      if (!_.isUndefined(options.x && !_.isUndefined(options.y))) {
        _.assign(windowOptions, {
          x: option.x,
          y: options.y
        });
      }
      window = new BrowserWindow(windowOptions);
      this.handleWindowEvents(window);
      _.assign(window, {
        name: options.name,
        rawWindowInstance: window,
        url: options.url
      });
      this.windows.push(window);
      if (options.name === 'main') {
        this.mainWindow = window;
      }
      if (options.name === 'loading') {
        this.loadingWindow = window;
      }
      chiika.logger.info("Adding new window..");
      if (options.loadImmediately) {
        window.loadURL(options.url);
      }
      window.closeDevTools();
      return window;
    };

    WindowManager.prototype.createModalWindow = function(options, returnCallback) {
      var parent, window;
      if (options.parent === 'main') {
        parent = this.getMainWindow();
      }
      if (options.parent === 'login') {
        parent = this.getLoginWindow();
      }
      chiika.logger.info("Adding new modal window.. " + parent.name);
      if (parent != null) {
        window = new BrowserWindow({
          webPreferences: {
            nodeIntegration: false,
            preload: __dirname + "/preload.js"
          },
          width: 1400,
          height: 900,
          parent: parent,
          modal: true,
          show: false,
          frame: false
        });
        this.handleWindowEvents(window);
        _.assign(window, {
          name: options.name
        });
        this.windows.push(window);
        window.openDevTools();
        window.once('ready-to-show', (function(_this) {
          return function() {
            return window.show();
          };
        })(this));
        window.loadURL(options.url);
        window.on('closed', (function(_this) {
          return function() {
            chiika.logger.info("Modal window is closed");
            return returnCallback();
          };
        })(this));
        return window.webContents.on('dom-ready', (function(_this) {
          return function() {
            _this.emitter.emit('ui-dom-ready', window);
            return chiika.chiikaApi.emit('ui-dom-ready', window);
          };
        })(this));
      }
    };

    WindowManager.prototype.removeWindow = function(window) {
      var match;
      match = _.find(this.windows, window);
      if (match != null) {
        chiika.logger.info("Removed window. " + match.name);
        return _.remove(this.windows, window);
      }
    };

    WindowManager.prototype.rememberWindowProperties = function() {
      var window;
      window = this.getMainWindow();
      if (window != null) {
        return this.emitter.on('close', function() {
          var height, width, winPosX, winPosY;
          if (window.name === 'main') {
            winPosX = window.getPosition()[0];
            winPosY = window.getPosition()[1];
            width = window.getSize()[0];
            height = window.getSize()[1];
            return chiika.settingsManager.setWindowProperties({
              x: winPosX,
              y: winPosY,
              width: width,
              height: height
            });
          }
        });
      } else {
        return chiika.logger.warn("Can't remember window properties because window is null.");
      }
    };

    WindowManager.prototype.handleWindowEvents = function(window) {
      window.on('closed', (function(_this) {
        return function() {
          _this.emitter.emit('closed', window);
          return window = null;
        };
      })(this));
      window.on('close', (function(_this) {
        return function() {
          _this.emitter.emit('close', window);
          return _this.removeWindow(window);
        };
      })(this));
      window.webContents.on('did-finish-load', (function(_this) {
        return function() {
          _this.emitter.emit('did-finish-load');
          return chiika.logger.info("[magenta](Window-Manager) Window has finished loading.");
        };
      })(this));
      return window.webContents.on('ready-to-show', (function(_this) {
        return function() {
          _this.emitter.emit('ready-to-show');
          return chiika.logger.info("[magenta](Window-Manager) Window has finished loading.");
        };
      })(this));
    };

    WindowManager.prototype.loadURL = function(window) {
      return window.loadURL(window.url);
    };

    WindowManager.prototype.openDevTools = function(window) {
      return window.openDevTools();
    };

    WindowManager.prototype.getPosition = function(window) {
      return window.getPosition();
    };

    WindowManager.prototype.getSize = function(window) {
      return window.getSize();
    };

    WindowManager.prototype.getMainWindow = function() {
      return this.mainWindow;
    };

    WindowManager.prototype.getWindowByName = function(name) {
      var match;
      match = _.find(this.windows, {
        name: name
      });
      if (match != null) {
        return match;
      } else {
        chiika.logger.warn("Window named " + name + " can't be found.");
        return void 0;
      }
    };

    WindowManager.prototype.getLoginWindow = function() {
      return this.getWindowByName('login');
    };

    WindowManager.prototype.showMainWindow = function(loadURL) {
      if (this.mainWindow != null) {
        if (loadURL) {
          this.loadURL(this.mainWindow);
        }
        return this.mainWindow.show();
      }
    };

    WindowManager.prototype.showLoadingWindow = function() {
      if (this.loadingWindow != null) {
        return this.loadingWindow.show();
      }
    };

    WindowManager.prototype.hideMainWindow = function() {
      if (this.mainWindow != null) {
        return this.mainWindow.hide();
      }
    };

    WindowManager.prototype.hideLoadingWindow = function() {
      if (this.loadingWindow != null) {
        return this.loadingWindow.hide();
      }
    };

    WindowManager.prototype.closeLoadingWindow = function() {
      if (this.loadingWindow != null) {
        return this.loadingWindow.close();
      }
    };

    return WindowManager;

  })();

}).call(this);
