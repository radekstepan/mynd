class InterMineWidget

    chartOptions:
        fontName: "Sans-Serif"
        fontSize: 9
        width: 400
        height: 450
        legend: "bottom"
        colors: [ "#2F72FF", "#9FC0FF" ]
        chartArea:
            top: 30
        hAxis:
            titleTextStyle:
                fontName: "Sans-Serif"
        vAxis:
            titleTextStyle:
                fontName: "Sans-Serif"


# --------------------------------------------


class GraphWidget extends InterMineWidget

    templates:
        normal:
            """
                <h3><%= id %></h3>
                <p><%= description %></p>
                <% if (notAnalysed > 0) { %>
                    <p>Number of Genes in this list not analysed in this widget: <%= notAnalysed %></p>
                <% } %>
                <div class="widget"></div>
            """
        noresults:
            "<p>The widget has no results.</p>"

    # Set the params on us and set Google load callback.
    # `service`: http://aragorn.flymine.org:8080/flymine/service/
    # `id`:      widgetId
    # `bagName`: myBag
    # `el`:      #target
    constructor: (@service, @id, @bagName, @el, domainLabel, rangeLabel, series) ->
        @options =
            "domainLabel": domainLabel
            "rangeLabel":  rangeLabel
            "series":      series

        google.setOnLoadCallback => @render()

    # Visualize the displayer.
    render: =>
        # Get JSON response by calling the service.
        $.getJSON @service + "list/chart",
            widget: @id
            list:   @bagName
            filter: ""
            token:  "" # Only public lists for now.
        , (response) =>
            # We have results.
            if response.results
                # Render the widget template.
                $(@el).html _.template @templates.normal,
                    "id": @id
                    "description": response.description
                    "notAnalysed": response.notAnalysed

                # Set chart options.
                @chartOptions.title = response.title
                @chartOptions.hAxis.title = @options.domainLabel if @options.domainLabel?
                @chartOptions.vAxis.title = @options.rangeLabel if @options.rangeLabel?

                # Create the chart.
                chart = new google.visualization[response.chartType]($(@el).find("div.widget")[0])
                chart.draw(google.visualization.arrayToDataTable(response.results, false), @chartOptions)

                # Add event listener on click the chart bar.
                if response.pathQuery?
                    google.visualization.events.addListener chart, "select", =>
                        for item in chart.getSelection()
                            if item.row?
                                if item.column?
                                    #pq = response.pathQuery.replace("%category", response.results[item.row + 1][0]).replace("%series", @options[response.results[0][item.column]])
                                    #window.open @service + "query/results?query=" + pq + "&format=html"
                                else
                                    #pq = response.pathQuery.replace("%category", response.results[item.row + 1][0])
                                    #window.open @service + "query/results?query=" + pq + "&format=html"
            else
                $(@el).html _.template @templates.noresults


# --------------------------------------------


class EnrichmentWidget extends InterMineWidget

    constructor: (@service, @id, @bagName, @el) ->
        google.setOnLoadCallback => @render()

    render: =>
        $.getJSON @service + "list/enrichment",
            widget:     @id
            list:       @bagName
            correction: "Holm-Bonferroni"
            maxp:       0.05
            filter:     "All datasets"
            token:      ""
        , (response) =>
            if response.results
                console.log response

    displayEnrichmentWidgetConfig: (widgetId, label, bagName, target) =>
        target = $(target)
        target.find("div.data").hide()
        target.find("div.noresults").hide()
        target.find("div.wait").show()
    
        errorCorrection = target.find("div.errorcorrection").valueif target.find("div.errorcorrection").length > 0
        max = target.find("div.max").value if target.find("div.max").length > 0
        
        extraAttr ?= @el.find("select.select")?.value

        wsCall = ((tokenId="") =>
            request_data =
                widget: widgetId
                list: bagName
                correction: errorCorrection
                maxp: max
                filter: extraAttr
                token: tokenId

            $.getJSON @service + "list/enrichment", request_data, (res) ->
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
        )()

    make_enrichment_row: (result, externalLink, externalLinkLabel) ->
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

    load: (id, domainLabel, rangeLabel, seriesLabels, seriesValues, bagName, target) =>
        google.setOnLoadCallback =>
            @displayEnrichmentWidgetConfig id, label, bagName, target


# --------------------------------------------


class window.Widgets

    # Load Google Visualization.
    google.load "visualization", "1.0",
        packages: [ "corechart" ]

    constructor: (@service) ->

    graph: (opts...) =>
        new GraphWidget(@service, opts...)
    
    enrichment: (opts...) =>
        new EnrichmentWidget(@service, opts...)