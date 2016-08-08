(function() {
  var BrowserWindow, Menu, Tray, Utility, fs, globalShortcut, ipcMain, mkdirp, ncp, path, string, _, _ref;

  _ref = require('electron'), BrowserWindow = _ref.BrowserWindow, ipcMain = _ref.ipcMain, globalShortcut = _ref.globalShortcut, Tray = _ref.Tray, Menu = _ref.Menu;

  _ = require('lodash');

  path = require('path');

  fs = require('fs');

  mkdirp = require('mkdirp');

  ncp = require('ncp');

  string = require('string');

  module.exports = Utility = (function() {
    function Utility() {}

    Utility.prototype.fileExists = function(absolutePath) {
      var e, file;
      try {
        file = fs.statSync(absolutePath);
      } catch (_error) {
        e = _error;
        file = void 0;
      }
      if (_.isUndefined(file)) {
        return false;
      } else {
        return true;
      }
    };

    Utility.prototype.fileExistsSmart = function(relativePath) {
      return this.fileExists(path.join(chiika.getAppHome(), relativePath));
    };

    Utility.prototype.readFileSync = function(absolutePath) {
      return fs.readFileSync(absolutePath, 'utf-8');
    };

    Utility.prototype.readFileSmart = function(relativePath) {
      return this.readFileSync(path.join(chiika.getAppHome(), relativePath));
    };

    Utility.prototype.openFileWSync = function(absolutePath) {
      return fs.openSync(absolutePath, 'w');
    };

    Utility.prototype.closeFileSync = function(fd) {
      return fs.closeSync(fd);
    };

    Utility.prototype.openFileWSmart = function(relativePath) {
      return this.openFileWSync(path.join(chiika.getAppHome(), relativePath));
    };

    Utility.prototype.writeFileSync = function(absolutePath, write) {
      return fs.writeFileSync(absolutePath, write, 'utf-8');
    };

    Utility.prototype.writeFileSmart = function(relativePath, write) {
      return this.writeFileSync(path.join(chiika.getAppHome(), relativePath), write);
    };

    Utility.prototype.createFolder = function(absolutePath) {
      return new Promise((function(_this) {
        return function(resolve) {
          return mkdirp(absolutePath, function() {
            return resolve();
          });
        };
      })(this));
    };

    Utility.prototype.createFolderSmart = function(relativePath) {
      return this.createFolder(path.join(chiika.getAppHome(), relativePath));
    };

    Utility.prototype.copyFileToDestination = function(fileAbsolute, destinationAbsolute) {
      return fs.createReadStream(fileAbsolute).pipe(fs.createWriteStream(destinationAbsolute));
    };

    Utility.prototype.copyDirectoryToDestination = function(dirAbsolute, destinationAbsolute) {
      return ncp(dirAbsolute, destinationAbsolute, (function(_this) {
        return function(err) {
          if (err) {
            chiika.logger.error("Error copying directory! " + err);
            throw err;
          }
        };
      })(this));
    };

    Utility.prototype.getScreenResolution = function() {
      var height, width, _ref1;
      _ref1 = electron.screen.getPrimaryDisplay().workAreaSize, width = _ref1.width, height = _ref1.height;
      return {
        width: width,
        height: height
      };
    };

    Utility.prototype.calculateWindowSize = function() {
      var screenRes, windowHeight, windowWidth;
      screenRes = this.getScreenResolution();
      windowWidth = Math.round(screenRes.width * 0.66);
      windowHeight = Math.round(screenRes.height * 0.75);
      return {
        width: windowWidth,
        height: windowHeight
      };
    };

    Utility.prototype.chompLeft = function(orig, str) {
      return string(orig).chompLeft(str).s;
    };

    Utility.prototype.chompRight = function(orig, str) {
      return string(orig).chompRight(str).s;
    };

    return Utility;

  })();

}).call(this);
