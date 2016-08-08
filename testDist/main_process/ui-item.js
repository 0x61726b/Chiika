(function() {
  var UIItem, _, _when;

  _ = require('lodash');

  _when = require('when');

  module.exports = UIItem = (function() {
    UIItem.prototype.name = null;

    UIItem.prototype.displayName = null;

    UIItem.prototype.dataSource = [];

    UIItem.prototype.db = null;

    UIItem.prototype.displayType = null;

    UIItem.prototype.needUpdate = false;

    UIItem.prototype.children = [];

    function UIItem(params) {
      if (params == null) {
        params = {};
      }
      this.name = params.name, this.displayName = params.displayName, this.displayType = params.displayType, this.owner = params.owner, this.category = params.category;
      this.children = [];
      this.needUpdate = false;
      this.dataSource = [];
    }

    UIItem.prototype.addChild = function(child) {
      if (child != null) {
        return this.children.push(child);
      }
    };

    UIItem.prototype.setDatabaseInterface = function(db) {
      return this.db = db;
    };

    UIItem.prototype.update = function() {
      var defer;
      chiika.logger.info("Updating UIItem " + this.name);
      defer = _when.defer();
      if (this.needUpdate) {
        if (this.owner != null) {
          chiika.chiikaApi.emit('view-update', {
            calling: this.owner,
            view: this,
            defer: defer,
            params: {}
          });
        } else {
          chiika.logger.error("Can't update an item without owner! UI Item: " + this.name);
          defer.resolve({
            success: false
          });
        }
        this.needUpdate = false;
      } else {
        defer.resolve({
          success: true
        });
      }
      return defer.promise;
    };

    UIItem.prototype.setDataSource = function(data) {
      if (_.isUndefined(data)) {
        chiika.logger.warn("[magenta](" + this.name + ") - Undefined data source!");
      }
      if (!_.isArray(data)) {
        chiika.logger.error("[magenta](" + this.name + ") - Non-array data source!");
        return;
      }
      chiika.logger.verbose("Setting data source for UI item " + this.name + ". Data Array Length: " + data.length);
      return this.dataSource = data;
    };

    return UIItem;

  })();

}).call(this);
