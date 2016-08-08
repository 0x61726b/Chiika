(function() {
  var BrowserHistory, Link, React, Route, Router, anime, _ref;

  React = require('react');

  _ref = require('react-router'), Router = _ref.Router, Route = _ref.Route, BrowserHistory = _ref.BrowserHistory, Link = _ref.Link;

  anime = require('animejs');

  module.exports = React.createClass({
    componentDidMount: function() {
      return anime({
        targets: '.anime' + name,
        rotate: {
          value: 180,
          duration: 1500,
          easing: 'easeInOutQuad'
        },
        scale: {
          value: 2,
          delay: 150,
          duration: 850,
          easing: 'easeInOutExpo'
        },
        direction: 'alternate',
        loop: true
      });
    },
    render: function() {
      return React.createElement("div", {
        "style": {
          width: 'inherit',
          height: 'inherit',
          align: 'center'
        }
      }, React.createElement("div", null, React.createElement("img", {
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
