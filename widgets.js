(function() {
  var EnrichmentWidget, GraphWidget, InterMineWidget,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __slice = Array.prototype.slice;

  InterMineWidget = (function() {

    function InterMineWidget() {}

    InterMineWidget.prototype.chartOptions = {
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

    return InterMineWidget;

  })();

  GraphWidget = (function(_super) {

    __extends(GraphWidget, _super);

    GraphWidget.prototype.templates = {
      normal: "<h3><%= id %></h3>\n<p><%= description %></p>\n<% if (notAnalysed > 0) { %>\n    <p>Number of Genes in this list not analysed in this widget: <%= notAnalysed %></p>\n<% } %>\n<div class=\"widget\"></div>",
      noresults: "<p>The widget has no results.</p>"
    };

    function GraphWidget(service, id, bagName, el, domainLabel, rangeLabel, series) {
      var _this = this;
      this.service = service;
      this.id = id;
      this.bagName = bagName;
      this.el = el;
      this.render = __bind(this.render, this);
      this.options = {
        "domainLabel": domainLabel,
        "rangeLabel": rangeLabel,
        "series": series
      };
      google.setOnLoadCallback(function() {
        return _this.render();
      });
    }

    GraphWidget.prototype.render = function() {
      var _this = this;
      return $.getJSON(this.service + "list/chart", {
        widget: this.id,
        list: this.bagName,
        filter: $(this.el).find("select.select").value || "",
        token: ""
      }, function(response) {
        var chart;
        if (response.results) {
          $(_this.el).html(_.template(_this.templates.normal, {
            "id": _this.id,
            "description": response.description,
            "notAnalysed": response.notAnalysed
          }));
          _this.chartOptions.title = response.title;
          if (_this.options.domainLabel != null) {
            _this.chartOptions.hAxis.title = _this.options.domainLabel;
          }
          if (_this.options.rangeLabel != null) {
            _this.chartOptions.vAxis.title = _this.options.rangeLabel;
          }
          chart = new google.visualization[response.chartType]($(_this.el).find("div.widget")[0]);
          chart.draw(google.visualization.arrayToDataTable(response.results, false), _this.chartOptions);
          if (response.pathQuery != null) {
            return google.visualization.events.addListener(chart, "select", function() {
              var item, _i, _len, _ref, _results;
              _ref = chart.getSelection();
              _results = [];
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                item = _ref[_i];
                if (item.row != null) {
                  if (item.column != null) {} else {

                  }
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

    return GraphWidget;

  })(InterMineWidget);

  EnrichmentWidget = (function(_super) {

    __extends(EnrichmentWidget, _super);

    function EnrichmentWidget() {
      this.load = __bind(this.load, this);
      this.displayEnrichmentWidgetConfig = __bind(this.displayEnrichmentWidgetConfig, this);
      EnrichmentWidget.__super__.constructor.apply(this, arguments);
    }

    EnrichmentWidget.prototype.displayEnrichmentWidgetConfig = function(widgetId, label, bagName, target) {
      var errorCorrection, max, wsCall, _ref,
        _this = this;
      target = $(target);
      target.find("div.data").hide();
      target.find("div.noresults").hide();
      target.find("div.wait").show();
      errorCorrection = target.find("div.errorcorrection").valueif(target.find("div.errorcorrection").length > 0);
      if (target.find("div.max").length > 0) max = target.find("div.max").value;
      if (typeof extraAttr === "undefined" || extraAttr === null) {
        extraAttr = (_ref = this.el.find("select.select")) != null ? _ref.value : void 0;
      }
      return wsCall = (function(tokenId) {
        var request_data;
        if (tokenId == null) tokenId = "";
        request_data = {
          widget: widgetId,
          list: bagName,
          correction: errorCorrection,
          maxp: max,
          filter: extraAttr,
          token: tokenId
        };
        return $.getJSON(_this.service + "list/enrichment", request_data, function(res) {
          var $table, columns, externalLink, externalLinkLabel, i, results;
          target.find("table.tablewidget thead").html("");
          target.find("table.tablewidget tbody").html("");
          results = res.results;
          if (results.length !== 0) {
            columns = [label, "p-Value", "Matches"];
            createTableHeader(widgetId, columns);
            $table = target.find("table.tablewidget tbody");
            i = 0;
            if (target.find("div.externallink").length > 0) {
              externalLink = target.find("div.externallink").value;
            }
            if (target.find("div.externallabel").length > 0) {
              externalLinkLabel = target.find("div.externallabel").value;
            }
            for (i in results) {
              $table.append(make_enrichment_row(results[i], externalLink, externalLinkLabel));
            }
            target.find("div.data").show();
          } else {
            target.find("div.noresults").show();
          }
          target.find("div.wait").hide();
          return calcNotAnalysed(widgetId, res.notAnalysed);
        });
      })();
    };

    EnrichmentWidget.prototype.make_enrichment_row = function(result, externalLink, externalLinkLabel) {
      var $a, $checkBox, $count, $list, $matches, $row, $td, i, label;
      $row = $("<tr>");
      $checkBox = $("<input />").attr({
        type: "checkbox",
        id: "selected_" + result.item,
        value: result.item,
        name: "selected"
      });
      $row.append($("<td>").append($checkBox));
      if (result.description) {
        $td = $("<td>").text(result.description + " ");
        if (externalLink) {
          if (externalLinkLabel !== void 0) {
            label = externalLinkLabel + result.item;
          }
          label = label + result.item;
          $a = $("<a>").addClass("extlink").text("[" + label + "]");
          $a.attr({
            target: "_new",
            href: externalLink + result.item
          });
          $td.append($a);
        }
        $row.append($td);
      } else {
        $row.append($("<td>").html("<em>no description</em>"));
      }
      $row.append($("<td>").text(result["p-value"]));
      $count = $("<span>").addClass("match-count").text(result.matches.length);
      $matches = $("<div>");
      $matches.css({
        display: "none"
      });
      $list = $("<ul>");
      i = 0;
      for (i in result.matches) {
        $list.append($("<li>").text(result.matches[i]));
      }
      $matches.append($list);
      $count.append($matches);
      $count.click(function() {
        return $matches.slideToggle();
      });
      $row.append($("<td>").append($count));
      return $row;
    };

    EnrichmentWidget.prototype.load = function(id, domainLabel, rangeLabel, seriesLabels, seriesValues, bagName, target) {
      var _this = this;
      return google.setOnLoadCallback(function() {
        return _this.displayEnrichmentWidgetConfig(id, label, bagName, target);
      });
    };

    return EnrichmentWidget;

  })(InterMineWidget);

  window.Widgets = (function() {

    google.load("visualization", "1.0", {
      packages: ["corechart"]
    });

    function Widgets(service) {
      this.service = service;
      this.enrichment = __bind(this.enrichment, this);
      this.graph = __bind(this.graph, this);
    }

    Widgets.prototype.graph = function() {
      var opts;
      opts = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return (function(func, args, ctor) {
        ctor.prototype = func.prototype;
        var child = new ctor, result = func.apply(child, args);
        return typeof result === "object" ? result : child;
      })(GraphWidget, [this.service].concat(__slice.call(opts)), function() {});
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

    return Widgets;

  })();

}).call(this);
