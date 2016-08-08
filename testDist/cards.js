(function() {
  var CardViews, React, _;

  React = require('react');

  _ = require('lodash');

  module.exports = CardViews = (function() {
    function CardViews() {}

    CardViews.prototype.miniCard = function(card, i) {
      return React.createElement("div", {
        "className": "card purple",
        "key": i
      }, React.createElement("div", {
        "className": "title"
      }, React.createElement("p", {
        "className": "mini-card-title"
      }, card.title)), React.createElement("p", null, card.content));
    };

    CardViews.prototype.cardWithItems = function(card) {
      return React.createElement("div", {
        "className": "card"
      }, card.items.map((function(_this) {
        return function(item, i) {
          if (item.type === 'text') {
            return React.createElement("div", {
              "className": "detailsPage-card-item"
            }, React.createElement("div", {
              "className": "title"
            }, React.createElement("h2", null, item.title)), React.createElement("div", {
              "className": "content"
            }, item.content));
          } else if (item.type === 'miniCard') {
            return React.createElement("div", {
              "className": "detailsPage-card-item"
            }, "@miniCard(item.card)");
          }
        };
      })(this)));
    };

    return CardViews;

  })();

}).call(this);
