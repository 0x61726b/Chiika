(function() {
  var ApplicationWindow,
    __slice = [].slice;

  module.exports = ApplicationWindow = (function() {
    ApplicationWindow.prototype.window = null;

    function ApplicationWindow(path, options) {
      this.window = new BrowserWindow(options);
      this.window.loadURL(path);
      this.window.on('closed', (function(_this) {
        return function() {
          return _this.window = null;
        };
      })(this));
    }

    ApplicationWindow.prototype.getWindow = function() {
      return this.window;
    };

    ApplicationWindow.prototype.on = function() {
      var args, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return (_ref = this.window).on.apply(_ref, args);
    };

    ApplicationWindow.prototype.openDevTools = function() {
      return this.window.openDevTools();
    };

    ApplicationWindow.prototype.enableReactDevTools = function() {};

    ApplicationWindow.prototype.loadURL = function(url) {
      return this.window.loadURL(url);
    };

    ApplicationWindow.prototype.getPosition = function() {
      return this.window.getPosition();
    };

    ApplicationWindow.prototype.getSize = function() {
      return this.window.getSize();
    };

    ApplicationWindow.prototype.showWindow = function() {
      return this.window.show();
    };

    return ApplicationWindow;

  })();

}).call(this);
