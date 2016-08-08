(function() {
  var CardView, LoadingMini, React, _;

  React = require('react');

  _ = require('lodash');

  CardView = require('./card-view');

  LoadingMini = require('./loading-mini');

  module.exports = React.createClass({
    getInitialState: function() {
      return {
        layout: {
          miniCards: [],
          genres: "",
          actionButtons: [],
          synopsis: "",
          characters: [],
          cover: null,
          scoring: {
            type: 'normal',
            userScore: 0
          }
        }
      };
    },
    componentWillMount: function() {
      var id, owner;
      console.log("Will mount");
      id = this.props.params.id;
      owner = 'myanimelist';
      return chiika.ipc.getDetailsLayout(id, owner, (function(_this) {
        return function(args) {
          _this.setState({
            layout: args
          });
          return console.log(_this.state.layout);
        };
      })(this));
    },
    componentWillUnmount: function() {
      return chiika.ipc.disposeListeners('details-layout-request-response');
    },
    componentDidMount: function() {
      return console.log("Mount");
    },
    componentDidUpdate: function() {
      var average, chart, options, remainder, scoring, userScore;
      scoring = this.state.layout.scoring;
      userScore = 0;
      remainder = 10;
      if (scoring.type === 'normal') {
        userScore = scoring.userScore;
        average = scoring.average;
        remainder = 10 - userScore;
        options = {
          type: 'doughnut',
          options: {
            legend: {
              display: false
            },
            cutoutPercentage: 60
          },
          data: {
            datasets: [
              {
                data: [userScore, remainder],
                backgroundColor: ["#0288D1"]
              }, {
                data: [average, 10 - average],
                backgroundColor: ["#6A1B9A"]
              }
            ],
            labels: ["Average", "y"]
          }
        };
        return chart = new Chart(document.getElementById("score-circle"), options);
      }
    },
    render: function() {
      var _ref;
      return React.createElement("div", {
        "className": "detailsPage"
      }, React.createElement("div", {
        "className": "detailsPage-left"
      }, (this.state.layout.cover != null ? React.createElement("img", {
        "src": "" + this.state.layout.cover,
        "onClick": yuiModal,
        "width": "150",
        "height": "225",
        "alt": ""
      }) : React.createElement(LoadingMini, null)), (this.state.layout.list ? React.createElement("div", null, React.createElement("button", {
        "type": "button",
        "className": "button raised lightblue"
      }, "Watching"), React.createElement("div", {
        "className": "progressInteractions"
      }, React.createElement("div", {
        "className": "title"
      }, "Episode"), React.createElement("div", {
        "className": "interactions"
      }, React.createElement("button", {
        "className": "minus"
      }, "-"), React.createElement("div", {
        "className": "number"
      }, React.createElement("input", {
        "type": "text",
        "name": "name",
        "value": ""
      }), React.createElement("span", null, "\x2F 36")), React.createElement("button", {
        "className": "plus"
      }, "+")))) : void 0), (this.state.layout.list ? this.state.layout.actionButtons.map((function(_this) {
        return function(button, i) {
          return React.createElement("button", {
            "type": "button",
            "className": "button raised " + button.color,
            "key": i
          }, " ", button.name);
        };
      })(this)) : React.createElement("button", {
        "type": "button",
        "className": "button raised yellow"
      }, "Add to List"))), React.createElement("div", {
        "className": "detailsPage-right"
      }, React.createElement("div", {
        "className": "detailsPage-row"
      }, React.createElement("h1", null, this.state.layout.title), React.createElement("span", {
        "className": "detailsPage-genre"
      }, React.createElement("ul", null, (this.state.layout.genres != null ? this.state.layout.genres.split(',').map((function(_this) {
        return function(genre, i) {
          return React.createElement("li", {
            "key": i
          }, genre);
        };
      })(this)) : void 0)))), React.createElement("div", {
        "className": "detailsPage-score detailsPage-row"
      }, React.createElement("div", {
        "className": "score-circle-div",
        "data-score": this.state.layout.scoring.average
      }, React.createElement("canvas", {
        "id": "score-circle",
        "width": "100",
        "height": "100"
      })), React.createElement("span", {
        "className": "detailsPage-score-info"
      }, React.createElement("h5", null, "From ", (_ref = this.state.layout.voted) != null ? _ref : "", " votes"), React.createElement("span", null, React.createElement("h5", null, "Your Score"), (this.state.layout.scoring.type === "normal" ? React.createElement("select", {
        "className": "button lightblue",
        "name": "",
        "value": this.state.layout.scoring.userScore
      }, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map((function(_this) {
        return function(score, i) {
          return React.createElement("option", {
            "value": score,
            "key": i
          }, score);
        };
      })(this))) : void 0)))), React.createElement("div", {
        "className": "detailsPage-miniCards detailsPage-row"
      }, (this.state.layout.miniCards.length !== 0 ? this.state.layout.miniCards.map((function(_this) {
        return function(card, i) {
          return chiika.cardManager.renderCard(card, i);
        };
      })(this)) : React.createElement(LoadingMini, null))), React.createElement("div", {
        "className": "card"
      }, React.createElement("div", {
        "className": "detailsPage-card-item"
      }, React.createElement("div", {
        "className": "title"
      }, React.createElement("h2", null, "Synopsis")), (this.state.layout.synopsis.length > 0 ? React.createElement("div", {
        "className": "card-content",
        "dangerouslySetInnerHTML": {
          __html: this.state.layout.synopsis
        }
      }) : void 0)), React.createElement("div", {
        "className": "detailsPage-card-item"
      }, React.createElement("div", {
        "className": "title"
      }, React.createElement("h2", null, "Characters")), React.createElement("div", {
        "className": "card-content"
      }, (this.state.layout.characters.length > 0 ? this.state.layout.characters.map((function(_this) {
        return function(ch, i) {
          return React.createElement("div", {
            "key": i
          }, React.createElement("img", {
            "src": ch.image,
            "alt": ""
          }), React.createElement("span", null, ch.name));
        };
      })(this)) : void 0))))), React.createElement("div", {
        "className": "fab"
      }, "\x3E"));
    }
  });

}).call(this);
