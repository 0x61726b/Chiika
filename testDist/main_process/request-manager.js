(function() {
  var RequestErrorException, RequestManager, request, _;

  request = require('request');

  _ = require('lodash');

  RequestErrorException = require('./exceptions').RequestErrorException;

  module.exports = RequestManager = (function() {
    function RequestManager() {}

    RequestManager.prototype.makeGetRequest = function(url, headers, callback) {
      var onRequestReturn;
      if (_.isUndefined(headers)) {
        headers = {
          'User-Agent': 'ChiikaDesktopApplication',
          'Content-Type': 'application/x-www-form-urlencoded'
        };
      } else {
        _.assign(headers, {
          'User-Agent': 'ChiikaDesktopApplication',
          'Content-Type': 'application/x-www-form-urlencoded'
        });
      }
      onRequestReturn = function(error, response, body) {
        if (error) {
          chiika.logger.warn("Request has failed with status code: " + response.statusCode);
        } else {
          if (!_.isUndefined(response)) {
            if (response.statusCode !== 200) {
              chiika.logger.warn("Request returned successful but the status code is " + response.statusCode);
            } else {
              chiika.logger.info("Request complete! Return code: " + response.statusCode);
            }
          } else {
            chiika.logger.error("Somehow response is null. WTF ?");
            chiika.logger.error(body);
          }
        }
        return callback(error, response, body);
      };
      chiika.logger.verbose("GET request on " + url);
      return request({
        url: url,
        headers: headers
      }, onRequestReturn);
    };

    RequestManager.prototype.makePostRequest = function(url, headers, callback) {
      var onRequestReturn;
      if (_.isUndefined(headers)) {
        headers = {
          'User-Agent': 'ChiikaDesktopApplication',
          'Content-Type': 'application/x-www-form-urlencoded'
        };
      } else {
        _.assign(headers, {
          'User-Agent': 'ChiikaDesktopApplication',
          'Content-Type': 'application/x-www-form-urlencoded'
        });
      }
      onRequestReturn = function(error, response, body) {
        if (error) {
          chiika.logger.warn("Request has failed with status code: " + response.statusCode);
        } else {
          if (!_.isUndefined(response)) {
            if (response.statusCode !== 200) {
              chiika.logger.warn("Request returned successful but the status code is " + response.statusCode);
            } else {
              chiika.logger.info("Request complete! Return code: " + response.statusCode);
            }
          } else {
            chiika.logger.error("Somehow response is null. WTF ?");
            chiika.logger.error(body);
          }
        }
        return callback(error, response, body);
      };
      chiika.logger.verbose("POST request on " + url);
      return request.post({
        url: url,
        headers: headers
      }, onRequestReturn);
    };

    RequestManager.prototype.makeGetRequestAuth = function(url, user, headers, callback) {
      var auth, form, onRequestReturn;
      form = {
        username: user.userName,
        password: user.password
      };
      auth = {
        user: user.userName,
        password: user.password
      };
      if (_.isUndefined(headers)) {
        headers = {
          'User-Agent': 'ChiikaDesktopApplication',
          'Content-Type': 'application/x-www-form-urlencoded'
        };
      } else {
        _.assign(headers, {
          'User-Agent': 'ChiikaDesktopApplication',
          'Content-Type': 'application/x-www-form-urlencoded'
        });
      }
      chiika.logger.info("Creating a GET request to URL " + url);
      onRequestReturn = function(error, response, body) {
        if (error) {
          chiika.logger.warn("Request has failed with status code: " + response.statusCode);
        } else {
          if (!_.isUndefined(response)) {
            if (response.statusCode !== 200) {
              chiika.logger.warn("Request returned successful but the status code is " + response.statusCode);
            } else {
              chiika.logger.info("Request complete! Return code: " + response.statusCode);
            }
          } else {
            chiika.logger.error("Somehow response is null. WTF ?");
            chiika.logger.error(body);
          }
        }
        return callback(error, response, body);
      };
      return request({
        url: url,
        form: form,
        headers: headers,
        auth: auth
      }, onRequestReturn);
    };

    RequestManager.prototype.makePostRequestAuth = function(url, user, headers, callback) {
      var auth, form, onRequestReturn;
      form = {
        username: user.userName,
        password: user.password
      };
      auth = {
        user: user.userName,
        password: user.password
      };
      if (_.isUndefined(headers)) {
        headers = {
          'User-Agent': 'ChiikaDesktopApplication',
          'Content-Type': 'application/x-www-form-urlencoded'
        };
      } else {
        _.assign(headers, {
          'User-Agent': 'ChiikaDesktopApplication',
          'Content-Type': 'application/x-www-form-urlencoded'
        });
      }
      onRequestReturn = function(error, response, body) {
        if (error) {
          chiika.logger.warn("Request has failed with status code: " + response.statusCode);
        } else {
          if (!_.isUndefined(response)) {
            if (response.statusCode !== 200) {
              chiika.logger.warn("Request returned successful but the status code is " + response.statusCode);
            } else {
              chiika.logger.info("Request complete! Return code: " + response.statusCode);
            }
          } else {
            chiika.logger.error("Somehow response is null. WTF ?");
            chiika.logger.error(body);
          }
        }
        return callback(error, response, body);
      };
      return request.post({
        url: url,
        form: form,
        headers: headers,
        auth: auth
      }, onRequestReturn);
    };

    return RequestManager;

  })();

}).call(this);
