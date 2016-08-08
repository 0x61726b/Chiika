(function() {
  var React, ReactTabs, Tab, TabList, TabPanel, Tabs, _, _ref;

  React = require('react');

  _ = require('lodash');

  _ref = require('react-tabs'), ReactTabs = _ref.ReactTabs, Tab = _ref.Tab, Tabs = _ref.Tabs, TabList = _ref.TabList, TabPanel = _ref.TabPanel;

  module.exports = React.createClass({
    getInitialState: function() {
      return {
        tabList: [],
        tabDataSourceLenghts: [],
        gridColumnList: [],
        gridColumnData: [],
        currentTabIndex: 0,
        scrollData: [],
        view: {
          name: ''
        }
      };
    },
    currentGrid: null,
    scrollPending: false,
    componentWillReceiveProps: function(props) {
      var dataSourceLengths, tabCache;
      tabCache = chiika.viewManager.getTabSelectedIndexByName(props.route.view.name);
      if (this.state.view.name !== props.route.view.name) {
        this.state.currentTabIndex = tabCache.index;
      }
      dataSourceLengths = [];
      _.forEach(props.route.view.TabGridView.tabList, function(v, k) {
        var findInDataSource, name;
        name = v.name;
        findInDataSource = _.find(props.route.view.children, function(o) {
          return o.name === name + "_grid";
        });
        return dataSourceLengths.push(findInDataSource.dataSource.length);
      });
      return this.setState({
        tabList: props.route.view.TabGridView.tabList,
        gridColumnData: props.route.view.children,
        view: props.route.view,
        tabDataSourceLenghts: dataSourceLengths
      });
    },
    componentDidUpdate: function() {
      var scroll;
      this.updateGrid(this.state.tabList[this.state.currentTabIndex].name + "_grid");
      scroll = chiika.viewManager.getTabScrollAmount(this.state.view.name, this.state.currentTabIndex);
      return $(".objbox").scrollTop(scroll);
    },
    onSelect: function(index, last) {
      this.setState({
        currentTabIndex: index,
        lastTabIndex: last
      });
      return chiika.viewManager.onTabSelect(this.state.view.name, index, last);
    },
    updateGrid: function(name) {
      var column, columnAligns, columnIdsForDhtml, columnInitWidths, columnList, columnSorting, columnTextForDhtml, diff, fixedColumnsTotal, gridConf, gridData, headerAligns, i, totalArea, _i, _ref1;
      if (this.currentGrid != null) {
        this.currentGrid.clearAll();
        this.currentGrid = null;
      }
      this.currentGrid = new dhtmlXGridObject(name);
      columnList = this.state.view.TabGridView.gridColumnList;
      columnIdsForDhtml = "";
      columnTextForDhtml = "";
      columnInitWidths = "";
      columnAligns = "";
      columnSorting = "";
      headerAligns = [];
      if ($(".objbox").scrollHeight > $(".objbox").height()) {
        console.log("There is scrollbar");
        totalArea = $(".objbox").width() - 20;
      } else {
        totalArea = $(".objbox").width();
      }
      fixedColumnsTotal = 0;
      _.forEach(columnList, (function(_this) {
        return function(v, k) {
          if ((v.width != null) && !v.hidden) {
            return fixedColumnsTotal += parseInt(v.width);
          }
        };
      })(this));
      diff = totalArea - fixedColumnsTotal;
      _.forEach(columnList, (function(_this) {
        return function(v, k) {
          var calculatedWidth;
          if (!v.hidden) {
            columnIdsForDhtml += v.name + ",";
            columnTextForDhtml += v.display + ",";
            columnSorting += v.sort + ",";
            columnAligns += v.align + ",";
            headerAligns.push("text-align: " + v.headerAlign + ";");
            if (v.widthP != null) {
              calculatedWidth = diff * (v.widthP / 100);
              return columnInitWidths += calculatedWidth + ",";
            } else {
              return columnInitWidths += v.width + ",";
            }
          }
        };
      })(this));
      columnIdsForDhtml = columnIdsForDhtml.substring(0, columnIdsForDhtml.length - 1);
      columnTextForDhtml = columnTextForDhtml.substring(0, columnTextForDhtml.length - 1);
      columnInitWidths = columnInitWidths.substring(0, columnInitWidths.length - 1);
      columnSorting = columnSorting.substring(0, columnSorting.length - 1);
      columnAligns = columnAligns.substring(0, columnAligns.length - 1);
      this.currentGrid.setInitWidths(columnInitWidths);
      this.currentGrid.setColumnIds(columnIdsForDhtml);
      this.currentGrid.enableAutoWidth(true);
      this.currentGrid.setHeader(columnTextForDhtml, null, headerAligns);
      this.currentGrid.setColTypes(columnIdsForDhtml);
      this.currentGrid.setColAlign(columnAligns);
      this.currentGrid.setColSorting(columnSorting);
      this.currentGrid.enableMultiselect(true);
      gridData = _.find(this.state.gridColumnData, function(o) {
        return o.name === name;
      });
      gridConf = {
        data: gridData.dataSource
      };
      this.currentGrid.init();
      this.currentGrid.parse(gridConf, "js");
      this.currentGrid.filterBy(1, $(".form-control").val());
      for (i = _i = 0, _ref1 = columnList.length; 0 <= _ref1 ? _i < _ref1 : _i > _ref1; i = 0 <= _ref1 ? ++_i : --_i) {
        column = columnList[i];
        if (!column.hidden && (column.customSort != null)) {
          this.currentGrid.setCustomSorting(window.sortFunctions[v.customSort], i);
        }
      }
      $(".form-control").on('input', (function(_this) {
        return function(e) {
          return _this.currentGrid.filterBy(1, e.target.value);
        };
      })(this));
      this.currentGrid.attachEvent('onRowDblClicked', function(rId, cInd) {
        var find, _j, _ref2, _results;
        _results = [];
        for (i = _j = 0, _ref2 = gridConf.data.length; 0 <= _ref2 ? _j < _ref2 : _j > _ref2; i = 0 <= _ref2 ? ++_j : --_j) {
          if (i === rId - 1) {
            find = gridConf.data[i];
            _results.push(window.location = "#details/" + find.mal_id);
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      });
      $(window).resize((function(_this) {
        return function() {
          var v, width, _j, _ref2, _results;
          if (_this.currentGrid != null) {
            if ($(".objbox")[0].scrollHeight > $(".objbox").height()) {
              totalArea = $(".objbox").width() - 8;
            } else {
              totalArea = $(".objbox").width();
            }
            fixedColumnsTotal = 0;
            _.forEach(_this.state.view.TabGridView.gridColumnList, function(v, k) {
              if ((v.width != null) && !v.hidden) {
                return fixedColumnsTotal += parseInt(v.width);
              }
            });
            diff = totalArea - fixedColumnsTotal;
            _results = [];
            for (i = _j = 0, _ref2 = _this.state.view.TabGridView.gridColumnList.length; 0 <= _ref2 ? _j < _ref2 : _j > _ref2; i = 0 <= _ref2 ? ++_j : --_j) {
              v = _this.state.view.TabGridView.gridColumnList[i];
              if (!v.hidden) {
                width = 0;
                if (v.widthP != null) {
                  width = diff * (v.widthP / 100);
                } else {
                  width = v.width;
                }
                _results.push(_this.currentGrid.setColWidth(i, width));
              } else {
                _results.push(void 0);
              }
            }
            return _results;
          }
        };
      })(this));
      return $(window).trigger('resize');
    },
    componentWillUnmount: function() {
      var scroll;
      chiika.viewManager.onTabViewUnmount(this.state.view.name, this.state.currentTabIndex);
      scroll = chiika.viewManager.getTabScrollAmount(this.state.view.name, this.state.currentTabIndex);
      if (this.currentGrid != null) {
        $(".form-control").off('input');
        this.currentGrid.clearAll();
        return this.currentGrid = null;
      }
    },
    render: function() {
      return React.createElement(Tabs, {
        "selectedIndex": this.state.currentTabIndex,
        "onSelect": this.onSelect
      }, React.createElement(TabList, null, this.state.tabList.map((function(_this) {
        return function(tab, i) {
          return React.createElement(Tab, {
            "key": i
          }, tab.display, " ", React.createElement("span", {
            "className": "label raised theme-accent"
          }, _this.state.tabDataSourceLenghts[i]));
        };
      })(this))), this.state.tabList.map((function(_this) {
        return function(tab, i) {
          return React.createElement(TabPanel, {
            "key": i
          }, React.createElement("div", {
            "id": "" + tab.name + "_grid",
            "className": "listCommon"
          }));
        };
      })(this)));
    }
  });

}).call(this);
