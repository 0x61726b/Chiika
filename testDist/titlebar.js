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
      var close, fullscreen, minimize;
      $('.titlebar').addClass("webkit-draggable");
      close = $('.titlebar-close', $('.titlebar'))[0];
      fullscreen = $('.titlebar-fullscreen', $('.titlebar'))[0];
      minimize = $('.titlebar-minimize', $('.titlebar'))[0];
      $('.titlebar').on('click', (function(_this) {
        return function(e) {
          if (close.contains(e.target)) {
            _this.emitter.emit('titlebar-close');
            return remote.getCurrentWindow().close();
          } else if (fullscreen.contains(e.target)) {
            _this.emitter.emit('titlebar-maximize');
            return remote.getCurrentWindow().maximize();
          } else if (minimize.contains(e.target)) {
            _this.emitter.emit('titlebar-minimize');
            return remote.getCurrentWindow().minimize();
          }
        };
      })(this));
      return $('.titlebar').on('dblclick', (function(_this) {
        return function(e) {
          if (close.contains(target) || minimize.contains(target) || fullscreen.contains(target)) {
            return;
          }
          remote.getCurrentWindow().maximize();
          return _this.emitter.emit('titlebar-maximize');
        };
      })(this));
    },
    render: function() {
      return React.createElement("div", {
        "className": "titlebar"
      }, React.createElement("div", {
        "className": "searchContainer"
      }, React.createElement("input", {
        "type": "text",
        "placeholder": "Search...",
        "className": "form-control",
        "id": "gridSearch"
      })), React.createElement("div", {
        "className": "spotlightContainer"
      }, React.createElement("div", {
        "className": "titlebar-stoplight"
      }, React.createElement("div", {
        "className": "titlebar-minimize"
      }, React.createElement("svg", {
        "x": "0px",
        "y": "0px",
        "viewBox": "0 0 8 1.1"
      }, React.createElement("rect", {
        "fill": "#995700",
        "width": "8",
        "height": "1.1"
      }))), React.createElement("div", {
        "className": "titlebar-fullscreen"
      }, React.createElement("svg", {
        "className": "fullscreen-svg",
        "x": "0px",
        "y": "0px",
        "viewBox": "0 0 6 5.9"
      }, React.createElement("path", {
        "fill": "#006400",
        "d": "M5.4,0h-4L6,4.5V0.6C5.7,0.6,5.3,0.3,5.4,0z"
      }), React.createElement("path", {
        "fill": "#006400",
        "d": "M0.6,5.9h4L0,1.4l0,3.9C0.3,5.3,0.6,5.6,0.6,5.9z"
      })), React.createElement("svg", {
        "className": "maximize-svg",
        "x": "0px",
        "y": "0px",
        "viewBox": "0 0 7.9 7.9"
      }, React.createElement("polygon", {
        "fill": "#006400",
        "points": "7.9,4.5 7.9,3.4 4.5,3.4 4.5,0 3.4,0 3.4,3.4 0,3.4 0,4.5 3.4,4.5 3.4,7.9 4.5,7.9 4.5,4.5"
      }))), React.createElement("div", {
        "className": "titlebar-close"
      }, React.createElement("svg", {
        "x": "0px",
        "y": "0px",
        "viewBox": "0 0 6.4 6.4"
      }, React.createElement("polygon", {
        "fill": "#4d0000",
        "points": "6.4,0.8 5.6,0 3.2,2.4 0.8,0 0,0.8 2.4,3.2 0,5.6 0.8,6.4 3.2,4 5.6,6.4 6.4,5.6 4,3.2"
      }))))));
    }
  });

}).call(this);
