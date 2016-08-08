(function() {
  var DbUI, IDb, InvalidParameterException, _, _when,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  IDb = require('./db-interface');

  _ = require('lodash');

  _when = require('when');

  InvalidParameterException = require('./exceptions').InvalidParameterException;

  module.exports = DbUI = (function(_super) {
    __extends(DbUI, _super);

    function DbUI(params) {
      var defer, loadDatabase, onAll;
      if (params == null) {
        params = {};
      }
      this.name = 'UI';
      defer = _when.defer();
      params.promises.push(defer.promise);
      DbUI.__super__.constructor.call(this, {
        dbName: this.name,
        promises: params.promises
      });
      onAll = (function(_this) {
        return function(data) {
          _this.uiData = data;
          chiika.logger.debug("[yellow](Database) " + _this.name + " loaded. Data Count " + _this.uiData.length + " ");
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

    DbUI.prototype.addOrUpdate = function(menuItem, callback) {
      var onInsertOrUpdate, onWrongViewStructure;
      onWrongViewStructure = function(error) {
        if (typeof callback === "function") {
          callback(error);
        }
        return chiika.logger.error(error);
      };
      if (menuItem.name == null) {
        onWrongViewStructure('UI Item must have a name property');
        return;
      }
      if (menuItem.displayName == null) {
        onWrongViewStructure('UI Item must have a displayName property');
        return;
      }
      if (menuItem.displayType == null) {
        onWrongViewStructure('UI Item must have a displayType property');
        return;
      }
      if (menuItem[menuItem.displayType] == null) {
        onWrongViewStructure("UI Item must have a " + menuItem.displayType + " property");
        return;
      }
      onInsertOrUpdate = (function(_this) {
        return function(insert, update) {
          var findItem, index;
          if (insert != null) {
            _this.uiData.push(menuItem);
          }
          if (update != null) {
            findItem = _.find(_this.uiData, function(o) {
              return o.name === menuItem.name;
            });
            index = _.indexOf(_this.uiData, findItem);
            if (findItem != null) {
              _this.uiData.splice(index, 1, findItem);
            } else {
              chiika.logger.error("There was an update op but the local array doesn't have the entry.");
            }
          }
          return typeof callback === "function" ? callback() : void 0;
        };
      })(this);
      return this.insertRecord(menuItem, (function(_this) {
        return function(result) {
          if (result.exists) {
            return _this.updateRecords(menuItem, function() {
              return typeof onInsertOrUpdate === "function" ? onInsertOrUpdate(null, true) : void 0;
            });
          } else {
            return typeof onInsertOrUpdate === "function" ? onInsertOrUpdate(true, null) : void 0;
          }
        };
      })(this));
    };

    DbUI.prototype.getUIItem = function(name, callback) {
      return this.one('name', name, null).then((function(_this) {
        return function(data) {
          return callback(data);
        };
      })(this));
    };

    DbUI.prototype.getUIItemSync = function(name) {
      return _.find(this.uiData, function(o) {
        return o.name === name;
      });
    };

    DbUI.prototype.getUIItemsAsync = function(callback) {
      var onAll;
      onAll = function(data) {
        return typeof callback === "function" ? callback(data) : void 0;
      };
      return this.all(onAll);
    };

    DbUI.prototype.getUIItems = function() {
      return this.uiData;
    };

    return DbUI;

  })(IDb);

}).call(this);
