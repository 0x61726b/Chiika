(function() {
  var React, ViewManager, _;

  React = require('react');

  _ = require('lodash');

  module.exports = ViewManager = (function() {
    function ViewManager() {}

    ViewManager.prototype.tabViewTabIndexCounter = [];

    ViewManager.prototype.scrollData = [];

    ViewManager.prototype.getComponent = function(name) {
      if (name === 'TabGridView') {
        return './view-tabGrid';
      }
    };

    ViewManager.prototype.onTabSelect = function(viewName, index, last) {
      this.tabViewTabIndexCounter[viewName] = {
        index: index
      };
      if (this.scrollData[viewName] != null) {
        return this.scrollData[viewName].scrollData[last] = $(".objbox").scrollTop();
      } else {
        this.scrollData[viewName] = {
          scrollData: {}
        };
        return this.scrollData[viewName].scrollData[last] = $(".objbox").scrollTop();
      }
    };

    ViewManager.prototype.onTabViewUnmount = function(viewName, index) {
      this.tabViewTabIndexCounter[viewName] = {
        index: index
      };
      if (this.scrollData[viewName] != null) {
        return this.scrollData[viewName].scrollData[index] = $(".objbox").scrollTop();
      }
    };

    ViewManager.prototype.getTabScrollAmount = function(viewName, index) {
      var scroll;
      if (this.scrollData[viewName] != null) {
        scroll = this.scrollData[viewName].scrollData[index];
        if (scroll != null) {
          return scroll;
        } else {
          return 0;
        }
      } else {
        return 0;
      }
    };

    ViewManager.prototype.getTabSelectedIndexByName = function(viewName) {
      var v;
      v = this.tabViewTabIndexCounter[viewName];
      if (v != null) {
        return v;
      } else {
        return {
          index: 0
        };
      }
    };

    return ViewManager;

  })();

}).call(this);
