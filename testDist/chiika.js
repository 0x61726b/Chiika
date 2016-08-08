(function() {
  var BrowserHistory, CardView, ChiikaRouter, Content, DetailsCardView, Home, LoadingScreen, React, Route, Router, RouterContainer, Settings, SideMenu, TabGridView, Titlebar, _ref;

  React = require('react');

  _ref = require('react-router'), Router = _ref.Router, Route = _ref.Route, BrowserHistory = _ref.BrowserHistory;

  SideMenu = require('./side-menu');

  Titlebar = require('./titlebar');

  Settings = require('./settings');

  LoadingScreen = require('./loading-screen');

  Home = require('./home');

  TabGridView = require('./view-tabGrid');

  CardView = require('./card-view');

  DetailsCardView = require('./card-view-details');

  Content = React.createClass({
    componentDidMount: function() {},
    render: function() {
      return React.createElement("div", {
        "className": "main"
      }, React.createElement("div", {
        "id": "titleBar"
      }, React.createElement(Titlebar, null)), React.createElement("div", {
        "className": "content"
      }, this.props.props.children), React.createElement("div", {
        "id": "settings"
      }, React.createElement(Settings, null)));
    }
  });

  RouterContainer = React.createClass({
    render: function() {
      return React.createElement("div", {
        "id": "appMain"
      }, React.createElement(SideMenu, {
        "props": this.props
      }), React.createElement(Content, {
        "props": this.props
      }));
    }
  });

  ChiikaRouter = React.createClass({
    routes: [],
    currentRouteName: null,
    getInitialState: function() {
      return {
        test: false,
        uiData: chiika.uiData,
        routerConfig: this.getRoutes(chiika.uiData)
      };
    },
    getRoutes: function(uiData) {
      var detailsLayout, dl, route, routerConfig, routes, testCards, _i, _len;
      routes = [];
      uiData.map((function(_this) {
        return function(route, i) {
          if (route.displayType === "TabGridView") {
            return routes.push({
              name: "/" + route.name,
              path: "/" + route.name,
              component: require(chiika.viewManager.getComponent(route.displayType)),
              view: route,
              onEnter: _this.onEnter
            });
          }
        };
      })(this));
      testCards = [];
      testCards.push(chiika.cardManager.getCard('typeMiniCard'));
      testCards.push(chiika.cardManager.getCard('seasonMiniCard'));
      testCards.push(chiika.cardManager.getCard('episodeMiniCard'));
      testCards.push(chiika.cardManager.getCard('studioMiniCard'));
      testCards.push(chiika.cardManager.getCard('sourceMiniCard'));
      detailsLayout = {
        title: "Nisekoi",
        genres: "Romcom,Comedy,Romance",
        list: true,
        synopsis: 'test',
        cover: './../assets/images/nisekoi.jpg',
        characters: [
          {
            name: 'Chitoge',
            image: './../assets/images/chitoge.png'
          }, {
            name: 'Kosaki',
            image: './../assets/images/kosaki.png'
          }, {
            name: 'Raku',
            image: './../assets/images/raku.png'
          }
        ],
        actionButtons: [
          {
            name: 'Torrent',
            action: 'torrent',
            color: 'lightblue'
          }, {
            name: 'Library',
            action: 'library',
            color: 'purple'
          }, {
            name: 'Play Next',
            action: 'playnext',
            color: 'teal'
          }, {
            name: 'Search',
            action: 'search',
            color: 'green'
          }
        ],
        scoring: {
          type: 'normal',
          userScore: '8'
        },
        miniCards: testCards
      };
      dl = {
        title: "Re:zero season 2",
        genres: "Drama,fantasy,thriller",
        list: false,
        synopsis: 'Subaru kun having fun with girls Rem,Ram and Emilia.',
        cover: './../assets/images/rezero.jpg',
        characters: [
          {
            name: 'Chitoge',
            image: './../assets/images/chitoge.png'
          }, {
            name: 'Kosaki',
            image: './../assets/images/kosaki.png'
          }, {
            name: 'Raku',
            image: './../assets/images/raku.png'
          }
        ],
        actionButtons: [
          {
            name: 'Torrent',
            action: 'torrent',
            color: 'lightblue'
          }, {
            name: 'Library',
            action: 'library',
            color: 'purple'
          }, {
            name: 'Play Next',
            action: 'playnext',
            color: 'teal'
          }, {
            name: 'Search',
            action: 'search',
            color: 'green'
          }
        ],
        scoring: {
          type: 'normal',
          userScore: '8'
        },
        miniCards: testCards
      };
      routerConfig = {
        component: RouterContainer,
        childRoutes: [
          {
            name: 'Home',
            path: '/Home',
            component: Home,
            onEnter: this.onEnter
          }, {
            name: 'CardTest',
            path: '/CardTest',
            component: CardView,
            onEnter: this.onEnter,
            cards: testCards
          }, {
            name: 'DetailsCardTest',
            path: '/DetailsCardTest',
            component: DetailsCardView,
            onEnter: this.onEnter,
            layout: detailsLayout
          }, {
            name: 'DetailsCardTest2',
            path: '/DetailsCardTest2',
            component: DetailsCardView,
            onEnter: this.onEnter,
            layout: dl
          }, {
            name: 'Details',
            path: '/details/:id',
            component: DetailsCardView,
            onEnter: this.onEnter
          }
        ]
      };
      for (_i = 0, _len = routes.length; _i < _len; _i++) {
        route = routes[_i];
        routerConfig.childRoutes.push(route);
      }
      return routerConfig;
    },
    componentDidMount: function() {
      var routerConfig;
      this.setState({
        routerConfig: this.getRoutes(chiika.uiData)
      });
      chiika.ipc.refreshUIData((function(_this) {
        return function(args) {
          var routerConfig;
          routerConfig = _this.state.routerConfig;
          _.forEach(args, function(v, k) {
            var findChildRoute;
            findChildRoute = _.find(routerConfig.childRoutes, function(o) {
              return o.name === '/' + v.name;
            });
            if (findChildRoute != null) {
              return findChildRoute.view = v;
            }
          });
          return _this.setState({
            routerConfig: routerConfig
          });
        };
      })(this));
      routerConfig = this.state.routerConfig;
      _.forEach(this.state.uiData, (function(_this) {
        return function(v, k) {
          var findChildRoute;
          findChildRoute = _.find(routerConfig.childRoutes, function(o) {
            return o.name === this.currentRouteName;
          });
          if (findChildRoute != null) {
            return findChildRoute.view = v;
          }
        };
      })(this));
      return this.setState({
        routerConfig: routerConfig
      });
    },
    componentDidUpdate: function() {
      return this.state.uiDataChanged = false;
    },
    onEnter: function(nextState) {
      var path, routerConfig;
      path = nextState.routes[1].name;
      routerConfig = this.state.routerConfig;
      this.currentRouteName = nextState.location.pathname;
      return routerConfig = this.state.routerConfig;
    },
    render: function() {
      return React.createElement(Router, {
        "history": BrowserHistory,
        "routes": this.state.routerConfig
      });
    }
  });

  module.exports = ChiikaRouter;

}).call(this);
