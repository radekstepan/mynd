((function(){this.JST||(this.JST={}),this.JST["widgets.invalidjsonkey"]=function(a){a||(a={});var b=[],c=function(a){var c=b,d;return b=[],a.call(this),d=b.join(""),b=c,e(d)},d=function(a){return a&&a.ecoSafe?a:typeof a!="undefined"&&a!=null?g(a):""},e,f=a.safe,g=a.escape;return e=a.safe=function(a){if(a&&a.ecoSafe)return a;if(typeof a=="undefined"||a==null)a="";var b=new String(a);return b.ecoSafe=!0,b},g||(g=a.escape=function(a){return(""+a).replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;")}),function(){((function(){b.push('<li style="vertical-align:bottom">\n    <span style="display:inline-block" class="label label-inverse">'),b.push(d(this.key)),b.push("</span> is "),b.push(d(this.actual)),b.push("; was expecting "),b.push(d(this.expected)),b.push("\n</li>")})).call(this)}.call(a),a.safe=f,a.escape=g,b.join("")}})).call(this),function(){this.JST||(this.JST={}),this.JST["widgets.enrichment.row"]=function(a){a||(a={});var b=[],c=function(a){var c=b,d;return b=[],a.call(this),d=b.join(""),b=c,e(d)},d=function(a){return a&&a.ecoSafe?a:typeof a!="undefined"&&a!=null?g(a):""},e,f=a.safe,g=a.escape;return e=a.safe=function(a){if(a&&a.ecoSafe)return a;if(typeof a=="undefined"||a==null)a="";var b=new String(a);return b.ecoSafe=!0,b},g||(g=a.escape=function(a){return(""+a).replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;")}),function(){((function(){b.push('<tr>\n    <td class="description">'),b.push(d(this.row.description)),b.push('</td>\n    <td class="pValue">'),b.push(d(this.row["p-value"].toFixed(7))),b.push('</td>\n    <td class="matches" style="position:relative">\n        <span class="count label label-success" style="cursor:pointer">'),b.push(d(this.row.matches.length)),b.push("</span>\n    </td>\n</tr>")})).call(this)}.call(a),a.safe=f,a.escape=g,b.join("")}}.call(this),function(){this.JST||(this.JST={}),this.JST["widgets.enrichment.form"]=function(a){a||(a={});var b=[],c=function(a){var c=b,d;return b=[],a.call(this),d=b.join(""),b=c,e(d)},d=function(a){return a&&a.ecoSafe?a:typeof a!="undefined"&&a!=null?g(a):""},e,f=a.safe,g=a.escape;return e=a.safe=function(a){if(a&&a.ecoSafe)return a;if(typeof a=="undefined"||a==null)a="";var b=new String(a);return b.ecoSafe=!0,b},g||(g=a.escape=function(a){return(""+a).replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;")}),function(){((function(){var a,c,e,f,g,h,i,j;b.push('<form>\n    <div class="group" style="display:inline-block;margin-right:5px">\n        <label>Test Correction</label>\n        <select name="errorCorrection" class="span2">\n            '),i=this.errorCorrections;for(e=0,g=i.length;e<g;e++)a=i[e],b.push('\n                <option value="'),b.push(d(a)),b.push('" '),this.options.errorCorrection===a&&b.push(d('selected="selected"')),b.push(">\n                    "),b.push(d(a)),b.push("\n            </option>\n            ");b.push('\n        </select>\n    </div>\n\n    <div class="group" style="display:inline-block;margin-right:5px">\n        <label>Max p-value</label>\n        <select name="pValue" class="span2">\n            '),j=this.pValues;for(f=0,h=j.length;f<h;f++)c=j[f],b.push('\n                <option value="'),b.push(d(c)),b.push('" '),this.options.pValue===c&&b.push(d('selected="selected"')),b.push(">\n                    "),b.push(d(c)),b.push("\n                </option>\n            ");b.push("\n        </select>\n    </div>\n</form>")})).call(this)}.call(a),a.safe=f,a.escape=g,b.join("")}}.call(this),function(){this.JST||(this.JST={}),this.JST["widgets.enrichment.extra"]=function(a){a||(a={});var b=[],c=function(a){var c=b,d;return b=[],a.call(this),d=b.join(""),b=c,e(d)},d=function(a){return a&&a.ecoSafe?a:typeof a!="undefined"&&a!=null?g(a):""},e,f=a.safe,g=a.escape;return e=a.safe=function(a){if(a&&a.ecoSafe)return a;if(typeof a=="undefined"||a==null)a="";var b=new String(a);return b.ecoSafe=!0,b},g||(g=a.escape=function(a){return(""+a).replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;")}),function(){((function(){var a,c,e,f;b.push('<div class="group" style="display:inline-block;margin-right:5px">\n    <label>'),b.push(d(this.label)),b.push('</label>\n    <select name="dataSet" class="span2">\n        '),f=this.possible;for(c=0,e=f.length;c<e;c++)a=f[c],b.push('\n            <option value="'),b.push(d(a)),b.push('" '),this.selected===a&&b.push(d('selected="selected"')),b.push(">\n                "),b.push(d(a)),b.push("\n            </option>\n        ");b.push("\n    </select>\n</div>")})).call(this)}.call(a),a.safe=f,a.escape=g,b.join("")}}.call(this),function(){this.JST||(this.JST={}),this.JST["widgets.error"]=function(a){a||(a={});var b=[],c=function(a){var c=b,d;return b=[],a.call(this),d=b.join(""),b=c,e(d)},d=function(a){return a&&a.ecoSafe?a:typeof a!="undefined"&&a!=null?g(a):""},e,f=a.safe,g=a.escape;return e=a.safe=function(a){if(a&&a.ecoSafe)return a;if(typeof a=="undefined"||a==null)a="";var b=new String(a);return b.ecoSafe=!0,b},g||(g=a.escape=function(a){return(""+a).replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;")}),function(){((function(){b.push('<div class="alert alert-block">\n    <h4 class="alert-heading">'),b.push(d(this.title)),b.push("</h4>\n    <p>"),b.push(d(this.text)),b.push("</p>\n</div>")})).call(this)}.call(a),a.safe=f,a.escape=g,b.join("")}}.call(this),function(){this.JST||(this.JST={}),this.JST["widgets.enrichment.table"]=function(a){a||(a={});var b=[],c=function(a){var c=b,d;return b=[],a.call(this),d=b.join(""),b=c,e(d)},d=function(a){return a&&a.ecoSafe?a:typeof a!="undefined"&&a!=null?g(a):""},e,f=a.safe,g=a.escape;return e=a.safe=function(a){if(a&&a.ecoSafe)return a;if(typeof a=="undefined"||a==null)a="";var b=new String(a);return b.ecoSafe=!0,b},g||(g=a.escape=function(a){return(""+a).replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;")}),function(){((function(){b.push('<table class="table table-striped">\n    <thead>\n        <tr>\n            <th>'),b.push(d(label)),b.push("</th>\n            <th>p-Value</th>\n            <th>Matches</th>\n        </tr>\n    </thead>\n    <tbody></tbody>\n</table>")})).call(this)}.call(a),a.safe=f,a.escape=g,b.join("")}}.call(this),function(){this.JST||(this.JST={}),this.JST["widgets.enrichment.normal"]=function(a){a||(a={});var b=[],c=function(a){var c=b,d;return b=[],a.call(this),d=b.join(""),b=c,e(d)},d=function(a){return a&&a.ecoSafe?a:typeof a!="undefined"&&a!=null?g(a):""},e,f=a.safe,g=a.escape;return e=a.safe=function(a){if(a&&a.ecoSafe)return a;if(typeof a=="undefined"||a==null)a="";var b=new String(a);return b.ecoSafe=!0,b},g||(g=a.escape=function(a){return(""+a).replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;")}),function(){((function(){b.push("<header>\n    <h3>"),this.title&&b.push(d(this.title)),b.push("</h3>\n    <p>"),this.description&&b.push(d(this.description)),b.push("</p>\n    "),this.notAnalysed&&(b.push('\n        <p>Number of Genes in this list not analysed in this widget: <span class="label label-info">'),b.push(d(this.notAnalysed)),b.push("</span></p>\n    ")),b.push('\n    <div class="form"></div>\n</header>\n<div class="content" style="overflow:auto;overflow-x:hidden;height:400px"></div>')})).call(this)}.call(a),a.safe=f,a.escape=g,b.join("")}}.call(this),function(){this.JST||(this.JST={}),this.JST["widgets.enrichment.matches"]=function(a){a||(a={});var b=[],c=function(a){var c=b,d;return b=[],a.call(this),d=b.join(""),b=c,e(d)},d=function(a){return a&&a.ecoSafe?a:typeof a!="undefined"&&a!=null?g(a):""},e,f=a.safe,g=a.escape;return e=a.safe=function(a){if(a&&a.ecoSafe)return a;if(typeof a=="undefined"||a==null)a="";var b=new String(a);return b.ecoSafe=!0,b},g||(g=a.escape=function(a){return(""+a).replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;")}),function(){((function(){var a,c,e,f;b.push('<div class="popover" style="position:absolute;top:22px;right:0;z-index:1;display:block">\n    <div class="popover-inner" style="width:300px;margin-left:-300px">\n        <a style="cursor:pointer;margin:2px 5px 0 0" class="close">×</a>\n        <h3 class="popover-title"></h3>\n        <div class="popover-content">\n            '),f=this.matches;for(c=0,e=f.length;c<e;c++)a=f[c],b.push('\n                <a href="#">'),b.push(d(a)),b.push("</a>\n            ");b.push("\n        </div>\n    </div>\n</div>")})).call(this)}.call(a),a.safe=f,a.escape=g,b.join("")}}.call(this),function(){this.JST||(this.JST={}),this.JST["widgets.noresults"]=function(a){a||(a={});var b=[],c=function(a){var c=b,d;return b=[],a.call(this),d=b.join(""),b=c,e(d)},d=function(a){return a&&a.ecoSafe?a:typeof a!="undefined"&&a!=null?g(a):""},e,f=a.safe,g=a.escape;return e=a.safe=function(a){if(a&&a.ecoSafe)return a;if(typeof a=="undefined"||a==null)a="";var b=new String(a);return b.ecoSafe=!0,b},g||(g=a.escape=function(a){return(""+a).replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;")}),function(){((function(){b.push('<div class="alert alert-info">\n    <p>The Widget has no results.</p>\n</div>')})).call(this)}.call(a),a.safe=f,a.escape=g,b.join("")}}.call(this),function(){this.JST||(this.JST={}),this.JST["widgets.chart.normal"]=function(a){a||(a={});var b=[],c=function(a){var c=b,d;return b=[],a.call(this),d=b.join(""),b=c,e(d)},d=function(a){return a&&a.ecoSafe?a:typeof a!="undefined"&&a!=null?g(a):""},e,f=a.safe,g=a.escape;return e=a.safe=function(a){if(a&&a.ecoSafe)return a;if(typeof a=="undefined"||a==null)a="";var b=new String(a);return b.ecoSafe=!0,b},g||(g=a.escape=function(a){return(""+a).replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;")}),function(){((function(){b.push("<header>\n    <h3>"),this.title&&b.push(d(this.title)),b.push("</h3>\n    <p>"),this.description&&b.push(d(this.description)),b.push("</p>\n    "),this.notAnalysed&&(b.push('\n        <p>Number of Genes in this list not analysed in this widget: <span class="label label-info">'),b.push(d(this.notAnalysed)),b.push("</span></p>\n    ")),b.push('\n</header>\n<div class="content"></div>')})).call(this)}.call(a),a.safe=f,a.escape=g,b.join("")}}.call(this);

