(function() {
  var Emitter, React;

  React = require('react');

  Emitter = require('event-kit').Emitter;

  module.exports = React.createClass({
    emitter: null,
    componentWillMount: function() {
      return this.emitter = new Emitter;
    },
    componentDidMount: function() {
      return console.log("Settings Mounted");
    },
    render: function() {
      return React.createElement("div", {
        "className": "modal"
      }, React.createElement("div", {
        "className": "settingsModal"
      }, React.createElement("div", {
        "className": "navigation"
      }, React.createElement("h5", null, "Settings"), React.createElement("ul", null, React.createElement("p", {
        "className": "list-title"
      }, "General"), React.createElement("a", {
        "id": "window",
        "className": "side-menu-link active"
      }, React.createElement("li", null, "Window")), React.createElement("a", {
        "id": "account",
        "className": "side-menu-link"
      }, React.createElement("li", null, "Account")), React.createElement("a", {
        "className": "side-menu-link"
      }, React.createElement("li", null, "Page 1")), React.createElement("p", {
        "className": "list-title"
      }, "Lists"), React.createElement("a", {
        "className": "side-menu-link"
      }, React.createElement("li", null, "Page 1")), React.createElement("a", {
        "className": "side-menu-link"
      }, React.createElement("li", null, "Page 1")), React.createElement("p", {
        "className": "list-title"
      }, "Accounts"), React.createElement("a", {
        "className": "side-menu-link"
      }, React.createElement("li", null, "Page 1")), React.createElement("button", {
        "className": "button raised red",
        "onClick": yuiCloseModal
      }, " Close "))), React.createElement("div", {
        "className": "settings-page"
      }, React.createElement("h2", null, "Settings Page Title"), React.createElement("div", {
        "className": "card"
      }, React.createElement("div", {
        "className": "title"
      }, React.createElement("h4", null, "Settings Group Tiddddddddddddtel"))))));
    }
  });

}).call(this);
