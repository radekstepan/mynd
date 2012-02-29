(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __slice = Array.prototype.slice;

  window.Widgets = (function() {

    function Widgets(service) {
      this.service = service;
      this.loadEnrichmentWidget = __bind(this.loadEnrichmentWidget, this);
      this.loadGraphWidget = __bind(this.loadGraphWidget, this);
      this.displayEnrichmentWidgetConfig = __bind(this.displayEnrichmentWidgetConfig, this);
      this.displayGraphWidgetConfig = __bind(this.displayGraphWidgetConfig, this);
    }

    Widgets.prototype.CHART_OPTS = {
      fontName: "Sans-Serif",
      fontSize: 9,
      width: 400,
      height: 450,
      legend: "bottom",
      colors: ["#2F72FF", "#9FC0FF"],
      chartArea: {
        top: 30
      }
    };

    Widgets.prototype.displayGraphWidgetConfig = function(widgetId, domainLabel, rangeLabel, seriesLabels, seriesValues, bagName, target) {
      var extraAttr, wsCall,
        _this = this;
      target = $(target);
      target.find("div.data").hide();
      target.find("div.noresults").hide();
      target.find("div.wait").show();
      extraAttr = this.getExtraValue(target);
      return wsCall = (function(token) {
        var request_data;
        if (token == null) token = "";
        request_data = {
          widget: widgetId,
          list: bagName,
          filter: extraAttr,
          token: token
        };
        return $.getJSON(_this.service + "list/chart", request_data, function(res) {
          var Chart, data, options, pathQuery, targetElem, viz;
          if (res.results.length !== 0) {
            viz = google.visualization;
            data = google.visualization.arrayToDataTable(res.results, false);
            targetElem = target[0];
            Chart = null;
            options = $.extend({}, _this.CHART_OPTS, {
              title: res.title
            });
            switch (res.chartType) {
              case "ColumnChart":
                Chart = viz.ColumnChart;
                break;
              case "BarChart":
                Chart = viz.BarChart;
                break;
              case "ScatterPlot":
                Chart = viz.ScatterChart;
                break;
              case "PieChart":
                Chart = viz.PieChart;
                break;
              case "XYLineChart":
                Chart = viz.LineChart;
            }
            if (domainLabel) {
              $.extend(options, {
                hAxis: {
                  title: rangeLabel,
                  titleTextStyle: {
                    fontName: "Sans-Serif"
                  }
                }
              });
            }
            if (rangeLabel) {
              $.extend(options, {
                vAxis: {
                  title: domainLabel,
                  titleTextStyle: {
                    fontName: "Sans-Serif"
                  }
                }
              });
            }
            viz = void 0;
            if (Chart) {
              viz = new Chart(targetElem);
              viz.draw(data, options);
              pathQuery = res.pathQuery;
              google.visualization.events.addListener(viz, "select", function() {
                var category, i, item, pathQueryWithConstraintValues, selection, series, seriesValue, _results;
                selection = viz.getSelection();
                i = 0;
                _results = [];
                while (i < selection.length) {
                  item = selection[i];
                  if ((item.row != null) && (item.column != null)) {
                    category = res.results[item.row + 1][0];
                    series = res.results[0][item.column];
                    seriesValue = getSeriesValue(series, seriesLabels, seriesValues);
                    pathQueryWithConstraintValues = pathQuery.replace("%category", category);
                    pathQueryWithConstraintValues = pathQueryWithConstraintValues.replace("%series", seriesValue);
                    window.open(this.service + "query/results?query=" + pathQueryWithConstraintValues + "&format=html");
                  } else if (item.row != null) {
                    category = res.results[item.row + 1][0];
                    pathQuery = pathQuery.replace("%category", category);
                    window.open(this.service + "query/results?query=" + pathQuery + "&format=html");
                  }
                  _results.push(i++);
                }
                return _results;
              });
            } else {
              alert("Don't know how to draw " + res.chartType + "s yet!");
            }
            target.find("div.data").show();
          } else {
            target.find("div.noresults").show();
          }
          target.find("div.wait").hide();
          return target.find("div.notanalysed").text(res.notAnalysed);
        });
      })();
    };

    Widgets.prototype.getSeriesValue = function(seriesLabel, seriesLabels, seriesValues) {
      var arraySeriesLabels, arraySeriesValues, i;
      arraySeriesLabels = seriesLabels.split(",");
      arraySeriesValues = seriesValues.split(",");
      i = 0;
      while (i < arraySeriesLabels.length) {
        if (seriesLabel === arraySeriesLabels[i]) return arraySeriesValues[i];
        i++;
      }
    };

    Widgets.prototype.displayEnrichmentWidgetConfig = function(widgetId, label, bagName, target) {
      var errorCorrection, extraAttr, max, wsCall,
        _this = this;
      target = $(target);
      target.find("div.data").hide();
      target.find("div.noresults").hide();
      target.find("div.wait").show();
      errorCorrection = target.find("div.errorcorrection").valueif(target.find("div.errorcorrection").length > 0);
      if (target.find("div.max").length > 0) max = target.find("div.max").value;
      extraAttr = getExtraValue(target);
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

    Widgets.prototype.getExtraValue = function(target) {
      var extraAttr;
      if (target.find("select.select").length > 0) {
        return extraAttr = target.find("select.select").value;
      }
    };

    Widgets.prototype.make_enrichment_row = function(result, externalLink, externalLinkLabel) {
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

    Widgets.prototype.loadGraphWidget = function(id, domainLabel, rangeLabel, seriesLabels, seriesValues, bagName, target) {
      var _this = this;
      return google.setOnLoadCallback(function() {
        return _this.displayGraphWidgetConfig(id, domainLabel, rangeLabel, seriesLabels, seriesValues, bagName, target);
      });
    };

    Widgets.prototype.loadEnrichmentWidget = function(id, domainLabel, rangeLabel, seriesLabels, seriesValues, bagName, target) {
      var _this = this;
      return google.setOnLoadCallback(function() {
        return _this.displayEnrichmentWidgetConfig(id, label, bagName, target);
      });
    };

    google.load("visualization", "1.0", {
      packages: ["corechart"]
    });

    Widgets.prototype.loadGraph = function() {
      var opts;
      opts = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return this.loadGraphWidget.apply(this, opts);
    };

    Widgets.prototype.loadEnrichment = function() {
      var opts;
      opts = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return this.loadEnrichmentWidget.apply(this, opts);
    };

    return Widgets;

  })();

}).call(this);
