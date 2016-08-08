(function() {
  var LoadingScreen, React, _;

  React = require('react');

  _ = require('lodash');

  LoadingScreen = require('./loading-screen');

  module.exports = React.createClass({
    getInitialState: function() {
      return {
        cards: []
      };
    },
    componentWillMount: function() {},
    componentWillReceiveProps: function(props) {
      return this.setState({
        cards: props.route.cards
      });
    },
    componentWillUnmount: function() {},
    componentDidUpdate: function() {
      return console.log(this.state.cards.cards);
    },
    render: function() {
      return React.createElement("div", null, (this.state.cards.length === 0 ? React.createElement(LoadingScreen, null) : this.state.cards.map((function(_this) {
        return function(card, i) {
          return chiika.cardManager.renderCard(card, i);
        };
      })(this))));
    }
  });

}).call(this);
