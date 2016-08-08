(function() {
  var ExceptionBase;

  ExceptionBase = function(message) {
    return chiika.logger.error(message);
  };

  module.exports = {
    InvalidParameterException: function(message) {
      this.name = "InvalidParameterException";
      this.message = message;
      return ExceptionBase(this.message);
    },
    InvalidOperationException: function(message) {
      this.name = "InvalidOperationException";
      this.message = message;
      return ExceptionBase(this.message);
    },
    RequestErrorException: function(error) {
      this.name = "RequestErrorException";
      this.message = error.message + (" Status Code: " + error.statusCode);
      return ExceptionBase(this.message);
    }
  };

}).call(this);
