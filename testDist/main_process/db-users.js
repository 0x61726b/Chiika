(function() {
  var DbUsers, IDb, InvalidParameterException, _, _when,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  IDb = require('./db-interface');

  _ = require('lodash');

  _when = require('when');

  InvalidParameterException = require('./exceptions').InvalidParameterException;

  module.exports = DbUsers = (function(_super) {
    __extends(DbUsers, _super);

    function DbUsers(params) {
      var defer, loadDatabase, onAll;
      if (params == null) {
        params = {};
      }
      this.name = 'Users';
      defer = _when.defer();
      params.promises.push(defer.promise);
      DbUsers.__super__.constructor.call(this, {
        dbName: this.name,
        promises: params.promises
      });
      onAll = (function(_this) {
        return function(data) {
          _this.users = data;
          chiika.logger.debug("[yellow](Database) " + _this.name + " loaded. Data Count " + _this.users.length + " ");
          return chiika.logger.info("[yellow](Database) " + _this.name + " has been succesfully loaded.");
        };
      })(this);
      loadDatabase = (function(_this) {
        return function() {
          return _this.all(onAll).then(function() {
            return defer.resolve();
          });
        };
      })(this);
      if (this.isReady()) {
        loadDatabase();
      } else {
        this.on('load', (function(_this) {
          return function() {
            return loadDatabase();
          };
        })(this));
      }
    }

    DbUsers.prototype.getDefaultUser = function(owner) {
      var match;
      match = _.find(this.users, {
        owner: owner
      });
      if (_.isUndefined(match)) {
        return chiika.logger.warn("Default user for " + owner + " does not exist.");
      } else {
        return match;
      }
    };

    DbUsers.prototype.getUser = function(userName) {
      var match;
      match = _.find(this.users, {
        userName: userName
      });
      if (_.isUndefined(match)) {
        chiika.logger.warn("The user " + userName + " you are trying to access doesn't exist.");
        return match;
      } else {
        return match;
      }
    };

    DbUsers.prototype.addUser = function(user, callback) {
      return this.insertRecord(user, (function(_this) {
        return function() {
          _this.users.push(user);
          if (!_.isUndefined(callback)) {
            return callback(user);
          }
        };
      })(this));
    };

    DbUsers.prototype.updateUser = function(user, callback) {
      var onUpdateComplete;
      onUpdateComplete = function(result) {
        if (!_.isUndefined(callback)) {
          return callback();
        }
      };
      return this.updateRecords(user, onUpdateComplete, 1);
    };

    DbUsers.prototype.removeUser = function(user, callback) {
      var onUpdateComplete;
      onUpdateComplete = function(result) {
        if (!_.isUndefined(callback)) {
          return callback();
        }
      };
      return this.removeRecords(user, onUpdateComplete, 1);
    };

    return DbUsers;

  })(IDb);

}).call(this);
