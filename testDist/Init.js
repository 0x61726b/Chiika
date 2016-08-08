(function() {
  var Chiika, Col, Environment, LoadingScreen, React, ReactDOM;

  React = require("react");

  ReactDOM = require("react-dom");

  Chiika = require("../chiika");

  LoadingScreen = require('../loading-screen');

  Environment = require('../chiika-environment');

  Col = require('../custom-column-types');

  window.$ = window.jQuery = require('../bundleJs.js');

  $(function() {
    var app, loading;
    loading = function() {
      return ReactDOM.render(React.createElement(LoadingScreen), document.getElementById('app'));
    };
    app = function() {
      return $(".loading-screen").fadeOut('fast', function() {
        return ReactDOM.render(React.createElement(Chiika), document.getElementById('app'));
      });
    };
    loading();
    window.chiika = new Environment({
      window: window,
      chiikaHome: process.env.CHIIKA_HOME,
      env: process.env
    });
    chiika.onReinitializeUI(loading, app);
    return chiika.emitter.emit('reinitialize-ui', {
      delay: 100
    });
  });

}).call(this);