(function() {
  var CSSLoader, ChartWidget, EnrichmentWidget, InterMineWidget, JSLoader, Loader, root, type,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __slice = Array.prototype.slice,
    __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  root = this;

  type = {};

  type.Root = (function() {

    function Root() {}

    Root.prototype.result = false;

    Root.prototype.is = function() {
      return this.result;
    };

    Root.prototype.toString = function() {
      return this.expected;
    };

    return Root;

  })();

  type.isString = (function(_super) {

    __extends(isString, _super);

    isString.prototype.expected = "String";

    function isString(key) {
      this.result = typeof key === 'string';
    }

    return isString;

  })(type.Root);

  type.isInteger = (function(_super) {

    __extends(isInteger, _super);

    isInteger.prototype.expected = "Integer";

    function isInteger(key) {
      this.result = typeof key === 'number';
    }

    return isInteger;

  })(type.Root);

  type.isBoolean = (function(_super) {

    __extends(isBoolean, _super);

    isBoolean.prototype.expected = "Boolean true";

    function isBoolean(key) {
      this.result = typeof key === 'boolean';
    }

    return isBoolean;

  })(type.Root);

  type.isNull = (function(_super) {

    __extends(isNull, _super);

    isNull.prototype.expected = "Null";

    function isNull(key) {
      this.result = key === null;
    }

    return isNull;

  })(type.Root);

  type.isArray = (function(_super) {

    __extends(isArray, _super);

    isArray.prototype.expected = "Array";

    function isArray(key) {
      this.result = key instanceof Array;
    }

    return isArray;

  })(type.Root);

  type.isHTTPSuccess = (function(_super) {

    __extends(isHTTPSuccess, _super);

    isHTTPSuccess.prototype.expected = "HTTP code 200";

    function isHTTPSuccess(key) {
      this.result = key === 200;
    }

    return isHTTPSuccess;

  })(type.Root);

  type.isUndefined = (function(_super) {

    __extends(isUndefined, _super);

    function isUndefined() {
      isUndefined.__super__.constructor.apply(this, arguments);
    }

    isUndefined.prototype.expected = "it to be undefined";

    return isUndefined;

  })(type.Root);

  InterMineWidget = (function() {

    function InterMineWidget() {
      this.isValidResponse = __bind(this.isValidResponse, this);      $(this.el).html($('<div/>', {
        "class": "inner",
        style: "height:572px;overflow:hidden"
      }));
      this.el = "" + this.el + " div.inner";
    }

    InterMineWidget.prototype.template = function(name, context) {
      var _base, _name;
      if (context == null) context = {};
      return typeof (_base = window.JST)[_name = "widgets." + name] === "function" ? _base[_name](context) : void 0;
    };

    InterMineWidget.prototype.isValidResponse = function(json) {
      var fails, key, r, value, _base;
      fails = [];
      for (key in json) {
        value = json[key];
        if ((r = (typeof (_base = this.json)[key] === "function" ? new _base[key](value) : void 0) || (r = new type.isUndefined())) && !r.is()) {
          fails.push(this.template("invalidjsonkey", {
            key: key,
            actual: r.is(),
            expected: new String(r)
          }));
        }
      }
      return fails;
    };

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

    ChartWidget.prototype.json = {
      "chartType": type.isString,
      "description": type.isString,
      "error": type.isNull,
      "list": type.isString,
      "notAnalysed": type.isInteger,
      "pathQuery": type.isString,
      "requestedAt": type.isString,
      "results": type.isArray,
      "seriesLabels": type.isString,
      "seriesValues": type.isString,
      "statusCode": type.isHTTPSuccess,
      "title": type.isString,
      "type": type.isString,
      "wasSuccessful": type.isBoolean
    };

    function ChartWidget(service, token, id, bagName, el, widgetOptions) {
      var _this = this;
      this.service = service;
      this.token = token;
      this.id = id;
      this.bagName = bagName;
      this.el = el;
      this.widgetOptions = widgetOptions != null ? widgetOptions : {
        "title": true,
        "description": true,
        selectCb: function(pq) {
          return window.open("" + _this.service + "query/results?query=" + (encodeURIComponent(pq)) + "&format=html");
        }
      };
      this.render = __bind(this.render, this);
      ChartWidget.__super__.constructor.call(this);
      this.render();
    }

    ChartWidget.prototype.render = function() {
      var _this = this;
      return $.ajax({
        url: "" + this.service + "list/chart",
        dataType: "json",
        data: {
          widget: this.id,
          list: this.bagName,
          token: this.token
        },
        success: function(response) {
          var chart, fails;
          if ((fails = _this.isValidResponse(response)) && !fails.length) {
            $(_this.el).html(_this.template("chart.normal", {
              "title": _this.widgetOptions.title ? response.title : "",
              "description": _this.widgetOptions.description ? response.description : "",
              "notAnalysed": response.notAnalysed
            }));
            if (response.results.length) {
              if (response.chartType in google.visualization) {
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
                          pq = pq.replace("%series", _this._translateSeries(response, response.results[0][item.column]));
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
                return $(_this.el).html(_this.template("error", {
                  title: response.chartType,
                  text: "This chart type does not exist in Google Visualization API"
                }));
              }
            } else {
              return $(_this.el).find("div.content").html($(_this.template("noresults")));
            }
          } else {
            return $(_this.el).html(_this.template("error", {
              title: "Invalid JSON response",
              text: "<ol>" + (fails.join('')) + "</ol>"
            }));
          }
        },
        error: function(err) {
          return $(_this.el).html(_this.template("error", {
            title: err.statusText,
            text: err.responseText
          }));
        }
      });
    };

    ChartWidget.prototype._translateSeries = function(response, series) {
      return response.seriesValues.split(',')[response.seriesLabels.split(',').indexOf(series)];
    };

    return ChartWidget;

  })(InterMineWidget);

  EnrichmentWidget = (function(_super) {

    __extends(EnrichmentWidget, _super);

    EnrichmentWidget.prototype.formOptions = {
      errorCorrection: "Holm-Bonferroni",
      pValue: 0.05
    };

    EnrichmentWidget.prototype.errorCorrections = ["Holm-Bonferroni", "Benjamini Hochberg", "Bonferroni", "None"];

    EnrichmentWidget.prototype.pValues = [0.05, 0.10, 1.00];

    function EnrichmentWidget(service, token, id, bagName, el, widgetOptions) {
      var _this = this;
      this.service = service;
      this.token = token;
      this.id = id;
      this.bagName = bagName;
      this.el = el;
      this.widgetOptions = widgetOptions != null ? widgetOptions : {
        "title": true,
        "description": true,
        matchCb: function(id) {
          return typeof console !== "undefined" && console !== null ? console.log(id) : void 0;
        }
      };
      this.matchesClick = __bind(this.matchesClick, this);
      this.formClick = __bind(this.formClick, this);
      this.render = __bind(this.render, this);
      EnrichmentWidget.__super__.constructor.call(this);
      this.render();
    }

    EnrichmentWidget.prototype.render = function() {
      var _this = this;
      return $.ajax({
        url: "" + this.service + "list/enrichment",
        dataType: "json",
        data: {
          widget: this.id,
          list: this.bagName,
          correction: this.formOptions.errorCorrection,
          maxp: this.formOptions.pValue,
          token: this.token
        },
        success: function(response) {
          var height, row, table, _fn, _i, _len, _ref;
          if (response.wasSuccessful) {
            $(_this.el).html(_this.template("enrichment.normal", {
              "title": _this.widgetOptions.title ? response.title : "",
              "description": _this.widgetOptions.description ? response.description : "",
              "notAnalysed": response.notAnalysed
            }));
            $(_this.el).find("div.form").html(_this.template("enrichment.form", {
              "options": _this.formOptions,
              "errorCorrections": _this.errorCorrections,
              "pValues": _this.pValues
            }));
            if (response.extraAttributeLabel != null) {
              $(_this.l).find('div.form form').append(_this.template("enrichment.extra", {
                "label": response.extraAttributeLabel,
                "possible": response.extraAttributePossibleValues,
                "selected": response.extraAttributeSelectedValue
              }));
            }
            if (response.results.length > 0) {
              height = $(_this.el).height() - $(_this.el).find('header').height() - 18;
              $(_this.el).find("div.content").html($(_this.template("enrichment.table", {
                "label": response.label
              }))).css("height", "" + height + "px");
              table = $(_this.el).find("div.content table");
              _ref = response.results;
              _fn = function(row) {
                var td, tr;
                table.append(tr = $(_this.template("enrichment.row", {
                  "row": row
                })));
                return td = tr.find("td.matches .count").click(function() {
                  return _this.matchesClick(td, row["matches"], _this.widgetOptions.matchCb);
                });
              };
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                row = _ref[_i];
                _fn(row);
              }
            } else {
              $(_this.el).find("div.content").html($(_this.template("noresults")));
            }
            return $(_this.el).find("form select").change(_this.formClick);
          }
        },
        error: function(err) {
          return $(_this.el).html(_this.template("error", {
            title: err.statusText,
            text: err.responseText
          }));
        }
      });
    };

    EnrichmentWidget.prototype.formClick = function(e) {
      this.formOptions[$(e.target).attr("name")] = $(e.target[e.target.selectedIndex]).attr("value");
      return this.render();
    };

    EnrichmentWidget.prototype.matchesClick = function(target, matches, matchCb) {
      var modal;
      target.after(modal = $(this.template("enrichment.matches", {
        "matches": matches
      })));
      modal.find("a.close").click(function() {
        return modal.remove();
      });
      return modal.find("div.popover-content a").click(function(e) {
        matchCb($(this).text());
        return e.preventDefault();
      });
    };

    return EnrichmentWidget;

  })(InterMineWidget);

  Loader = (function() {

    function Loader() {}

    Loader.prototype.getHead = function() {
      return document.getElementsByTagName('head')[0];
    };

    Loader.prototype.setCallback = function(tag, callback) {
      tag.onload = callback;
      return tag.onreadystatechange = function() {
        var state;
        state = tag.readyState;
        if (state === "complete" || state === "loaded") {
          tag.onreadystatechange = null;
          return window.setTimeout(callback, 0);
        }
      };
    };

    return Loader;

  })();

  JSLoader = (function(_super) {

    __extends(JSLoader, _super);

    function JSLoader(path, callback) {
      var script;
      script = document.createElement("script");
      script.src = path;
      script.type = "text/javascript";
      if (callback) this.setCallback(script, callback);
      this.getHead().appendChild(script);
    }

    return JSLoader;

  })(Loader);

  CSSLoader = (function(_super) {

    __extends(CSSLoader, _super);

    function CSSLoader(path, callback) {
      var sheet;
      sheet = document.createElement("link");
      sheet.rel = "stylesheet";
      sheet.type = "text/css";
      sheet.href = path;
      if (callback) this.setCallback(sheet, callback);
      this.getHead().appendChild(sheet);
    }

    return CSSLoader;

  })(Loader);

  root.Widgets = (function() {

    Widgets.prototype.resources = {
      js: {
        jQuery: "http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js",
        _: "http://documentcloud.github.com/underscore/underscore.js",
        google: "https://www.google.com/jsapi"
      }
    };

    function Widgets(service, token) {
      var library, path, _fn, _ref,
        _this = this;
      this.service = service;
      this.token = token != null ? token : "";
      this.all = __bind(this.all, this);
      this.enrichment = __bind(this.enrichment, this);
      this.chart = __bind(this.chart, this);
      _ref = this.resources.js;
      _fn = function(library, path) {
        var _ref2;
        if (!(root[library] != null)) {
          _this.wait = ((_ref2 = _this.wait) != null ? _ref2 : 0) + 1;
          return new JSLoader(path, function() {
            if (library === "jQuery") root.$ = root.jQuery;
            return _this.wait -= 1;
          });
        } else {
          if (library === "jQuery") return root.$ = root.jQuery;
        }
      };
      for (library in _ref) {
        path = _ref[library];
        _fn(library, path);
      }
    }

    Widgets.prototype.chart = function() {
      var opts,
        _this = this;
      opts = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (this.wait) {
        return window.setTimeout((function() {
          return _this.chart.apply(_this, opts);
        }), 0);
      } else {
        return google.load("visualization", "1.0", {
          packages: ["corechart"],
          callback: function() {
            return (function(func, args, ctor) {
              ctor.prototype = func.prototype;
              var child = new ctor, result = func.apply(child, args);
              return typeof result === "object" ? result : child;
            })(ChartWidget, [_this.service, _this.token].concat(__slice.call(opts)), function() {});
          }
        });
      }
    };

    Widgets.prototype.enrichment = function() {
      var opts,
        _this = this;
      opts = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (this.wait) {
        return window.setTimeout((function() {
          return _this.enrichment.apply(_this, opts);
        }), 0);
      } else {
        return (function(func, args, ctor) {
          ctor.prototype = func.prototype;
          var child = new ctor, result = func.apply(child, args);
          return typeof result === "object" ? result : child;
        })(EnrichmentWidget, [this.service, this.token].concat(__slice.call(opts)), function() {});
      }
    };

    Widgets.prototype.all = function(type, bagName, el, widgetOptions) {
      var _this = this;
      if (type == null) type = "Gene";
      if (this.wait) {
        return window.setTimeout((function() {
          return _this.all(type, bagName, el, widgetOptions);
        }), 0);
      } else {
        return $.ajax({
          url: "" + this.service + "widgets",
          dataType: "json",
          success: function(response) {
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
                    _results.push(_this.chart(widget.name, bagName, "" + el + " #" + widgetEl, widgetOptions));
                    break;
                  case "enrichment":
                    _results.push(_this.enrichment(widget.name, bagName, "" + el + " #" + widgetEl, widgetOptions));
                    break;
                  default:
                    _results.push(void 0);
                }
              }
              return _results;
            }
          },
          error: function(err) {
            return $(el).html($('<div/>', {
              "class": "alert alert-error",
              text: "An unspecified error has happened, server timeout?"
            }));
          }
        });
      }
    };

    return Widgets;

  })();

}).call(this);
