(function() {
  var Chart, React, jQBridger, _;

  React = require('react');

  _ = require('lodash');

  Chart = require('chart.js');

  jQBridger = require('jquery-bridget');

  module.exports = React.createClass({
    componentWillReceiveProps: function() {
      return this.props.data = {
        labels: ["Your Score", "Total"],
        datasets: [
          {
            label: '# of Votes',
            data: [7.4, 2.6],
            backgroundColor: ['rgba(255, 159, 64, 1)'],
            borderColor: ['rgba(255, 159, 64, 1)'],
            borderWidth: 0
          }
        ]
      };
    },
    componentDidMount: function() {
      var chartCanvas, options;
      chartCanvas = this.refs.chart;
      options = {
        type: 'doughnut',
        options: {
          legend: {
            display: false
          },
          responsive: true
        },
        data: {
          labels: ["Your Score", "Total"],
          datasets: [
            {
              label: '# of Votes',
              data: [7.4, 2.6],
              backgroundColor: ['rgba(255, 159, 64, 1)'],
              borderColor: ['rgba(255, 159, 64, 1)'],
              borderWidth: 0
            }
          ]
        }
      };
      this.setState({
        chart: chartCanvas
      });
      return window.$ = require('jquery');
    },
    componentDidUpdate: function() {},
    componentWillUnmount: function() {},
    render: function() {
      return React.createElement("div", {
        "className": "gridTest",
        "id": "homeGrid"
      }, React.createElement("div", {
        "className": "card grid teal",
        "id": "card-thisWeek"
      }, React.createElement("div", {
        "className": "grid-sizer"
      }), React.createElement("div", {
        "className": "home-inline title"
      }, React.createElement("h1", null, "This week"), React.createElement("button", {
        "type": "button",
        "className": "teal raised button",
        "name": "button"
      }, "History")), React.createElement("ul", {
        "className": "yui-list floated divider"
      }, React.createElement("li", null, "Episodes watched ", React.createElement("span", {
        "className": "label raised green"
      }, "5")), React.createElement("li", null, "Chapters read ", React.createElement("span", {
        "className": "label raised teal"
      }, "5")), React.createElement("li", null, "Volumes read ", React.createElement("span", {
        "className": "label raised lightblue"
      }, "5")), React.createElement("li", null, "Avg Episode\x2FWeek ", React.createElement("span", {
        "className": "label raised indigo"
      }, "5")), React.createElement("li", null, "Avg Chapter\x2FWeek ", React.createElement("span", {
        "className": "label raised purple"
      }, "5")), React.createElement("li", null, "Avg Volume\x2FWeek ", React.createElement("span", {
        "className": "label raised pink"
      }, "5")))), React.createElement("div", {
        "className": "card grid indigo",
        "id": "card-news"
      }, React.createElement("div", {
        "className": "home-inline title"
      }, React.createElement("h1", null, "News"), React.createElement("button", {
        "type": "button",
        "className": "button indigo raised",
        "id": "btn-play"
      }, "View more on MAL")), React.createElement("ul", {
        "className": "yui-list news divider"
      }, React.createElement("li", null, " ", React.createElement("span", {
        "className": "label raised red"
      }, "Anime"), " Series Continuation of Senki Zesshou Symphogear Announced "), React.createElement("li", null, " ", React.createElement("span", {
        "className": "label raised red"
      }, "Anime"), " Horimiya Anime Never "), React.createElement("li", null, " ", React.createElement("span", {
        "className": "label raised indigo"
      }, "Music"), " Love Live! School Idol Project Group \u03bcs Wins Japan Gold Disc Awards "), React.createElement("li", null, " ", React.createElement("span", {
        "className": "label raised purple"
      }, "Events"), " Baccano and Oregairu Light Novels Part of Yen Presss New Line-Up "), React.createElement("li", null, " ", React.createElement("span", {
        "className": "label raised orange"
      }, "Manga"), " 4-koma Manga Nobunaga no Shinobi Gets TV Anime Adaptation "), React.createElement("li", null, " ", React.createElement("span", {
        "className": "label raised grey"
      }, "Industry"), " Anime Blu-ray and DVD sales rankings."))), React.createElement("div", {
        "className": "card grid currently-watching",
        "id": "card-cw"
      }, React.createElement("div", {
        "className": "title"
      }, React.createElement("div", {
        "className": "home-inline"
      }, React.createElement("h1", null, "Shirobako"), React.createElement("button", {
        "type": "button",
        "className": "button raised red"
      }, "Details")), React.createElement("span", {
        "id": "watching-genre"
      }, React.createElement("ul", null, React.createElement("li", null, "Comedy"), React.createElement("li", null, "Drama"), React.createElement("li", null, "Comedy"), React.createElement("li", null, "Drama"), React.createElement("li", null, "Comedy"), React.createElement("li", null, "Drama")))), React.createElement("div", {
        "className": "currently-watching-info"
      }, React.createElement("div", {
        "className": "watching-cover"
      }, React.createElement("img", {
        "src": "./../assets/images/cover1.jpg",
        "width": "150",
        "height": "225",
        "alt": ""
      }), React.createElement("button", {
        "type": "button",
        "className": "button raised lightblue"
      }, "Share")), React.createElement("div", {
        "className": "watching-info"
      }, React.createElement("span", {
        "className": "info-miniCards"
      }, React.createElement("div", {
        "className": "card pink"
      }, React.createElement("div", {
        "className": "title"
      }, React.createElement("p", {
        "className": "mini-card-title"
      }, "Score")), React.createElement("div", {
        "className": "score-select"
      }, "8.50", React.createElement("div", {
        "className": "score-dropdown card pink"
      }, React.createElement("ul", null, React.createElement("li", null, "1"), React.createElement("li", null, "2"), React.createElement("li", null, "3"), React.createElement("li", null, "4"), React.createElement("li", null, "5"), React.createElement("li", null, "6"), React.createElement("li", null, "7"), React.createElement("li", null, "8"), React.createElement("li", null, "9"), React.createElement("li", {
        "className": "selected"
      }, "10"))))), React.createElement("div", {
        "className": "card purple"
      }, React.createElement("div", {
        "className": "title"
      }, React.createElement("p", {
        "className": "mini-card-title"
      }, "Type")), React.createElement("p", null, "TV")), React.createElement("div", {
        "className": "card lightblue"
      }, React.createElement("div", {
        "className": "title"
      }, React.createElement("p", {
        "className": "mini-card-title"
      }, "Season")), React.createElement("p", null, "Fall 2014")), React.createElement("div", {
        "className": "card indigo"
      }, React.createElement("div", {
        "className": "title"
      }, React.createElement("p", {
        "className": "mini-card-title"
      }, "Episode")), React.createElement("p", null, "6\x2F24")), React.createElement("div", {
        "className": "card green"
      }, React.createElement("div", {
        "className": "title"
      }, React.createElement("p", {
        "className": "mini-card-title"
      }, "Group")), React.createElement("p", null, "Commie"))), React.createElement("p", null, "Shirobako begins with the five members of the Kaminoyama High School animation club all making a pledge to work hard on their very first amateur production and make it into a success. After showing it to an audience at a culture festival, that pledge\nturned into a huge dream - to move to Tokyo, get jobs in the anime industry and one day join hands to create something amazing.", React.createElement("br", null), " Fast forward two and a half years and two of those members, Aoi Miyamori and Ema Yasuhara, have made their dreams into reality by landing jobs at a famous production company called Musashino Animation. Everything seems perfect at first. However,\nas the girls slowly discover, the animation industry is a bit tougher than they had imagined. Who said making your dream come true was easy?")))), React.createElement("div", {
        "className": "card grid pink",
        "id": "card-soon"
      }, React.createElement("div", {
        "className": "home-inline title"
      }, React.createElement("h1", null, "Soon\u2122"), React.createElement("button", {
        "type": "button",
        "className": "button raised pink",
        "name": "button"
      }, "Calendar ", React.createElement("i", {
        "className": "ion-android-calendar"
      }))), React.createElement("ul", {
        "className": "yui-list divider"
      }, React.createElement("li", null, React.createElement("span", {
        "className": "label indigo"
      }, "20:00", React.createElement("p", {
        "className": "detail"
      }, "TUE")), " NEW GAME"), React.createElement("li", null, React.createElement("span", {
        "className": "label indigo"
      }, "20:00", React.createElement("p", {
        "className": "detail"
      }, "TUE")), " Kono Bijutsubu ni wa Mondai ga Aru!"), React.createElement("li", null, React.createElement("span", {
        "className": "label orange"
      }, "15:00", React.createElement("p", {
        "className": "detail"
      }, "TUE")), " Shokugeki no Soma"), React.createElement("li", null, React.createElement("span", {
        "className": "label raised orange"
      }, "22:00", React.createElement("p", {
        "className": "detail"
      }, "TUE")), " One Piece"), React.createElement("li", null, React.createElement("span", {
        "className": "label raised indigo"
      }, "06:00", React.createElement("p", {
        "className": "detail"
      }, "TUE")), " orange"), React.createElement("li", null, React.createElement("span", {
        "className": "label raised purple"
      }, "06:00", React.createElement("p", {
        "className": "detail"
      }, "HUE")), " Horimiya"))), React.createElement("div", {
        "className": "card grid continue-watching",
        "id": "card-cnw"
      }, React.createElement("div", {
        "className": "title home-inline"
      }, React.createElement("h1", null, "Continue Watching"), React.createElement("button", {
        "type": "button",
        "className": "button raised lightblue",
        "name": "button"
      }, "Anime List ", React.createElement("i", {
        "className": "ion-ios-list"
      }))), React.createElement("div", {
        "className": "recent-images"
      }, React.createElement("div", {
        "className": "card image-card"
      }, React.createElement("div", {
        "className": "watch-img"
      }, React.createElement("img", {
        "src": "./../assets/images/cover1.jpg",
        "width": "120",
        "height": "180",
        "alt": ""
      }), React.createElement("a", null, "Shirobako")), React.createElement("div", {
        "className": "watch-info"
      }, React.createElement("p", null, "Kono Bijutsubu ni wa Mondai ga Aru!"), React.createElement("span", {
        "className": "label indigo"
      }, "Episode 6 out of 12"), React.createElement("span", null, React.createElement("span", {
        "className": "label red"
      }, "TV"), React.createElement("span", {
        "className": "label teal"
      }, "7.42"), React.createElement("span", {
        "className": "label orange"
      }, "12 EPS")), React.createElement("button", {
        "type": "button",
        "className": "button raised indigo",
        "name": "button"
      }, "Details"), React.createElement("button", {
        "type": "button",
        "className": "button raised teal",
        "name": "button"
      }, "Play next episode"), React.createElement("button", {
        "type": "button",
        "className": "button raised green",
        "name": "button"
      }, "open folder"))))));
    }
  });

}).call(this);
