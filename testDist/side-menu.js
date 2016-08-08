(function() {
  var BrowserHistory, BrowserWindow, Link, React, Route, Router, SideMenu, ipcRenderer, path, remote, _, _ref, _ref1;

  React = require('react');

  _ref = require('react-router'), Router = _ref.Router, Route = _ref.Route, BrowserHistory = _ref.BrowserHistory, Link = _ref.Link;

  _ref1 = require('electron'), BrowserWindow = _ref1.BrowserWindow, ipcRenderer = _ref1.ipcRenderer, remote = _ref1.remote;

  _ = require('lodash');

  path = require('path');

  SideMenu = React.createClass({
    menuItemsSet: false,
    isPendingUiItems: false,
    requiresRefresh: true,
    getInitialState: function() {
      return {
        uiItems: [],
        categories: []
      };
    },
    componentWillMount: function() {
      return chiika.ipc.refreshUIData((function(_this) {
        return function(args) {
          return _this.refreshSideMenu(args);
        };
      })(this));
    },
    componentDidMount: function() {
      var requiresRefresh;
      this.refreshSideMenu(chiika.uiData);
      if (requiresRefresh) {
        this.refreshSideMenu(chiika.uiData);
        return requiresRefresh = false;
      }
    },
    componentDidUpdate: function() {},
    refreshSideMenu: function(menuItems) {
      var requiresRefresh;
      if (this.requiresRefresh) {
        chiika.logger.renderer("SideMenu requires refresh!");
        this.state.uiItems = [];
        this.state.categories = [];
        chiika.logger.renderer("SideMenu::refreshSideMenu");
        this.pendingUiItems = [];
        this.pendingCategories = [];
        _.forEach(menuItems, (function(_this) {
          return function(v, k) {
            if (v.displayType === 'TabGridView' && v.children.length === 0) {
              return;
            }
            if (v.displayType !== 'TabGridView') {
              return;
            }
            if (_.indexOf(_this.pendingCategories, _.find(_this.pendingCategories, function(o) {
              return o === v.category;
            })) === -1) {
              _this.pendingCategories.push(v.category);
            }
            if (_.indexOf(_this.pendingUiItems, _.find(_this.pendingUiItems, function(o) {
              return v.name === o.name;
            })) === -1) {
              return _this.pendingUiItems.push(v);
            }
          };
        })(this));
        if (this.isMounted()) {
          this.setState({
            uiItems: this.pendingUiItems,
            categories: this.pendingCategories
          });
          return requiresRefresh = false;
        }
      }
    },
    renderCategory: function(name, i) {
      return React.createElement("p", {
        "className": "list-title",
        "key": i
      }, name);
    },
    isMenuItemActive: function(path) {
      var currentPath;
      currentPath = this.props.props.location.pathname;
      if ("/" + path === currentPath) {
        return 'active';
      }
    },
    renderMenuItem: function(item, i) {
      return React.createElement(Link, {
        "className": "side-menu-link " + (this.isMenuItemActive(item.name)),
        "to": "" + item.name,
        "key": i
      }, React.createElement("li", {
        "className": "side-menu-li",
        "key": i
      }, item.displayName));
    },
    renderMenuItems: function(category) {
      var menuItemsOfThisCategory;
      menuItemsOfThisCategory = _.filter(this.state.uiItems, function(o) {
        return o.category === category;
      });
      if (menuItemsOfThisCategory.length > 0) {
        return menuItemsOfThisCategory.map((function(_this) {
          return function(menuItem, j) {
            return _this.renderMenuItem(menuItem, j + 1);
          };
        })(this));
      }
    },
    openModal: function() {
      return window.yuiModal();
    },
    render: function() {
      return React.createElement("div", {
        "className": "sidebar"
      }, React.createElement("div", {
        "className": "topLeft"
      }, React.createElement("div", {
        "className": "logoContainer"
      }, React.createElement("img", {
        "className": "chiikaLogo",
        "src": "../assets/images/topLeftLogo.png"
      })), React.createElement(Link, {
        "to": "User",
        "className": "userArea noDecoration"
      }, React.createElement("div", {
        "className": "imageContainer"
      }, React.createElement("img", {
        "id": "userAvatar",
        "className": "img-circle avatar",
        "src": "../assets/images/avatar.jpg"
      })), React.createElement("div", {
        "className": "userInfo"
      }, "Chiika"))), React.createElement("div", {
        "className": "navigation"
      }, React.createElement("ul", null, React.createElement(Link, {
        "className": "side-menu-link " + (this.isMenuItemActive('Home')),
        "to": "Home"
      }, React.createElement("li", {
        "className": "side-menu-li"
      }, "Home")), this.state.categories.map((function(_this) {
        return function(category, i) {
          return React.createElement("div", {
            "key": i
          }, _this.renderCategory(category, i), _this.renderMenuItems(category));
        };
      })(this))), React.createElement("button", {
        "className": "button raised red",
        "onClick": this.openModal,
        "id": "settings-button"
      }, "Settings")));
    }
  });

  module.exports = SideMenu;

}).call(this);
