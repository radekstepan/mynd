(function() {

  window.Widgets = function(service) {
    var CHART_OPTS, displayEnrichmentWidgetConfig, displayGraphWidgetConfig, getExtraValue, getSeriesValue, loadEnrichmentWidget, loadGraphWidget, make_enrichment_row;
    CHART_OPTS = {
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
    displayGraphWidgetConfig = function(widgetId, domainLabel, rangeLabel, seriesLabels, seriesValues, bagName, target) {
      var extraAttr, wsCall;
      target = jQuery(target);
      target.find("div.data").hide();
      target.find("div.noresults").hide();
      target.find("div.wait").show();
      extraAttr = getExtraValue(target);
      wsCall = wsCall = function(token) {
        var request_data;
        request_data = {
          widget: widgetId,
          list: bagName,
          filter: extraAttr,
          token: token
        };
        return jQuery.getJSON(service + "list/chart", request_data, function(res) {
          var Chart, data, options, pathQuery, targetElem, viz;
          if (res.results.length !== 0) {
            viz = google.visualization;
            data = google.visualization.arrayToDataTable(res.results, false);
            targetElem = target;
            Chart = null;
            options = jQuery.extend({}, CHART_OPTS, {
              title: res.title
            });
            if (res.chartType === "ColumnChart") {
              Chart = viz.ColumnChart;
            } else if (res.chartType === "BarChart") {
              Chart = viz.BarChart;
            } else if (res.chartType === "ScatterPlot") {
              Chart = viz.ScatterChart;
            } else if (res.chartType === "PieChart") {
              Chart = viz.PieChart;
            } else {
              if (res.chartType === "XYLineChart") Chart = viz.LineChart;
            }
            if (domainLabel) {
              jQuery.extend(options, {
                hAxis: {
                  title: rangeLabel,
                  titleTextStyle: {
                    fontName: "Sans-Serif"
                  }
                }
              });
            }
            if (rangeLabel) {
              jQuery.extend(options, {
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
                    window.open(service + "query/results?query=" + pathQueryWithConstraintValues + "&format=html");
                  } else if (item.row != null) {
                    category = res.results[item.row + 1][0];
                    pathQuery = pathQuery.replace("%category", category);
                    window.open(service + "query/results?query=" + pathQuery + "&format=html");
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
      };
      return "";
    };
    getSeriesValue = function(seriesLabel, seriesLabels, seriesValues) {
      var arraySeriesLabels, arraySeriesValues, i;
      arraySeriesLabels = seriesLabels.split(",");
      arraySeriesValues = seriesValues.split(",");
      i = 0;
      while (i < arraySeriesLabels.length) {
        if (seriesLabel === arraySeriesLabels[i]) return arraySeriesValues[i];
        i++;
      }
    };
    displayEnrichmentWidgetConfig = function(widgetId, label, bagName, target) {
      var errorCorrection, extraAttr, max, wsCall;
      target = jQuery(target);
      target.find("div.data").hide();
      target.find("div.noresults").hide();
      target.find("div.wait").show();
      errorCorrection = void 0;
      if (target.find("div.errorcorrection").length > 0) {
        errorCorrection = target.find("div.errorcorrection").value;
      }
      max = void 0;
      if (target.find("div.max").length > 0) max = target.find("div.max").value;
      extraAttr = getExtraValue(target);
      wsCall = wsCall = function(tokenId) {
        var request_data;
        request_data = {
          widget: widgetId,
          list: bagName,
          correction: errorCorrection,
          maxp: max,
          filter: extraAttr,
          token: tokenId
        };
        return jQuery.getJSON(service + "list/enrichment", request_data, function(res) {
          var $table, columns, externalLink, externalLinkLabel, i, results;
          target.find("table.tablewidget thead").html("");
          target.find("table.tablewidget tbody").html("");
          results = res.results;
          if (results.length !== 0) {
            columns = [label, "p-Value", "Matches"];
            createTableHeader(widgetId, columns);
            $table = target.find("table.tablewidget tbody");
            i = 0;
            externalLink = void 0;
            if (target.find("div.externallink").length > 0) {
              externalLink = target.find("div.externallink").value;
            }
            externalLinkLabel = void 0;
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
      };
      return "";
    };
    getExtraValue = function(target) {
      var extraAttr;
      extraAttr = void 0;
      if (target.find("select.select").length > 0) {
        extraAttr = target.find("select.select").value;
      }
      return extraAttr;
    };
    make_enrichment_row = function(result, externalLink, externalLinkLabel) {
      var $a, $checkBox, $count, $list, $matches, $row, $td, i, label;
      $row = jQuery("<tr>");
      $checkBox = jQuery("<input />").attr({
        type: "checkbox",
        id: "selected_" + result.item,
        value: result.item,
        name: "selected"
      });
      $row.append(jQuery("<td>").append($checkBox));
      if (result.description) {
        $td = jQuery("<td>").text(result.description + " ");
        if (externalLink) {
          label = void 0;
          if (externalLinkLabel !== undefined) label = externalLinkLabel;
          label = label + result.item;
          $a = jQuery("<a>").addClass("extlink").text("[" + label + "]");
          $a.attr({
            target: "_new",
            href: externalLink + result.item
          });
          $td.append($a);
        }
        $row.append($td);
      } else {
        $row.append(jQuery("<td>").html("<em>no description</em>"));
      }
      $row.append(jQuery("<td>").text(result["p-value"]));
      $count = jQuery("<span>").addClass("match-count").text(result.matches.length);
      $matches = jQuery("<div>");
      $matches.css({
        display: "none"
      });
      $list = jQuery("<ul>");
      i = 0;
      for (i in result.matches) {
        $list.append(jQuery("<li>").text(result.matches[i]));
      }
      $matches.append($list);
      $count.append($matches);
      $count.click(function() {
        return $matches.slideToggle();
      });
      $row.append(jQuery("<td>").append($count));
      return $row;
    };
    loadGraphWidget = function(id, domainLabel, rangeLabel, seriesLabels, seriesValues, bagName, target) {
      return google.setOnLoadCallback(function() {
        return displayGraphWidgetConfig(id, domainLabel, rangeLabel, seriesLabels, seriesValues, bagName, target);
      });
    };
    loadEnrichmentWidget = function(id, domainLabel, rangeLabel, seriesLabels, seriesValues, bagName, target) {
      return google.setOnLoadCallback(function() {
        return displayEnrichmentWidgetConfig(id, label, bagName, target);
      });
    };
    google.load("visualization", "1.0", {
      packages: ["corechart"]
    });
    return {
      loadGraph: loadGraphWidget,
      loadEnrichment: loadEnrichmentWidget
    };
  };

}).call(this);
