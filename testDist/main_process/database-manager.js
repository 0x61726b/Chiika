(function() {
  var DatabaseManager, DbCustom, DbUI, DbUsers, DbView, Emitter, path, _, _when,
    __slice = [].slice;

  path = require('path');

  DbUsers = require('./db-users');

  DbCustom = require('./db-custom');

  DbUI = require('./db-ui');

  DbView = require('./db-view');

  Emitter = require('event-kit').Emitter;

  _ = require('lodash');

  _when = require('when');

  module.exports = DatabaseManager = (function() {
    DatabaseManager.prototype.usersDb = null;

    DatabaseManager.prototype.emitter = null;

    DatabaseManager.prototype.promises = [];

    DatabaseManager.prototype.instances = [];

    function DatabaseManager() {
      this.emitter = new Emitter;
      global.dbManager = this;
      this.usersDb = new DbUsers({
        promises: this.promises
      });
      this.customDb = new DbCustom({
        promises: this.promises
      });
      this.uiDb = new DbUI({
        promises: this.promises
      });
    }

    DatabaseManager.prototype.onLoad = function(callback) {
      return _when.all(this.promises).then((function(_this) {
        return function() {
          return callback();
        };
      })(this));
    };

    DatabaseManager.prototype.createViewDb = function(viewName) {
      var dbView, instance;
      instance = _.find(this.instances, {
        viewName: viewName
      });
      if (instance != null) {
        chiika.logger.info("[magenta](Database-Manager) Returning existing database instance for view " + viewName);
        return instance;
      } else {
        chiika.logger.info("[magenta](Database-Manager) Loading new database instance for view " + viewName);
        dbView = new DbView({
          viewName: viewName
        });
        this.instances.push({
          viewName: viewName,
          instance: dbView
        });
        return dbView;
      }
    };

    DatabaseManager.prototype.emit = function(message) {
      return this.emitter.emit(message);
    };

    DatabaseManager.prototype.on = function() {
      var args, message, _ref;
      message = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return (_ref = this.emitter).on.apply(_ref, [message].concat(__slice.call(args)));
    };

    return DatabaseManager;

  })();

}).call(this);
