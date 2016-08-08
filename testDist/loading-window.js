(function() {
  var BrowserHistory, Link, LoadingWindow, React, ReactDOM, Route, Router, anime, electron, ipcRenderer, _ref, _ref1;

  React = require('react');

  _ref = require('react-router'), Router = _ref.Router, Route = _ref.Route, BrowserHistory = _ref.BrowserHistory, Link = _ref.Link;

  ReactDOM = require("react-dom");

  _ref1 = require('electron'), electron = _ref1.electron, ipcRenderer = _ref1.ipcRenderer;

  anime = require('animejs');

  window.$ = window.jQuery = require('./../bundleJs.js');

  LoadingWindow = React.createClass({
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
        "className": "loading-screen"
      }, React.createElement("div", null, React.createElement("img", {
        "src": "../assets/images/logo.svg",
        "style": {
          width: 72,
          height: 72
        },
        "className": "anime",
        "alt": ""
      })));
    }
  });

  ReactDOM.render(React.createElement(LoadingWindow), document.getElementById('app'));

}).call(this);
