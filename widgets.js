(function() {
  var ChartWidget, EnrichmentWidget, InterMineWidget,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __slice = Array.prototype.slice,
    __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  InterMineWidget = (function() {

    function InterMineWidget() {
      $(this.el).html($('<div/>', {
        "class": "inner",
        style: "height:572px;overflow:hidden"
      }));
      this.el = "" + this.el + " div.inner";
    }

    return InterMineWidget;

  })();

  ChartWidget = (function(_super) {

    __extends(ChartWidget, _super);

    ChartWidget.prototype.chartOptions = {
      fontName: "Sans-Serif",
      fontSize: 9,
      width: 400,
      height: 450,
      legend: "bottom",
      colors: ["#2F72FF", "#9FC0FF"],
      chartArea: {
        top: 30
      },
      hAxis: {
        titleTextStyle: {
          fontName: "Sans-Serif"
        }
      },
      vAxis: {
        titleTextStyle: {
          fontName: "Sans-Serif"
        }
      }
    };

    ChartWidget.prototype.templates = {
      normal: "<header>\n    <% if (title) { %>\n        <h3><%= title %></h3>\n    <% } %>\n    <% if (description) { %>\n        <p><%= description %></p>\n    <% } %>\n    <% if (notAnalysed > 0) { %>\n        <p>Number of Genes in this list not analysed in this widget: <span class=\"label label-info\"><%= notAnalysed %></span></p>\n    <% } %>\n</header>\n<div class=\"content\"></div>",
      noresults: "<p>The widget has no results.</p>"
    };

    function ChartWidget(service, id, bagName, el, widgetOptions) {
      var _this = this;
      this.service = service;
      this.id = id;
      this.bagName = bagName;
      this.el = el;
      this.widgetOptions = widgetOptions != null ? widgetOptions : {
        "title": true,
        "description": true,
        "selectCb": function(pq) {
          return console.log(pq);
        }
      };
      this.render = __bind(this.render, this);
      ChartWidget.__super__.constructor.call(this);
      google.setOnLoadCallback(function() {
        return _this.render();
      });
    }

    ChartWidget.prototype.render = function() {
      var _this = this;
      return $.getJSON("" + this.service + "list/chart", {
        widget: this.id,
        list: this.bagName,
        filter: "",
        token: ""
      }, function(response) {
        var chart;
        if (response.results) {
          $(_this.el).html(_.template(_this.templates.normal, {
            "title": _this.widgetOptions.title ? response.title : "",
            "description": _this.widgetOptions.description ? response.description : "",
            "notAnalysed": response.notAnalysed
          }));
          chart = new google.visualization[response.chartType]($(_this.el).find("div.content")[0]);
          chart.draw(google.visualization.arrayToDataTable(response.results, false), _this.chartOptions);
          if (response.pathQuery != null) {
            return google.visualization.events.addListener(chart, "select", function() {
              var item, pq, _i, _len, _ref, _results;
              pq = response.pathQuery;
              _ref = chart.getSelection();
              _results = [];
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                item = _ref[_i];
                if (item.row != null) {
                  pq = pq.replace("%category", response.results[item.row + 1][0]);
                  if (item.column != null) {
                    pq = pq.replace("%series", response.results[0][item.column]);
                  }
                  _results.push(_this.widgetOptions.selectCb(pq));
                } else {
                  _results.push(void 0);
                }
              }
              return _results;
            });
          }
        } else {
          return $(_this.el).html(_.template(_this.templates.noresults));
        }
      });
    };

    return ChartWidget;

  })(InterMineWidget);

  EnrichmentWidget = (function(_super) {

    __extends(EnrichmentWidget, _super);

    EnrichmentWidget.prototype.formOptions = {
      errorCorrection: "Holm-Bonferroni",
      pValue: 0.05,
      dataSet: "All datasets"
    };

    EnrichmentWidget.prototype.errorCorrections = ["Holm-Bonferroni", "Benjamini Hochberg", "Bonferroni", "None"];

    EnrichmentWidget.prototype.pValues = [0.05, 0.10, 1.00];

    EnrichmentWidget.prototype.templates = {
      normal: "<header>\n    <% if (title) { %>\n        <h3><%= title %></h3>\n    <% } %>\n    <% if (description) { %>\n        <p><%= description %></p>\n    <% } %>\n    <% if (notAnalysed > 0) { %>\n        <p>Number of Genes in this list not analysed in this widget: <span class=\"label label-info\"><%= notAnalysed %></span></p>\n    <% } %>\n    <div class=\"form\"></div>\n</header>\n<div class=\"content\" style=\"overflow:auto;overflow-x:hidden;height:400px\"></div>",
      form: "<form>\n    <label>Multiple Hypothesis Test Correction</label>\n    <select name=\"errorCorrection\" class=\"input-medium\">\n        <% for (var i = 0; i < errorCorrections.length; i++) { %>\n            <% var correction = errorCorrections[i] %>\n            <option value=\"<%= correction %>\" <%= (options.errorCorrection == correction) ? 'selected=\"selected\"' : \"\" %>><%= correction %></option>\n        <% } %>\n    </select>\n\n    <label>Maximum value to display</label>\n    <select name=\"pValue\" class=\"input-small\">\n        <% for (var i = 0; i < pValues.length; i++) { %>\n            <% var p = pValues[i] %>\n            <option value=\"<%= p %>\" <%= (options.pValue == p) ? 'selected=\"selected\"' : \"\" %>><%= p %></option>\n        <% } %>\n    </select>\n\n    <label>DataSet</label>\n    <select name=\"dataSet\" class=\"input-medium\">\n        <option value=\"All datasets\" selected=\"selected\">All datasets</option>\n    </select>\n</form>",
      table: "<table class=\"table table-striped\">\n    <thead>\n        <tr>\n            <th><%= label %></th>\n            <th>p-Value</th>\n            <th>Matches</th>\n        </tr>\n    </thead>\n    <tbody></tbody>\n</table>",
      row: "<tr>\n    <td class=\"description\"><%= row[\"description\"] %></td>\n    <td class=\"pValue\"><%= row[\"p-value\"].toFixed(7) %></td>\n    <td class=\"matches\" style=\"position:relative\">\n        <span class=\"count label label-success\" style=\"cursor:pointer\"><%= row[\"matches\"].length %></span>\n    </td>\n</tr>",
      matches: "<div class=\"popover\" style=\"position:absolute;top:22px;right:0;z-index:1;display:block\">\n    <div class=\"popover-inner\" style=\"width:300px;margin-left:-300px\">\n        <a style=\"cursor:pointer;margin:2px 5px 0 0\" class=\"close\">×</a>\n        <h3 class=\"popover-title\"></h3>\n        <div class=\"popover-content\">\n            <% for (var i = 0; i < matches.length; i++) { %>\n                <a href=\"#\"><%= matches[i] %></a><%= (i < matches.length -1) ? \",\" : \"\" %>\n            <% } %>\n        </div>\n    </div>\n</div>",
      noresults: "<p>The widget has no results.</p>"
    };

    function EnrichmentWidget(service, id, bagName, el, widgetOptions) {
      this.service = service;
      this.id = id;
      this.bagName = bagName;
      this.el = el;
      this.widgetOptions = widgetOptions != null ? widgetOptions : {
        "title": true,
        "description": true
      };
      this.matchesClick = __bind(this.matchesClick, this);
      this.formClick = __bind(this.formClick, this);
      this.render = __bind(this.render, this);
      EnrichmentWidget.__super__.constructor.call(this);
      this.render();
    }

    EnrichmentWidget.prototype.render = function() {
      var _this = this;
      return $.getJSON("" + this.service + "list/enrichment", {
        widget: this.id,
        list: this.bagName,
        correction: this.formOptions.errorCorrection,
        maxp: this.formOptions.pValue,
        filter: this.formOptions.dataSet,
        token: ""
      }, function(response) {
        var height, row, table, _fn, _i, _len, _ref;
        if (response.results) {
          $(_this.el).html(_.template(_this.templates.normal, {
            "title": _this.widgetOptions.title ? response.title : "",
            "description": _this.widgetOptions.description ? response.description : "",
            "notAnalysed": response.notAnalysed
          }));
          $(_this.el).find("div.form").html(_.template(_this.templates.form, {
            "options": _this.formOptions,
            "errorCorrections": _this.errorCorrections,
            "pValues": _this.pValues
          }));
          height = $(_this.el).height() - $(_this.el).find('header').height() - 18;
          $(_this.el).find("div.content").html($(_.template(_this.templates.table, {
            "label": response.label
          }))).css("height", "" + height + "px");
          table = $(_this.el).find("div.content table");
          _ref = response.results;
          _fn = function(row) {
            var td, tr;
            table.append(tr = $(_.template(_this.templates.row, {
              "row": row
            })));
            return td = tr.find("td.matches .count").click(function() {
              return _this.matchesClick(td, row["matches"]);
            });
          };
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            row = _ref[_i];
            _fn(row);
          }
          return $(_this.el).find("form select").change(_this.formClick);
        } else {
          return $(_this.el).html(_.template(_this.templates.noresults));
        }
      });
    };

    EnrichmentWidget.prototype.formClick = function(e) {
      this.formOptions[$(e.target).attr("name")] = $(e.target[e.target.selectedIndex]).attr("value");
      return this.render();
    };

    EnrichmentWidget.prototype.matchesClick = function(target, matches) {
      var modal;
      target.after(modal = $(_.template(this.templates.matches, {
        "matches": matches
      })));
      return modal.find("a.close").click(function() {
        return modal.remove();
      });
    };

    return EnrichmentWidget;

  })(InterMineWidget);

  window.Widgets = (function() {

    function Widgets(service) {
      this.service = service;
      this.all = __bind(this.all, this);
      this.enrichment = __bind(this.enrichment, this);
      this.chart = __bind(this.chart, this);
      if (!(window.jQuery != null)) throw "jQuery not loaded";
      if (!(window._ != null)) throw "underscore.js not loaded";
      if (!(window.google != null)) throw "Google API not loaded";
    }

    Widgets.prototype.chart = function() {
      var opts;
      opts = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      google.load("visualization", "1.0", {
        packages: ["corechart"]
      });
      return (function(func, args, ctor) {
        ctor.prototype = func.prototype;
        var child = new ctor, result = func.apply(child, args);
        return typeof result === "object" ? result : child;
      })(ChartWidget, [this.service].concat(__slice.call(opts)), function() {});
    };

    Widgets.prototype.enrichment = function() {
      var opts;
      opts = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return (function(func, args, ctor) {
        ctor.prototype = func.prototype;
        var child = new ctor, result = func.apply(child, args);
        return typeof result === "object" ? result : child;
      })(EnrichmentWidget, [this.service].concat(__slice.call(opts)), function() {});
    };

    Widgets.prototype.all = function(type, bagName, el, widgetOptions) {
      var _this = this;
      if (type == null) type = "Gene";
      return $.getJSON("" + this.service + "widgets", function(response) {
        var widget, widgetEl, _i, _len, _ref, _results;
        if (response.widgets) {
          _ref = response.widgets;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            widget = _ref[_i];
            if (!(__indexOf.call(widget.targets, type) >= 0)) continue;
            widgetEl = widget.name.replace(/[^-a-zA-Z0-9,&\s]+/ig, '').replace(/-/gi, "_").replace(/\s/gi, "-").toLowerCase();
            $(el).append($('<div/>', {
              id: widgetEl,
              "class": "widget span6"
            }));
            switch (widget.widgetType) {
              case "chart":
                _results.push(new ChartWidget(_this.service, widget.name, bagName, "#" + el + " #" + widgetEl, widgetOptions));
                break;
              case "enrichment":
                _results.push(new EnrichmentWidget(_this.service, widget.name, bagName, "#" + el + " #" + widgetEl, widgetOptions));
                break;
              default:
                _results.push(void 0);
            }
          }
          return _results;
        }
      });
    };

    return Widgets;

  })();

}).call(this);
