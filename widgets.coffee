window.Widgets = (service) ->

    CHART_OPTS =
        fontName: "Sans-Serif"
        fontSize: 9
        width: 400
        height: 450
        legend: "bottom"
        colors: [ "#2F72FF", "#9FC0FF" ]
        chartArea:
            top: 30


    # --------- graph widget ---------


    displayGraphWidgetConfig = (widgetId, domainLabel, rangeLabel, seriesLabels, seriesValues, bagName, target) ->
        target = $(target)
        target.find("div.data").hide()
        target.find("div.noresults").hide()
        target.find("div.wait").show()
        extraAttr = getExtraValue(target)
      
        wsCall = do (token=null) ->
            request_data =
                widget: widgetId
                list: bagName
                filter: extraAttr
                token: token or ""

            $.getJSON service + "list/chart", request_data, (res) ->
                unless res.results.length is 0
                    viz = google.visualization
                    data = google.visualization.arrayToDataTable(res.results, false)
                    targetElem = target
                    Chart = null
                    options = $.extend({}, CHART_OPTS,
                        title: res.title
                    )

                    switch res.chartType
                        when "ColumnChart" then Chart = viz.ColumnChart
                        when "BarChart"  then Chart = viz.BarChart
                        when "ScatterPlot" then Chart = viz.ScatterChart
                        when "PieChart"  then Chart = viz.PieChart
                        when "XYLineChart" then Chart = viz.LineChart
                    
                    if domainLabel
                        $.extend(options,
                            hAxis:
                                title: rangeLabel
                                titleTextStyle:
                                    fontName: "Sans-Serif"
                        )
                    
                    if rangeLabel
                        $.extend(options,
                            vAxis:
                                title: domainLabel
                                titleTextStyle:
                                    fontName: "Sans-Serif"
                        )
                    
                    viz = undefined
                    if Chart
                        viz = new Chart(targetElem)
                        viz.draw(data, options)
                        pathQuery = res.pathQuery
                        google.visualization.events.addListener viz, "select", ->
                            selection = viz.getSelection()
                            i = 0

                            while i < selection.length
                                item = selection[i]
                                if item.row? and item.column?
                                    category = res.results[item.row + 1][0]
                                    series = res.results[0][item.column]
                                    seriesValue = getSeriesValue(series, seriesLabels, seriesValues)
                                    pathQueryWithConstraintValues = pathQuery.replace("%category", category)
                                    pathQueryWithConstraintValues = pathQueryWithConstraintValues.replace("%series", seriesValue)
                                    window.open service + "query/results?query=" + pathQueryWithConstraintValues + "&format=html"
                                else if item.row?
                                    category = res.results[item.row + 1][0]
                                    pathQuery = pathQuery.replace("%category", category)
                                    window.open service + "query/results?query=" + pathQuery + "&format=html"
                                i++
                    else
                        alert "Don't know how to draw " + res.chartType + "s yet!"
                    target.find("div.data").show()
                else
                    target.find("div.noresults").show()
                
                target.find("div.wait").hide()
                target.find("div.notanalysed").text res.notAnalysed

    getSeriesValue = (seriesLabel, seriesLabels, seriesValues) ->
        arraySeriesLabels = seriesLabels.split(",")
        arraySeriesValues = seriesValues.split(",")
        i = 0

        while i < arraySeriesLabels.length
            return arraySeriesValues[i]  if seriesLabel is arraySeriesLabels[i]
            i++


    # --------- enrichment widget ---------


    displayEnrichmentWidgetConfig = (widgetId, label, bagName, target) ->
        target = $(target)
        target.find("div.data").hide()
        target.find("div.noresults").hide()
        target.find("div.wait").show()
    
        errorCorrection = target.find("div.errorcorrection").valueif target.find("div.errorcorrection").length > 0
        max = target.find("div.max").value if target.find("div.max").length > 0
        
        extraAttr = getExtraValue(target)
      
        wsCall = do -> (tokenId="") ->
            request_data =
                widget: widgetId
                list: bagName
                correction: errorCorrection
                maxp: max
                filter: extraAttr
                token: tokenId

            $.getJSON service + "list/enrichment", request_data, (res) ->
                target.find("table.tablewidget thead").html ""
                target.find("table.tablewidget tbody").html ""
                
                results = res.results
                unless results.length is 0
                    columns = [ label, "p-Value", "Matches" ]
                    createTableHeader widgetId, columns
                    $table = target.find("table.tablewidget tbody")
                    i = 0
                    externalLink = target.find("div.externallink").value  if target.find("div.externallink").length > 0
                    externalLinkLabel = target.find("div.externallabel").value  if target.find("div.externallabel").length > 0
                    for i of results
                        $table.append make_enrichment_row(results[i], externalLink, externalLinkLabel)
                    target.find("div.data").show()
                else
                    target.find("div.noresults").show()
                
                target.find("div.wait").hide()
                calcNotAnalysed widgetId, res.notAnalysed

    getExtraValue = (target) ->
        extraAttr = target.find("select.select").value if target.find("select.select").length > 0

    make_enrichment_row = (result, externalLink, externalLinkLabel) ->
        $row = $("<tr>")
        $checkBox = $("<input />").attr(
            type: "checkbox"
            id: "selected_" + result.item
            value: result.item
            name: "selected"
        )
        
        $row.append $("<td>").append($checkBox)
        if result.description
            $td = $("<td>").text(result.description + " ")
        
            if externalLink
                label = externalLinkLabel + result.item unless externalLinkLabel is undefined
                label = label + result.item
                $a = $("<a>").addClass("extlink").text("[" + label + "]")
                $a.attr
                    target: "_new"
                    href: externalLink + result.item

                $td.append $a
            $row.append $td
        else
            $row.append $("<td>").html("<em>no description</em>")
      
        $row.append $("<td>").text(result["p-value"])
        $count = $("<span>").addClass("match-count").text(result.matches.length)
        $matches = $("<div>")
        $matches.css display: "none"
        $list = $("<ul>")
        i = 0
        for i of result.matches
            $list.append $("<li>").text(result.matches[i])
        $matches.append $list
        $count.append $matches
        $count.click ->
            $matches.slideToggle()

        $row.append $("<td>").append($count)
        $row

    loadGraphWidget = (id, domainLabel, rangeLabel, seriesLabels, seriesValues, bagName, target) ->
        google.setOnLoadCallback ->
            displayGraphWidgetConfig id, domainLabel, rangeLabel, seriesLabels, seriesValues, bagName, target

    loadEnrichmentWidget = (id, domainLabel, rangeLabel, seriesLabels, seriesValues, bagName, target) ->
        google.setOnLoadCallback ->
            displayEnrichmentWidgetConfig id, label, bagName, target

    # Load Google Visualization.
    google.load "visualization", "1.0",
        packages: [ "corechart" ]

    # Public methods.
    loadGraph: loadGraphWidget
    loadEnrichment: loadEnrichmentWidget    