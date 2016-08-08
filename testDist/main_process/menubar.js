(function() {
  var BrowserWindow, Menubar, Positioner, Tray, app, electron, events, fs, path, _;

  path = require('path');

  events = require('events');

  fs = require('fs');

  electron = require('electron');

  app = electron.app;

  Tray = electron.Tray;

  BrowserWindow = electron.BrowserWindow;

  Positioner = require('electron-positioner');

  _ = require('lodash');

  module.exports = Menubar = (function() {
    Menubar.prototype.clickCount = 0;

    Menubar.prototype.isPlayingVideo = false;

    function Menubar() {
      application.emitter.on('mp-video-changed', (function(_this) {
        return function() {
          return _this.isPlayingVideo = true;
        };
      })(this));
      application.emitter.on('mp-closed', (function(_this) {
        return function() {
          return _this.isPlayingVideo = false;
        };
      })(this));
    }

    Menubar.prototype.handleClick = function(e, bounds) {
      var clearClickCount;
      this.clickCount++;
      if (this.isPlayingVideo && this.clickCount === 1) {
        this.clicked(e, bounds);
      }
      if (this.isPlayingVideo && this.clickCount === 2) {
        application.showMainWindow();
      }
      if (!this.isPlayingVideo && this.clickCount === 1) {
        application.showMainWindow();
      }
      clearClickCount = (function(_this) {
        return function() {
          return _this.clickCount = 0;
        };
      })(this);
      return setTimeout(clearClickCount, 1000);
    };

    Menubar.prototype.clicked = function(e, bounds) {
      var cachedBounds;
      if (e.altKey || e.shiftKey || e.ctrlKey || e.metaKey) {
        return this.hideWindow();
      }
      if (this.menubar.window && this.menubar.window.isVisible()) {
        return this.hideWindow();
      }
      cachedBounds = bounds || cachedBounds;
      return this.showWindow(cachedBounds);
    };

    Menubar.prototype.create = function(opts) {
      if (opts == null) {
        opts = {
          dir: app.getAppPath()
        };
      }
      if (typeof opts === 'string') {
        opts = {
          dir: opts
        };
      }
      if (!opts.dir) {
        opts.dir = app.getAppPath();
      }
      if (!(path.isAbsolute(opts.dir))) {
        opts.dir = path.resolve(opts.dir);
      }
      if (!opts.index) {
        opts.index = 'file://' + path.join(opts.dir, 'index.html');
      }
      if (!opts.windowPosition) {
        if (process.platform === 'win32') {
          opts.windowPosition = 'trayBottomCenter';
        } else {
          opts.windowPosition = 'trayCenter';
        }
      }
      if (typeof opts.showDockIcon === 'undefined') {
        opts.showDockIcon = false;
      }
      opts.width = opts.width || 400;
      opts.height = opts.height || 400;
      opts.tooltip = opts.tooltip || '';
      this.opts = opts;
      app.on('ready', (function(_this) {
        return function() {
          return _this.appReady();
        };
      })(this));
      this.menubar = new events.EventEmitter();
      this.menubar.app = app;
      this.menubar.setOption = function(opt, val) {
        return this.opts[opt] = val;
      };
      this.menubar.getOption = function(opt) {
        return this.opts[opt];
      };
      return this.menubar;
    };

    Menubar.prototype.appReady = function() {
      var defaultClickEvent, iconPath;
      if (app.dock && !this.opts.showDockIcon) {
        app.dock.hide();
      }
      iconPath = this.opts.icon || path.join(this.opts.dir, 'IconTemplate.png');
      if (!fs.existsSync(iconPath)) {
        iconPath = path.join(__dirname, 'example', 'IconTemplate.png');
      }
      defaultClickEvent = 'click';
      this.menubar.tray = this.opts.tray || new Tray(iconPath);
      this.menubar.tray.on(defaultClickEvent, (function(_this) {
        return function(e, bounds) {
          return _this.handleClick(e, bounds);
        };
      })(this));
      this.menubar.tray.setToolTip(this.opts.tooltip);
      if (this.opts.preloadWindow) {
        this.createWindow();
      }
      this.menubar.showWindow = this.showWindow;
      this.menubar.hideWindow = this.hideWindow;
      return this.menubar.emit('ready');
    };

    Menubar.prototype.showWindow = function(trayPos) {
      var cachedBounds, noBoundsPosition, position, x, y, _ref;
      if (!this.menubar.window) {
        this.createWindow();
      }
      this.menubar.emit('show');
      if (trayPos && trayPos.x !== 0) {
        cachedBounds = trayPos;
      } else if (cachedBounds) {
        trayPos = cachedBounds;
      } else if (this.menubar.tray.getBounds) {
        trayPos = this.menubar.tray.getBounds();
      }
      noBoundsPosition = null;
      if ((trayPos === void 0 || trayPos.x === 0) && this.opts.windowPosition.substring(0, 4) === 'tray') {
        noBoundsPosition = (_ref = process.platform === 'win32') != null ? _ref : {
          'bottomRight': 'topRight'
        };
      }
      position = this.menubar.positioner.calculate(noBoundsPosition || this.opts.windowPosition, trayPos);
      if (this.opts.x !== void 0) {
        x = this.opts.x;
      } else {
        x = position.x;
      }
      if (this.opts.y !== void 0) {
        y = this.opts.y;
      } else {
        y = position.y;
      }
      this.menubar.window.setPosition(x, y);
      this.menubar.window.show();
      this.menubar.emit('after-show');
    };

    Menubar.prototype.hideWindow = function() {
      if (!this.menubar.window) {
        return;
      }
      this.menubar.emit('hide');
      this.menubar.window.hide();
      return this.menubar.emit('after-hide');
    };

    Menubar.prototype.windowClear = function() {
      delete this.menubar.window;
      return this.menubar.emit('after-close');
    };

    Menubar.prototype.emitBlur = function() {
      return this.menubar.emit('focus-lost');
    };

    Menubar.prototype.createWindow = function() {
      var defaults, winOpts;
      this.menubar.emit('create-window');
      defaults = {
        show: false,
        frame: false
      };
      winOpts = _.assign(defaults, this.opts);
      this.menubar.window = new BrowserWindow(winOpts);
      this.menubar.positioner = new Positioner(this.menubar.window);
      this.menubar.window.on('blur', (function(_this) {
        return function() {
          if (_this.opts.alwaysOnTop) {
            return _this.emitBlur();
          } else {
            return _this.hideWindow();
          }
        };
      })(this));
      if (this.opts.showOnAllWorkspaces !== false) {
        this.menubar.window.setVisibleOnAllWorkspaces(true);
      }
      this.menubar.window.on('close', (function(_this) {
        return function() {
          return _this.windowClear();
        };
      })(this));
      this.menubar.window.loadURL(this.opts.index);
      return this.menubar.emit('after-create-window');
    };

    return Menubar;

  })();

}).call(this);
