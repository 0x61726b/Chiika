(function() {
  var DbView, IDb, InvalidParameterException, _, _when,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  IDb = require('./db-interface');

  _ = require('lodash');

  _when = require('when');

  InvalidParameterException = require('./exceptions').InvalidParameterException;

  module.exports = DbView = (function(_super) {
    __extends(DbView, _super);

    function DbView(params) {
      var defer, loadDatabase, onAll;
      if (params == null) {
        params = {};
      }
      this.name = 'View_' + params.viewName;
      defer = _when.defer();
      this.promise = defer.promise;
      DbView.__super__.constructor.call(this, {
        dbName: this.name,
        params: params
      });
      onAll = (function(_this) {
        return function(data) {
          _this.views = data;
          chiika.logger.debug("[yellow](Database) " + _this.name + " loaded. Data Count " + _this.views.length + " ");
          chiika.logger.info("[yellow](Database) " + _this.name + " has been succesfully loaded.");
          return defer.resolve();
        };
      })(this);
      loadDatabase = (function(_this) {
        return function() {
          return _this.all(onAll);
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

    DbView.prototype.save = function(data, callback) {
      var saveData;
      saveData = (function(_this) {
        return function(data) {
          return _this.insertRecord(data, function(result) {
            if (result.exists) {
              return _this.updateRecords(data, function(args) {
                if (!_.isUndefined(callback)) {
                  return callback(args);
                }
              });
            } else {
              return callback({
                rows: 1
              });
            }
          });
        };
      })(this);
      if (!this.isReady()) {
        return this.on('load', (function(_this) {
          return function() {
            return saveData(data);
          };
        })(this));
      } else {
        return saveData(data);
      }
    };

    return DbView;

  })(IDb);

}).call(this);
