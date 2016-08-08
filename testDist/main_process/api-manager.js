(function() {
  var APIManager, Emitter, coffee, fs, moment, path, rimraf, string, _, _when,
    __slice = [].slice;

  path = require('path');

  fs = require('fs');

  _ = require('lodash');

  _when = require('when');

  coffee = require('coffee-script');

  string = require('string');

  Emitter = require('event-kit').Emitter;

  moment = require('moment');

  rimraf = require('rimraf');

  module.exports = APIManager = (function() {
    APIManager.prototype.compiledUserScripts = [];

    APIManager.prototype.scriptInstances = [];

    APIManager.prototype.scriptsDirs = [];

    APIManager.prototype.emitter = null;

    function APIManager() {
      global.api = this;
      this.emitter = new Emitter;
      this.scriptsDir = path.join(chiika.getAppHome(), "Scripts");
      this.scriptsCacheDir = path.join(chiika.getAppHome(), "Cache", "Scripts");
      this.scriptsDirs.push(path.join(process.cwd(), "scripts"));
      this.watchScripts();
    }

    APIManager.prototype.onScriptCompiled = function(script) {
      var index, instance, isActive, isService, localInstance, loginType, logo, match, rScript, scriptDesc, scriptName, sub, subs, _i, _len;
      rScript = require(script);
      instance = new rScript(chiika.chiikaApi);
      subs = _.where(chiika.chiikaApi.subscriptions, {
        receiver: instance.name
      });
      for (_i = 0, _len = subs.length; _i < _len; _i++) {
        sub = subs[_i];
        sub.sub.dispose();
        _.remove(chiika.chiikaApi.subscriptions, sub);
      }
      instance.run(chiika.chiikaApi);
      scriptName = instance.name;
      scriptDesc = instance.displayDescription;
      logo = instance.logo;
      loginType = instance.loginType;
      isService = instance.isService;
      isActive = instance.isActive;
      if (isService === null || _.isUndefined(isService)) {
        isService = true;
      }
      if (isActive == null) {
        isActive = true;
      }
      localInstance = {
        name: scriptName,
        description: scriptDesc,
        logo: logo,
        instance: instance,
        loginType: loginType,
        isService: isService,
        isActive: isActive
      };
      if (!_.isUndefined(this.getScriptByName(scriptName))) {
        match = _.find(this.scriptInstances, localInstance);
        index = _.indexOf(this.scriptInstances, _.find(this.scriptInstances, localInstance));
        this.scriptInstances.splice(index, 1, localInstance);
        chiika.logger.info("[magenta](Api-Manager) Updating script instance " + rScript.name);
      } else {
        chiika.logger.info("[magenta](Api-Manager) Adding new script instance " + rScript.name);
        this.scriptInstances.push(localInstance);
      }
      return this.initializeScript(scriptName);
    };

    APIManager.prototype.getScriptByName = function(name) {
      var instance;
      instance = _.find(this.scriptInstances, {
        name: name
      });
      if (!_.isUndefined(instance)) {
        return instance;
      } else {
        chiika.logger.error("You are trying to access " + name + " but it doesnt exist!");
        return void 0;
      }
    };

    APIManager.prototype.getScripts = function() {
      return this.scriptInstances;
    };

    APIManager.prototype.initializeScript = function(name) {
      return chiika.chiikaApi.emit('initialize', {
        calling: name
      });
    };

    APIManager.prototype.postInit = function() {
      return chiika.chiikaApi.emit('post-initialize', {});
    };

    APIManager.prototype.compileUserScripts = function() {
      var processedFileCount, sanityCheck, sanityPromise, scriptCount, scriptDir, _i, _len, _ref;
      chiika.logger.info("[magenta](Api-Manager) Compiling user scripts...");
      this.promises = [];
      sanityCheck = _when.defer();
      sanityPromise = sanityCheck.promise;
      this.promises.push(sanityPromise);
      processedFileCount = 0;
      scriptCount = 2;
      _ref = this.scriptsDirs;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        scriptDir = _ref[_i];
        fs.readdir(scriptDir, (function(_this) {
          return function(err, files) {
            return _.forEach(files, function(v, k) {
              var defer, stripExtension;
              stripExtension = string(v).chompRight('.coffee').s;
              if (stripExtension[0] === "_") {
                chiika.logger.info("[magenta](Api-Manager) Skipping disabled script " + stripExtension.substring(1, stripExtension.length));
                return;
              }
              chiika.logger.info("[magenta](Api-Manager) Compiling " + v);
              defer = _when.defer();
              _this.promises.push(defer.promise);
              return fs.readFile(path.join(scriptDir, v), 'utf-8', function(err, data) {
                var jsCode;
                jsCode = data;
                return _this.compileScript(jsCode, v, true, function() {
                  defer.resolve();
                  processedFileCount++;
                  if (processedFileCount === scriptCount) {
                    return sanityCheck.resolve();
                  }
                });
              });
            });
          };
        })(this));
      }
      return _when.all(this.promises);
    };

    APIManager.prototype.compileScript = function(js, file, cache, callback) {
      var cachedScriptPath, compiledString, e, stripExtension;
      stripExtension = string(file).chompRight('.coffee').s;
      try {
        compiledString = coffee.compile(js);
        chiika.logger.info("[magenta](Api-Manager) Compiled " + file);
      } catch (_error) {
        e = _error;
        chiika.logger.error("[magenta](Api-Manager) Error compiling user-script " + file);
        throw e;
      }
      cachedScriptPath = path.join(this.scriptsCacheDir, stripExtension + moment().valueOf() + '.chiikaJS');
      if (cache) {
        return fs.writeFile(cachedScriptPath, compiledString, (function(_this) {
          return function(err) {
            if (err) {
              chiika.error("[magenta](Api-Manager) Error occured while writing compiled script to the file.");
              throw err;
            }
            chiika.logger.verbose("[magenta](Api-Manager) Cached " + file + " " + moment().format('DD/MM/YYYY HH:mm'));
            _this.onScriptCompiled(cachedScriptPath);
            return callback();
          };
        })(this));
      }
    };

    APIManager.prototype.watchScripts = function() {
      return fs.readdir(this.scriptsDir, (function(_this) {
        return function(err, files) {
          return _.forEach(files, function(v, k) {
            return fs.watchFile(path.join(_this.scriptsDir, v), function(eventType, filename) {
              var stripExtension;
              chiika.logger.info("[magenta](Api-Manager) Recompiling...");
              stripExtension = string(v).chompRight('.coffee').s;
              return fs.readFile(path.join(_this.scriptsDir, v), 'utf-8', function(err, data) {
                var jsCode;
                jsCode = data;
                return _this.compileScript(jsCode, v, true, function() {});
              });
            });
          });
        };
      })(this));
    };

    APIManager.prototype.clearCache = function() {
      rimraf = require('rimraf');
      return rimraf(this.scriptsCacheDir, {}, function() {
        return chiika.logger.info("[magenta](Api-Manager) Cleared scripts cache.");
      });
    };

    APIManager.prototype.on = function(message, callback) {
      return this.emitter.on(message, callback);
    };

    APIManager.prototype.emit = function() {
      var args, message, _ref;
      message = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return (_ref = this.emitter).emit.apply(_ref, [message].concat(__slice.call(args)));
    };

    return APIManager;

  })();

}).call(this);
