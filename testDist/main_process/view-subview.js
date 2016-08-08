(function() {
  var InvalidOperationException, InvalidParameterException, SubView, UIItem, _, _ref, _when,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  _ = require('lodash');

  _when = require('when');

  UIItem = require('./ui-item');

  _ref = require('./exceptions'), InvalidOperationException = _ref.InvalidOperationException, InvalidParameterException = _ref.InvalidParameterException;

  module.exports = SubView = (function(_super) {
    __extends(SubView, _super);

    function SubView(params) {
      if (params == null) {
        params = {};
      }
      SubView.__super__.constructor.call(this, params);
    }

    SubView.prototype.load = function() {
      return new Promise((function(_this) {
        return function(resolve) {
          var onAll;
          onAll = function(data) {
            var L;
            L = data.length;
            if (L === 0) {
              _this.needUpdate = true;
            } else {
              _this.setDataSource(data);
            }
            return resolve();
          };
          return _this.db.all(onAll);
        };
      })(this));
    };

    SubView.prototype.getData = function() {
      return this.dataSource;
    };

    SubView.prototype.setData = function(data, key) {
      return new Promise((function(_this) {
        return function(resolve) {
          var find, index, onSaved;
          if (_.isUndefined(data)) {
            throw new InvalidParameterException("You didn't specify data to be added.");
          }
          chiika.logger.info("Adding a new row for " + _this.name);
          find = _.find(_this.dataSource, function(o) {
            return o[key] === data[key];
          });
          index = _.indexOf(_this.dataSource, find);
          if (find != null) {
            _this.dataSource.splice(index, 1, data);
          } else {
            _this.dataSource.push(data);
          }
          onSaved = function(args) {
            return resolve(args);
          };
          return _this.db.save(data, onSaved);
        };
      })(this));
    };

    return SubView;

  })(UIItem);

}).call(this);
