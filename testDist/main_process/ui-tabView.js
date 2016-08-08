(function() {
  var InvalidOperationException, InvalidParameterException, TabView, UIItem, _, _ref, _when,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  _ = require('lodash');

  _when = require('when');

  UIItem = require('./ui-item');

  _ref = require('./exceptions'), InvalidOperationException = _ref.InvalidOperationException, InvalidParameterException = _ref.InvalidParameterException;

  module.exports = TabView = (function(_super) {
    __extends(TabView, _super);

    TabView.prototype.TabGridView = null;

    TabView.prototype.gridSuffix = '_grid';

    function TabView(params) {
      if (params == null) {
        params = {};
      }
      this.TabGridView = params.TabGridView;
      TabView.__super__.constructor.call(this, params);
    }

    TabView.prototype.loadTabData = function() {
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
            _.forEach(data, function(v, k) {
              return _this.setTabData(v.name, v.data);
            });
            return resolve();
          };
          return _this.db.all(onAll);
        };
      })(this));
    };

    TabView.prototype.getTabData = function(tabName) {
      var findUIItem, index;
      findUIItem = _.find(this.children, {
        name: tabName + this.gridSuffix
      });
      index = _.indexOf(this.children, findUIItem);
      if (findUIItem != null) {
        return findUIItem.dataSource;
      }
    };

    TabView.prototype.getData = function() {
      var data;
      data = [];
      _.forEach(this.children, function(v, k) {
        return _.forEach(v.dataSource, function(v, k) {
          return data.push(v);
        });
      });
      return data;
    };

    TabView.prototype.save = function() {
      var async;
      chiika.logger.info("[red](" + this.name + ") Saving tab view data...");
      async = [];
      _.forEach(this.children, (function(_this) {
        return function(v, k) {
          var deferSave, onSaved;
          deferSave = _when.defer();
          async.push(deferSave.promise);
          onSaved = function() {
            return deferSave.resolve();
          };
          return _this.db.save({
            name: v.name,
            data: v.dataSource
          }, onSaved);
        };
      })(this));
      return _when.all(async);
    };

    TabView.prototype.setData = function(data) {
      if (_.isUndefined(data)) {
        throw new InvalidParameterException("You didn't specify data to be added.");
      }
      if (!_.isArray(data)) {
        throw new InvalidParameterException("Specified data has to be type of array.");
      }
      chiika.logger.info("Setting data source for " + this.name);
      this.dataSource = data;
      _.forEach(this.dataSource, (function(_this) {
        return function(v, k) {
          return _this.setTabData(v.name, v.data);
        };
      })(this));
      return this.save();
    };

    TabView.prototype.setTabData = function(tabName, data) {
      var checkName, childExists, findUIItem, index, uiItem;
      checkName = tabName.indexOf(this.gridSuffix);
      if (checkName === -1) {
        tabName += this.gridSuffix;
      }
      uiItem = new UIItem({
        name: tabName,
        displayName: tabName,
        displayType: 'grid'
      });
      if (_.isUndefined(data)) {
        throw new InvalidParameterException("You didn't specify data to be added.");
      }
      if (!_.isArray(data)) {
        throw new InvalidParameterException("Specified data has to be type of array.");
      }
      findUIItem = _.find(this.children, {
        name: tabName
      });
      index = _.indexOf(this.children, findUIItem);
      childExists = false;
      if (index !== -1) {
        _.forEach(this.children, (function(_this) {
          return function(v, k) {
            if (v.name === tabName) {
              childExists = true;
              chiika.logger.warn("You are trying to set data for an existing child item. Replacing data source instead. " + v.name + " vs " + tabName);
              findUIItem.setDataSource(data);
              _this.children.splice(index, 1, findUIItem);
              return false;
            }
          };
        })(this));
      }
      if (!childExists) {
        this.addChild(uiItem);
        return uiItem.setDataSource(data);
      }
    };

    return TabView;

  })(UIItem);

}).call(this);
