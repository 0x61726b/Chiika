(function() {
  var BrowserWindow, IpcManager, Menu, Tray, globalShortcut, ipcMain, string, _, _ref, _when,
    __slice = [].slice;

  _ref = require('electron'), BrowserWindow = _ref.BrowserWindow, ipcMain = _ref.ipcMain, globalShortcut = _ref.globalShortcut, Tray = _ref.Tray, Menu = _ref.Menu;

  _ = require('lodash');

  _when = require('when');

  string = require('string');

  module.exports = IpcManager = (function() {
    function IpcManager() {}

    IpcManager.prototype.answer = function() {
      var args, message, receiver;
      receiver = arguments[0], message = arguments[1], args = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
      chiika.logger.verbose("[yellow](IPC-Manager) Sending answer " + message + "-response");
      return receiver.send.apply(receiver, [message + '-response'].concat(__slice.call(args)));
    };

    IpcManager.prototype.send = function() {
      var args, message, receiver, _ref1;
      receiver = arguments[0], message = arguments[1], args = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
      chiika.logger.verbose("[yellow](IPC-Manager) Sending message " + message + " to " + receiver.name + " ");
      return (_ref1 = receiver.webContents).send.apply(_ref1, [message].concat(__slice.call(args)));
    };

    IpcManager.prototype.receiveAnswer = function(message, callback) {
      return ipcMain.on(message, (function(_this) {
        return function(event, args) {
          chiika.logger.info("[yellow](IPC-Manager) Received message " + message);
          return _this.answer(event.sender, message, callback(event, args));
        };
      })(this));
    };

    IpcManager.prototype.receive = function(message, callback) {
      return ipcMain.on(message, (function(_this) {
        return function(event, args) {
          chiika.logger.info("[yellow](IPC-Manager) Received message " + message);
          return callback(event, args);
        };
      })(this));
    };

    IpcManager.prototype.handleEvents = function() {
      this.callWindowMethod();
      this.getUIData();
      this.getUserData();
      this.login();
      this.loginCustom();
      this.getServices();
      this.refreshViewByName();
      this.modalWindowJsEval();
      this.reconstructUI();
      this.windowMethodByName();
      return this.detailsLayoutRequest();
    };

    IpcManager.prototype.windowMethodByName = function() {
      return this.receive('window-method', (function(_this) {
        return function(event, args) {
          var win;
          console.log(args);
          win = chiika.windowManager.getWindowByName(args.window);
          return win[args.method]();
        };
      })(this));
    };

    IpcManager.prototype.callWindowMethod = function() {
      return this.receive('call-window-method', (function(_this) {
        return function(event, method) {
          var win;
          console.log(method);
          win = BrowserWindow.fromWebContents(event.sender);
          return win[method]();
        };
      })(this));
    };

    IpcManager.prototype.detailsLayoutRequest = function() {
      return this.receive('details-layout-request', (function(_this) {
        return function(event, args) {
          var params, returnFromScript;
          returnFromScript = function(layout) {
            return event.sender.send('details-layout-request-response', layout);
          };
          params = {
            calling: args.owner,
            id: args.id,
            "return": returnFromScript
          };
          return chiika.chiikaApi.emit('details-layout', params);
        };
      })(this));
    };

    IpcManager.prototype.reconstructUI = function() {
      return this.receive('reconstruct-ui', (function(_this) {
        return function(event, args) {
          var async, defer, script, _i, _len, _ref1;
          async = [];
          _ref1 = chiika.apiManager.getScripts();
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            script = _ref1[_i];
            if (script.isActive) {
              defer = _when.defer();
              async.push(defer.promise);
              chiika.chiikaApi.emit('reconstruct-ui', {
                defer: defer,
                calling: script.name
              });
            }
          }
          return _when.all(async).then(function() {
            return event.sender.send('reconstruct-ui-response');
          });
        };
      })(this));
    };

    IpcManager.prototype.modalWindowJsEval = function() {
      return this.receive('modal-window-message', (function(_this) {
        return function(event, args) {
          var owner;
          owner = string(args.windowName).chompRight('modal').s;
          console.log(owner);
          return chiika.chiikaApi.emit('ui-modal-message', {
            calling: owner,
            args: args
          });
        };
      })(this));
    };

    IpcManager.prototype.refreshViewByName = function() {
      return this.receive('refresh-view-by-name', (function(_this) {
        return function(event, args) {
          var deferUpdate, view;
          view = chiika.uiManager.getUIItem(args.viewName);
          deferUpdate = _when.defer();
          if (view != null) {
            chiika.chiikaApi.emit('view-update', {
              calling: args.service,
              view: view,
              defer: deferUpdate
            });
            return deferUpdate.promise.then(function() {
              var uiItems;
              uiItems = chiika.uiManager.getUIItems();
              if (uiItems.length > 0) {
                return event.sender.send('get-ui-data-response', uiItems);
              }
            });
          }
        };
      })(this));
    };

    IpcManager.prototype.login = function() {
      this.receive('set-user-login', (function(_this) {
        return function(event, args) {
          var params, returnFromLogin;
          returnFromLogin = function(result) {
            _.assign(result, args);
            return _this.send(chiika.windowManager.getLoginWindow(), 'login-response', result);
          };
          if (args.login != null) {
            return chiika.chiikaApi.emit('set-user-login', {
              calling: args.service,
              user: args.login.user,
              pass: args.login.pass,
              "return": returnFromLogin
            });
          } else {
            params = {
              "return": returnFromLogin,
              calling: args.service
            };
            _.assign(params, args);
            return chiika.chiikaApi.emit('set-user-login', params);
          }
        };
      })(this));
      return this.receive('continue-from-login', (function(_this) {
        return function(event, args) {
          chiika.windowManager.showMainWindow(true);
          return chiika.apiManager.postInit();
        };
      })(this));
    };

    IpcManager.prototype.loginCustom = function() {
      return this.receive('set-user-auth-pin', (function(_this) {
        return function(event, args) {
          return chiika.chiikaApi.emitTo(args.service, 'set-user-auth-pin', {});
        };
      })(this));
    };

    IpcManager.prototype.getUIData = function() {
      return this.receiveAnswer('get-ui-data', (function(_this) {
        return function(event, args) {
          var uiItems;
          uiItems = chiika.uiManager.getUIItems();
          if (uiItems.length > 0) {
            return uiItems;
          }
        };
      })(this));
    };

    IpcManager.prototype.getUserData = function() {
      return this.receiveAnswer('get-user-data', (function(_this) {
        return function(event, args) {
          var users;
          users = chiika.dbManager.usersDb.users;
          if (users.length > 0) {
            return users;
          }
        };
      })(this));
    };

    IpcManager.prototype.getServices = function() {
      return this.receiveAnswer('get-services', (function(_this) {
        return function(event, args) {
          var script, scripts, services, _i, _len;
          scripts = chiika.apiManager.getScripts();
          services = [];
          for (_i = 0, _len = scripts.length; _i < _len; _i++) {
            script = scripts[_i];
            if (script.isService && script.isActive) {
              services.push(script);
            }
          }
          if (services.length > 0) {
            return services;
          } else {
            return void 0;
          }
        };
      })(this));
    };

    return IpcManager;

  })();

}).call(this);
