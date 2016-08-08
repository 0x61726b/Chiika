(function() {
  var Emitter, IDb, InvalidParameterException, NoSQL, colors, path, _, _when,
    __slice = [].slice;

  NoSQL = require('nosql');

  path = require('path');

  _ = require('lodash');

  _when = require('when');

  colors = require('colors');

  Emitter = require('event-kit').Emitter;

  InvalidParameterException = require('./exceptions').InvalidParameterException;

  module.exports = IDb = (function() {
    IDb.prototype.nosql = null;

    IDb.prototype.promise = null;

    function IDb(params) {
      var defer, promises;
      if (params == null) {
        params = {};
      }
      this.dbName = params.dbName, promises = params.promises;
      if (promises != null) {
        defer = _when.defer();
        this.promise = defer.promise;
        promises.push(this.promise);
      }
      this.dbPhysicalPath = path.join(chiika.getDbHome(), this.dbName + ".nosql");
      this.nosql = NoSQL.load(path.join(chiika.getDbHome(), this.dbName + ".nosql"));
      chiika.logger.debug("IDb::constructor {dbName:" + this.dbName + "}");
      chiika.logger.debug("Idb::constructor {dbPhysicalPath:" + this.dbPhysicalPath + "}");
      this.on('load', function() {
        if (promises != null) {
          return defer.resolve();
        }
      });
    }

    IDb.prototype.all = function(callback) {
      return new Promise((function(_this) {
        return function(resolve) {
          var icall, map;
          chiika.logger.debug("IDb::all");
          map = function(doc) {
            return doc;
          };
          icall = function(err, selected) {
            if (err) {
              throw err;
            }
            callback(selected);
            return resolve(selected);
          };
          return _this.nosql.all(map, icall);
        };
      })(this));
    };

    IDb.prototype.one = function(key, value, callback) {
      return new Promise((function(_this) {
        return function(resolve) {
          var map, onOne;
          chiika.logger.debug("IDb::one");
          map = function(doc) {
            if (doc[key] === value) {
              return doc;
            }
          };
          onOne = function(err, doc) {
            if (err) {
              throw err;
              chiika.logger.error(err);
            }
            chiika.logger.debug("Idb::onOne");
            return resolve(doc);
          };
          return _this.nosql.one(map, onOne);
        };
      })(this));
    };

    IDb.prototype.internalInsertRecord = function(record, callback) {
      var onInsert;
      onInsert = function(err, count) {
        if (err) {
          throw err;
        }
        return chiika.logger.debug("Idb::onInsertComplete " + count);
      };
      this.nosql.insert(record, onInsert, 'IDb::insertRecord');
      return chiika.logger.debug("IDb::internalInsertRecord");
    };

    IDb.prototype.insertRecord = function(record, callback) {
      var key, keys, onKeyExistsCheck;
      chiika.logger.debug("Idb::insertRecord");
      keys = Object.keys(record);
      key = keys[0];
      onKeyExistsCheck = (function(_this) {
        return function(exists) {
          if (!exists.exists) {
            _this.internalInsertRecord(record, callback);
            chiika.logger.verbose("[magenta](" + _this.name + ") - Added new record " + key + ":" + record[key]);
            return callback({
              exists: exists.exists
            });
          } else {
            chiika.logger.verbose("[magenta](" + _this.name + ") - Key-value already exists " + key + ":" + record[key] + ". No need to insert, if you meant to update, use update method.");
            return callback({
              exists: exists.exists
            });
          }
        };
      })(this);
      return this.checkIfKeyValueExists(record, onKeyExistsCheck);
    };

    IDb.prototype.updateRecords = function(record, callback) {
      var affectedRows, updateCallback, updateFnc;
      chiika.logger.debug("IDb::updateRecord");
      affectedRows = 0;
      updateFnc = (function(_this) {
        return function(doc) {
          var key, keys, keysRecord;
          keys = Object.keys(doc);
          keysRecord = Object.keys(record);
          key = Object.keys(doc)[0];
          if (key === Object.keys(record)[0] && record[key] === doc[key]) {
            _.forOwn(record, function(v, k) {
              return doc[k] = v;
            });
            affectedRows++;
          }
          return doc;
        };
      })(this);
      updateCallback = (function(_this) {
        return function(err, count) {
          if (err) {
            chiika.logger.error(err);
            throw err;
          }
          if (count > 0) {
            chiika.logger.verbose("[magenta](" + _this.name + ") - Updated - " + count + " ");
          }
          return callback({
            rows: count
          });
        };
      })(this);
      this.nosql.update(updateFnc, updateCallback, 'IDb::updateRecord');
      return chiika.logger.debug("IDb::updateRecord");
    };

    IDb.prototype.removeRecords = function(record, callback) {
      var removeCallback, removeFnc;
      chiika.logger.debug("IDb::removeRecord");
      removeFnc = function(doc) {
        var key, removeThisRecord;
        key = Object.keys(doc)[0];
        removeThisRecord = false;
        if (!_.isArray(record)) {
          throw new InvalidParameterException("You have to supply array of keys.");
        } else {
          _.forEach(record, function(o) {
            var firstKey;
            firstKey = Object.keys(o)[0];
            if (firstKey === key && o[key] === doc[key]) {
              removeThisRecord = true;
              return false;
            }
          });
        }
        return removeThisRecord;
      };
      removeCallback = function(err, count) {
        return chiika.logger.verbose("[magenta](" + this.name + ") - Removed keys - " + count);
      };
      return this.nosql.remove(removeFnc, removeCallback, "Remove records");
    };

    IDb.prototype.checkIfKeyValueExists = function(key, callback) {
      var onAll;
      onAll = (function(_this) {
        return function(data) {
          var exists;
          exists = false;
          _.forEach(data, function(v, k) {
            var firstKey;
            firstKey = Object.keys(v)[0];
            if (firstKey === Object.keys(key)[0] && v[firstKey] === key[firstKey]) {
              exists = true;
              return false;
            }
          });
          return callback({
            exists: exists
          });
        };
      })(this);
      return this.all(onAll);
    };

    IDb.prototype.on = function() {
      var args, event, _ref;
      event = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return (_ref = this.nosql).on.apply(_ref, [event].concat(__slice.call(args)));
    };

    IDb.prototype.isReady = function() {
      return this.nosql.isReady;
    };

    return IDb;

  })();

}).call(this);
