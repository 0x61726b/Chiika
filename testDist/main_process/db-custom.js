(function() {
  var DbCustom, IDb, InvalidParameterException, _, _when,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  IDb = require('./db-interface');

  InvalidParameterException = require('./exceptions').InvalidParameterException;

  _ = require('lodash');

  _when = require('when');

  module.exports = DbCustom = (function(_super) {
    __extends(DbCustom, _super);

    function DbCustom(params) {
      var defer, loadDatabase, onAll;
      if (params == null) {
        params = {};
      }
      this.name = 'Custom';
      defer = _when.defer();
      params.promises.push(defer.promise);
      DbCustom.__super__.constructor.call(this, {
        dbName: this.name,
        promises: params.promises
      });
      onAll = (function(_this) {
        return function(data) {
          _this.keys = data;
          chiika.logger.debug("[yellow](Database) " + _this.name + " loaded. Data Count " + _this.keys.length + " ");
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

    DbCustom.prototype.getKey = function(name) {
      var match;
      match = _.find(this.keys, {
        name: name
      });
      if (_.isUndefined(match)) {
        chiika.logger.warn("The key " + name + " you are trying to access doesn't exist.");
        return void 0;
      } else {
        return match;
      }
    };

    DbCustom.prototype.addKey = function(object, callback) {
      var onInsertComplete, onInsertOrUpdate;
      onInsertOrUpdate = (function(_this) {
        return function(insert, update) {
          var findItem, index;
          if (insert != null) {
            _this.keys.push(object);
          }
          if (update != null) {
            findItem = _.find(_this.keys, function(o) {
              return o.name === object.name;
            });
            index = _.indexOf(_this.keys, findItem);
            if (findItem != null) {
              _this.keys.splice(index, 1, findItem);
            } else {
              chiika.logger.error("There was an update op but the local array doesn't have the entry.");
            }
          }
          return typeof callback === "function" ? callback() : void 0;
        };
      })(this);
      onInsertComplete = (function(_this) {
        return function(result) {
          if (result.exists) {
            return _this.updateRecords(object, function() {
              return typeof onInsertOrUpdate === "function" ? onInsertOrUpdate(null, true) : void 0;
            });
          } else {
            return typeof onInsertOrUpdate === "function" ? onInsertOrUpdate(true, null) : void 0;
          }
        };
      })(this);
      return this.insertRecord(object, onInsertComplete);
    };

    DbCustom.prototype.updateKeys = function(object, callback) {
      if (!_.isUndefined(callback)) {
        return this.updateRecords(object, callback);
      } else {
        return this.updateRecords(object, function() {});
      }
    };

    DbCustom.prototype.removeKey = function(object, callback) {
      return this.removeRecords(object, callback);
    };

    return DbCustom;

  })(IDb);

}).call(this);
