(function() {
  var CardManager, CardViews, React, _;

  React = require('react');

  _ = require('lodash');

  CardViews = require('./cards');

  module.exports = CardManager = (function() {
    CardManager.prototype.cards = [];

    function CardManager() {
      this.views = new CardViews();
    }

    CardManager.prototype.addCard = function(card) {
      var find, index;
      find = _.find(this.cards, function(o) {
        return o.name === card.name;
      });
      index = _.indexOf(this.cards, find);
      if (find != null) {
        return this.cards.splice(index, 1, find);
      } else {
        return this.cards.push(card);
      }
    };

    CardManager.prototype.getCard = function(name) {
      var find;
      find = _.find(this.cards, function(o) {
        return o.name === name;
      });
      if (find != null) {
        return find;
      } else {
        return null;
      }
    };

    CardManager.prototype.renderCard = function(card, i) {
      if (card.type === 'miniCard') {
        return this.views.miniCard(card, i);
      }
    };

    return CardManager;

  })();

}).call(this);
