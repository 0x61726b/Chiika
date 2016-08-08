(function() {
  var BrowserHistory, IPC, Link, LoadingScreen, MalLogin, React, ReactDOM, Route, Router, electron, ipcRenderer, remote, string, _, _ref, _ref1;

  React = require('react');

  ReactDOM = require("react-dom");

  _ref = require('react-router'), Router = _ref.Router, Route = _ref.Route, BrowserHistory = _ref.BrowserHistory, Link = _ref.Link;

  _ref1 = require('electron'), electron = _ref1.electron, ipcRenderer = _ref1.ipcRenderer, remote = _ref1.remote;

  IPC = require('../chiika-ipc');

  LoadingScreen = require('../loading-screen');

  _ = require('lodash');

  string = require('string');

  window.$ = window.jQuery = require('../bundleJs.js');

  MalLogin = React.createClass({
    getInitialState: function() {
      return {
        services: []
      };
    },
    componentDidMount: function() {
      window.chiika = this;
      this.logger = remote.getGlobal('logger');
      this.ipcManager = new IPC();
      window.ipcManager = this.ipcManager;
      this.ipcManager.sendReceiveIPC('get-services', null, (function(_this) {
        return function(event, defer, args) {
          if (args != null) {
            console.log(args);
            _this.setState({
              services: args
            });
            return args.map(function(service, i) {
              return $("#authPin-" + service.name).on('input', function() {
                if (_.isEmpty($("#authPin-" + service.name).val())) {
                  $("#verifyBtn-" + service.name).hide();
                  return $("#gotoBtn-" + service.name).show();
                } else {
                  $("#verifyBtn-" + service.name).show();
                  return $("#gotoBtn-" + service.name).hide();
                }
              });
            });
          }
        };
      })(this));
      ipcRenderer.on('login-response', (function(_this) {
        return function(event, response) {
          var message;
          $("#log-btn").prop('disabled', false);
          if (!response.success) {
            message = "We couldn't login you with the selected service!";
            window.yuiToast(message, 'top', 5000, 'dark');
            console.log(response);
            _this.highlightFormByParent("red", "#loginForm-" + response.service + " ");
          } else {
            console.log(response);
            _this.highlightFormByParent("green", "#loginForm-" + response.service + " ");
          }
          return $("#continue").prop("disabled", false);
        };
      })(this));
      ipcRenderer.on('inform-login-response', (function(_this) {
        return function(event, response) {
          console.log(response);
          if (response.status) {
            $("#authPin-" + response.owner).val(response.authPin);
            $("#gotoBtn-" + response.owner).hide();
            $("#verifyBtn-" + response.owner).show();
          } else {
            _this.highlightFormByParent("red", "#authPin-" + response.owner);
          }
          return $("#continue").prop("disabled", false);
        };
      })(this));
      return ipcRenderer.on('inform-login-set-form-value', (function(_this) {
        return function(event, response) {
          var parent;
          parent = "#loginForm-" + response.owner + " ";
          $(parent + ("#" + response.target)).val(response.value);
          return console.log(response);
        };
      })(this));
    },
    highlightFormByParent: function(color, parent) {
      var pass, user;
      user = $(parent + "#email");
      pass = $(parent + "#password");
      user.css({
        "border": "" + color + " 1px solid"
      });
      return pass.css({
        "border": "" + color + " 1px solid"
      });
    },
    componentDidUpdate: function() {
      return $("form").filter(function() {
        if (!_.isUndefined(this.id)) {
          return this.id.match(/loginForm-(.*?)/g);
        }
      }).submit((function(_this) {
        return function(e) {
          e.preventDefault();
          return false;
        };
      })(this));
    },
    onSubmit: function(e) {
      var id, loginData, parent, pass, serviceName, user;
      parent = "#" + $(e.target).parent().attr('id') + " ";
      user = $(parent + "#email").val();
      pass = $(parent + "#password").val();
      id = $(e.target).parent().attr("id");
      serviceName = string(id).chompLeft('loginForm-').s;
      if (_.isEmpty(user || _.isEmpty(pass))) {

      } else {
        loginData = {
          user: user,
          pass: pass
        };
        return ipcRenderer.send('set-user-login', {
          login: loginData,
          service: serviceName
        });
      }
    },
    onSubmitAuthPin: function(e) {
      var id, serviceName;
      id = $(e.target).parent().attr("id");
      serviceName = string(id).chompLeft('loginForm-').s;
      ipcRenderer.send('set-user-auth-pin', {
        service: serviceName
      });
      return $("#continue").prop('disabled', true);
    },
    onSubmitAuthPinStep2: function(e) {
      var authPin, id, parent, serviceName, user;
      id = $(e.target).parent().attr("id");
      parent = "#" + $(e.target).parent().attr('id') + " ";
      serviceName = string(id).chompLeft('loginForm-').s;
      authPin = $("#authPin-" + serviceName).val();
      user = $(parent + "#userName").val();
      ipcRenderer.send('set-user-login', {
        authPin: authPin,
        service: serviceName,
        user: user
      });
      return $("#continue").prop('disabled', true);
    },
    continueToApp: function(e) {
      this.ipcManager.sendMessage('call-window-method', 'close');
      this.ipcManager.sendMessage('window-method', {
        method: 'show',
        window: 'main'
      });
      return this.ipcManager.sendMessage('continue-from-login');
    },
    loginBody: function(key, service) {
      return React.createElement("div", {
        "className": "card",
        "id": "login-container",
        "key": key
      }, React.createElement("img", {
        "src": service.logo,
        "id": "mal-logo",
        "style": {
          width: 200,
          height: 200
        },
        "alt": ""
      }), React.createElement("form", {
        "className": "",
        "id": "loginForm-" + service.name
      }, React.createElement("label", {
        "htmlFor": "log-usr"
      }, "Username"), React.createElement("input", {
        "type": "text",
        "className": "text-input",
        "id": "email",
        "required": true,
        "autofocus": true
      }), React.createElement("label", {
        "htmlFor": "log-psw"
      }, "Password"), React.createElement("input", {
        "type": "Password",
        "className": "text-input",
        "id": "password",
        "required": true
      }), React.createElement("input", {
        "type": "submit",
        "onClick": this.onSubmit,
        "className": "button raised indigo log-btn",
        "id": "log-btn",
        "value": "Verify"
      })));
    },
    authPinBody: function(key, service) {
      return React.createElement("div", {
        "className": "card",
        "id": "login-container",
        "key": key
      }, React.createElement("img", {
        "src": service.logo,
        "id": "mal-logo",
        "style": {
          width: 200,
          height: 200
        },
        "alt": ""
      }), React.createElement("form", {
        "className": "",
        "id": "loginForm-" + service.name
      }, React.createElement("label", {
        "htmlFor": "log-usr"
      }, "User Name"), React.createElement("input", {
        "type": "text",
        "className": "text-input",
        "id": "userName",
        "placeholder": "Will be automatically replaced. If not, type your display name",
        "required": true,
        "autofocus": true
      }), React.createElement("label", {
        "htmlFor": "log-usr"
      }, "Auth Pin"), React.createElement("input", {
        "type": "text",
        "className": "text-input",
        "id": "authPin-" + service.name,
        "required": true,
        "autofocus": true,
        "disabled": true,
        "placeholder": "Will be automatically replaced"
      }), React.createElement("input", {
        "type": "submit",
        "onClick": this.onSubmitAuthPin,
        "className": "button raised indigo log-btn",
        "id": "gotoBtn-" + service.name,
        "value": "Go to " + service.description
      }), React.createElement("input", {
        "type": "submit",
        "onClick": this.onSubmitAuthPinStep2,
        "className": "button raised indigo log-btn",
        "id": "verifyBtn-" + service.name,
        "value": "Verify"
      })));
    },
    render: function() {
      var i, serviceCount;
      if (this.state.services != null) {
        serviceCount = this.state.services.length;
      } else {
        serviceCount = 0;
      }
      if (serviceCount === 0) {
        return React.createElement(LoadingScreen, null);
      } else {
        return React.createElement("div", {
          "className": "login-body-outer"
        }, React.createElement("div", {
          "className": "login-body"
        }, (function() {
          var _i, _results;
          _results = [];
          for (i = _i = 0; 0 <= serviceCount ? _i < serviceCount : _i > serviceCount; i = 0 <= serviceCount ? ++_i : --_i) {
            if (this.state.services[i].loginType === 'authPin') {
              _results.push(this.authPinBody(i, this.state.services[i]));
            } else {
              _results.push(this.loginBody(i, this.state.services[i]));
            }
          }
          return _results;
        }).call(this)), React.createElement("input", {
          "type": "submit",
          "onClick": this.continueToApp,
          "className": "button raised indigo log-btn-contiue",
          "id": "continue",
          "value": "Continue to Chiika"
        }));
      }
    }
  });

  ReactDOM.render(React.createElement(MalLogin), document.getElementById('app'));

}).call(this);
