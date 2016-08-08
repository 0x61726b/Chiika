(function() {
  var SubView, TabView, UIItem, UIManager, _, _when;

  _ = require('lodash');

  _when = require('when');

  UIItem = require('./ui-item');

  TabView = require('./ui-tabView');

  SubView = require('./view-subview');

  module.exports = UIManager = (function() {
    function UIManager() {}

    UIManager.prototype.uiItems = [];

    UIManager.prototype.preloadPromises = [];

    UIManager.prototype.preloadUIItems = function() {
      var async, defer, script, scripts, _i, _len;
      chiika.logger.verbose("[magenta](UI-Manager) Preloading UI items..");
      defer = _when.defer();
      if (chiika.dbManager.uiDb.getUIItems().length === 0) {
        chiika.logger.warn("[magenta](UI-Manager) There are no UI items...Calling reconstruct event");
        scripts = chiika.apiManager.getScripts();
        async = [];
        for (_i = 0, _len = scripts.length; _i < _len; _i++) {
          script = scripts[_i];
          if (script.isActive) {
            defer = _when.defer();
            async.push(defer.promise);
            chiika.chiikaApi.emit('reconstruct-ui', {
              defer: defer,
              calling: script.name
            });
          }
        }
        return _when.all(async);
      } else {
        _.forEach(chiika.dbManager.uiDb.getUIItems(), (function(_this) {
          return function(v, k) {
            return _this.preloadPromises.push(_this.addOrUpdate(v, null, false));
          };
        })(this));
        return _when.all(this.preloadPromises);
      }
    };

    UIManager.prototype.checkUIData = function() {
      var async, requiresUpdate;
      requiresUpdate = [];
      _.forEach(this.uiItems, (function(_this) {
        return function(v, k) {
          var dataSource;
          dataSource = v.dataSource;
          if ((dataSource != null) && _.isEmpty(dataSource)) {
            v.needUpdate = true;
            return requiresUpdate.push(v);
          }
        };
      })(this));
      chiika.logger.info("" + requiresUpdate.length + " item is waiting to update!");
      async = [];
      requiresUpdate.map((function(_this) {
        return function(item, i) {
          return async.push(item.update());
        };
      })(this));
      return _when.all(async);
    };

    UIManager.prototype.addTabView = function(item) {
      var dbView, tabView;
      tabView = new TabView({
        name: item.name,
        displayName: item.displayName,
        TabGridView: item.TabGridView,
        owner: item.owner,
        category: item.category,
        displayType: item.displayType
      });
      dbView = chiika.dbManager.createViewDb(item.name);
      tabView.setDatabaseInterface(dbView);
      tabView.loadTabData();
      return tabView;
    };

    UIManager.prototype.addSubView = function(item) {
      var dbView, subview;
      subview = new SubView({
        name: item.name,
        displayName: item.displayName,
        displayType: item.displayType,
        owner: item.owner,
        category: 'not_display'
      });
      dbView = chiika.dbManager.createViewDb(item.name);
      subview.setDatabaseInterface(dbView);
      subview.load();
      return subview;
    };

    UIManager.prototype.addOrUpdate = function(item, callback, insert) {
      var defer, findView, index, tabView, view;
      if (insert == null) {
        insert = true;
      }
      defer = _when.defer();
      findView = _.find(this.uiItems, function(o) {
        return o.name === item.name;
      });
      index = _.indexOf(this.uiItems, findView);
      if (item.displayType === 'subview') {
        if (findView != null) {
          _.assign(findView, item);
          this.uiItems.splice(index, 1, findView);
        } else {
          view = this.addSubView(item);
          this.uiItems.push(view);
        }
      }
      if (item.displayType === 'TabGridView') {
        if (findView != null) {
          _.assign(findView, item);
          this.uiItems.splice(index, 1, findView);
        } else {
          tabView = this.addTabView(item);
          this.uiItems.push(tabView);
          this.preloadPromises.push(tabView.db.promise);
        }
      }
      if (insert) {
        chiika.dbManager.uiDb.addOrUpdate(item, (function(_this) {
          return function(error) {
            if (error) {
              chiika.logger.error(error);
            }
            defer.resolve();
            return typeof callback === "function" ? callback(error) : void 0;
          };
        })(this));
      } else {
        defer.resolve();
      }
      return defer.promise;
    };

    UIManager.prototype.getUIItem = function(itemName) {
      var instance;
      instance = _.find(this.uiItems, {
        name: itemName
      });
      if (instance != null) {
        return instance;
      } else {
        chiika.logger.error("getUIItem UI item not found " + itemName);
        return null;
      }
    };

    UIManager.prototype.getUIItemsCount = function() {
      return chiika.dbManager.uiDb.uiData.length;
    };

    UIManager.prototype.getUIItems = function() {
      return this.uiItems;
    };

    UIManager.prototype.removeUIItem = function(item) {
      var index, match;
      match = _.find(uiItems, item);
      index = _.indexOf(uiItems, match);
      if (match != null) {
        this.uiItems.splice(index, 1, match);
        return chiika.logger.verbose("[magenta](UI-Manager) Removed a UI Item " + item.name);
      }
    };

    return UIManager;

  })();

}).call(this);
