(function() {
  var BrowserWindow, ChiikaIPC, Emitter, fs, ipcRenderer, path, remote, _, _ref, _when,
    __slice = [].slice;

  Emitter = require('event-kit').Emitter;

  _ref = require('electron'), BrowserWindow = _ref.BrowserWindow, ipcRenderer = _ref.ipcRenderer, remote = _ref.remote;

  _ = require('lodash');

  fs = require('fs');

  path = require('path');

  _when = require('when');

  module.exports = ChiikaIPC = (function() {
    ChiikaIPC.prototype.preloadPromises = [];

    function ChiikaIPC() {}

    ChiikaIPC.prototype.preload = function() {
      return _when.all(this.preloadPromises).then((function(_this) {
        return function() {
          return _this.sendMessage('ui-init-complete');
        };
      })(this));
    };

    ChiikaIPC.prototype.refreshUIData = function(callback) {
      return this.receive('get-ui-data-response', (function(_this) {
        return function(event, args) {
          return callback(args);
        };
      })(this));
    };

    ChiikaIPC.prototype.getUIData = function() {
      return this.preloadPromises.push(this.sendReceiveIPC('get-ui-data', {}, (function(_this) {
        return function(event, defer, args) {
          defer.resolve();
          return console.log(args);
        };
      })(this)));
    };

    ChiikaIPC.prototype.getUsers = function() {
      return this.preloadPromises.push(this.sendReceiveIPC('get-user-data', {}, (function(_this) {
        return function(event, defer, args) {
          defer.resolve();
          return console.log(args);
        };
      })(this)));
    };

    ChiikaIPC.prototype.getDetailsLayout = function(id, owner, callback) {
      var disposable;
      this.sendMessage('details-layout-request', {
        id: id,
        owner: owner
      });
      return disposable = this.receive('details-layout-request-response', (function(_this) {
        return function(event, args) {
          return callback(args);
        };
      })(this));
    };

    ChiikaIPC.prototype.refreshViewByName = function(name) {
      return this.sendReceiveIPC('refresh-view-by-name', name, (function(_this) {
        return function(event, args, defer) {
          return console.log("refresh-view-by-name hello");
        };
      })(this));
    };

    ChiikaIPC.prototype.openLoginWindow = function() {
      return this.sendMessage('window-method', {
        method: 'show',
        window: 'login'
      });
    };

    ChiikaIPC.prototype.reconstructUI = function() {
      return this.sendMessage('reconstruct-ui');
    };

    ChiikaIPC.prototype.onReconstructUI = function() {
      return this.receive('reconstruct-ui-response', (function(_this) {
        return function(event, args) {
          return chiika.reInitializeUI();
        };
      })(this));
    };

    ChiikaIPC.prototype.disposeListeners = function(channel) {
      return ipcRenderer.removeAllListeners(channel);
    };

    ChiikaIPC.prototype.sendMessage = function(message, args) {
      chiika.logger.renderer("Sending " + message);
      return ipcRenderer.send(message, args);
    };

    ChiikaIPC.prototype.receive = function(message, callback) {
      return ipcRenderer.on(message, (function(_this) {
        return function() {
          var args, event;
          event = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
          chiika.logger.info("[blue](RENDERER) Receiving " + message);
          return callback.apply(null, [event].concat(__slice.call(args)));
        };
      })(this));
    };

    ChiikaIPC.prototype.sendReceiveIPC = function(message, params, callback) {
      var defer;
      defer = _when.defer();
      chiika.logger.info("[red](RENDERER) Sending " + message);
      ipcRenderer.send(message, params);
      ipcRenderer.on(message + "-response", (function(_this) {
        return function() {
          var args, event;
          event = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
          chiika.logger.info("[blue](RENDERER) Receiving " + message + "-response");
          return callback.apply(null, [event, defer].concat(__slice.call(args)));
        };
      })(this));
      return defer.promise;
    };

    return ChiikaIPC;

  })();

}).call(this);
