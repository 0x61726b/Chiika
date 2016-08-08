(function() {
  var ChiikaPublicApi, Emitter, InvalidParameterException, _,
    __slice = [].slice;

  Emitter = require('event-kit').Emitter;

  InvalidParameterException = require('./exceptions').InvalidParameterException;

  _ = require('lodash');

  module.exports = ChiikaPublicApi = (function() {
    ChiikaPublicApi.prototype.emitter = null;

    ChiikaPublicApi.prototype.subscriptions = [];

    function ChiikaPublicApi(params) {
      if (params == null) {
        params = {};
      }
      this.emitter = new Emitter;
      this.logger = params.logger, this.db = params.db, this.parser = params.parser, this.ui = params.ui;
      this.users = this.db.usersDb;
      this.custom = this.db.customDb;
      this.uiDb = this.db.uiDb;
      this.utility = chiika.utility;
    }

    ChiikaPublicApi.prototype.makeGetRequest = function(url, headers, callback) {
      if (_.isUndefined(callback)) {
        throw new InvalidParameterException("You have to supply a callback to 'makeGetRequest' method.");
      }
      return chiika.requestManager.makeGetRequest(url, headers, callback);
    };

    ChiikaPublicApi.prototype.makePostRequest = function(url, headers, callback) {
      if (_.isUndefined(callback)) {
        throw new InvalidParameterException("You have to supply a callback to 'makePostRequest' method.");
      }
      return chiika.requestManager.makePostRequest(url, headers, callback);
    };

    ChiikaPublicApi.prototype.makeGetRequestAuth = function(url, user, headers, callback) {
      if (_.isUndefined(callback)) {
        throw new InvalidParameterException("You have to supply a callback to 'makeGetRequestAuth' method.");
      }
      return chiika.requestManager.makeGetRequestAuth(url, user, headers, callback);
    };

    ChiikaPublicApi.prototype.makePostRequestAuth = function(url, user, headers, callback) {
      if (_.isUndefined(callback)) {
        throw new InvalidParameterException("You have to supply a callback to 'makePostRequestAuth' method.");
      }
      return chiika.requestManager.makePostRequestAuth(url, user, headers, callback);
    };

    ChiikaPublicApi.prototype.sendMessageToWindow = function(windowName, message, args) {
      var wnd;
      wnd = chiika.windowManager.getWindowByName(windowName);
      if (!_.isUndefined(wnd)) {
        return wnd.webContents.send(message, args);
      }
    };

    ChiikaPublicApi.prototype.requestViewUpdate = function(viewName, owner, defer, params) {
      var view;
      if (params == null) {
        params = {};
      }
      if (_.isUndefined(params)) {
        params = {};
      }
      view = chiika.uiManager.getUIItem(viewName);
      if (view != null) {
        return this.emit('view-update', {
          calling: owner,
          view: view,
          defer: defer,
          params: params
        });
      } else {
        return chiika.logger.error("Can't update a non-existent view.");
      }
    };

    ChiikaPublicApi.prototype.createWindow = function(options, returnCall) {
      options.name += 'modal';
      return chiika.windowManager.createModalWindow(options, returnCall);
    };

    ChiikaPublicApi.prototype.closeWindow = function(windowName) {
      var wnd;
      wnd = chiika.windowManager.getWindowByName(windowName);
      if (!_.isUndefined(wnd)) {
        return wnd.close();
      }
    };

    ChiikaPublicApi.prototype.executeJavaScript = function(windowName, javascript) {
      var wnd;
      wnd = chiika.windowManager.getWindowByName(windowName);
      if (!_.isUndefined(wnd)) {
        return wnd.webContents.executeJavaScript(javascript);
      }
    };

    ChiikaPublicApi.prototype.on = function(receiver, message, callback) {
      return this.emitter.on(message, (function(_this) {
        return function(args) {
          var script;
          if (_.isUndefined(args.calling)) {
            console.log("" + receiver + " - " + message);
            chiika.logger.error("Emitter has received " + message + " but we don't know who to call to " + receiver + " != " + args.calling + ". Are you sure about this?");
            callback(args);
          }
          if (args.calling === receiver) {
            script = chiika.apiManager.getScriptByName(receiver);
            if (script != null) {
              if (script.isActive) {
                return callback(args);
              } else {
                return chiika.logger.warn("Skipping " + receiver + " - " + message + " because " + receiver + " is not active.");
              }
            }
          }
        };
      })(this));
    };

    ChiikaPublicApi.prototype.emit = function(message, args) {
      chiika.logger.debug("Emitting " + message + " to " + args.calling);
      return this.emitter.emit(message, args);
    };

    ChiikaPublicApi.prototype.dispatch = function() {
      var args, handler, _ref;
      handler = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return (_ref = this.emitter.constructor).dispatch.apply(_ref, [handler].concat(__slice.call(args)));
    };

    ChiikaPublicApi.prototype.emitTo = function() {
      var args, message, receiver, _ref;
      receiver = arguments[0], message = arguments[1], args = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
      return (_ref = this.emitter).emit.apply(_ref, [message].concat(__slice.call(args)));
    };

    return ChiikaPublicApi;

  })();

}).call(this);
