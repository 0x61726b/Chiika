(function() {
  var BrowserHistory, Link, React, Route, Router, anime, _ref;

  React = require('react');

  _ref = require('react-router'), Router = _ref.Router, Route = _ref.Route, BrowserHistory = _ref.BrowserHistory, Link = _ref.Link;

  anime = require('animejs');

  module.exports = React.createClass({
    componentDidMount: function() {
      return anime({
        targets: '.anime' + name,
        scale: [0.5, 0.7],
        duration: 800,
        direction: 'alternate',
        easing: 'easeInQuart',
        loop: true,
        delay: function(el, index) {
          return index * 200;
        }
      });
    },
    render: function() {
      return React.createElement("div", {
        "className": "loading-screen"
      }, React.createElement("div", null, React.createElement("img", {
        "src": "" + __dirname + "/assets/images/logo.svg",
        "style": {
          width: 72,
          height: 72
        },
        "className": "anime",
        "alt": ""
      }), React.createElement("img", {
        "src": "" + __dirname + "/assets/images/logo.svg",
        "style": {
          width: 72,
          height: 72
        },
        "className": "anime",
        "alt": ""
      }), React.createElement("img", {
        "src": "" + __dirname + "/assets/images/logo.svg",
        "style": {
          width: 72,
          height: 72
        },
        "className": "anime",
        "alt": ""
      }), React.createElement("img", {
        "src": "" + __dirname + "/assets/images/logo.svg",
        "style": {
          width: 72,
          height: 72
        },
        "className": "anime",
        "alt": ""
      }), React.createElement("img", {
        "src": "" + __dirname + "/assets/images/logo.svg",
        "style": {
          width: 72,
          height: 72
        },
        "className": "anime",
        "alt": ""
      })));
    }
  });

}).call(this);
