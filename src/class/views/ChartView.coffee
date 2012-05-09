### View maintaining Chart Widget.###

class ChartView extends Backbone.View

    events:
        "change div.form select": "formAction"

    initialize: (o) ->
        @[k] = v for k, v of o
        @render()

    render: ->
        # Render the widget template.
        $(@el).html @template "chart",
            "title":       if @options.title then @response.title else ""
            "description": if @options.description then @response.description else ""
            "notAnalysed": @response.notAnalysed

        # Extra attributes (DataSets etc.)?
        if @response.filterLabel?
            $(@el).find('div.form form').append @template "extra",
                "label":    @response.filterLabel
                "possible": @response.filters.split(',') # Is a String unfortunately.
                "selected": @response.filterSelectedValue

        # Are the results empty?
        if @response.results.length > 1
            # Form the series from Google Visualization formatted data.
            data = []
            for v in @response.results[1..]
                data.push
                    'text': v[0]
                    'data':
                        # Two series specifying ColorBrewer classes.
                        'Blues':  v[1]
                        'Greens': v[2]

            # Determine the height of the svg canvas it should occupy.
            height = $(@widget.el).height() - $(@widget.el).find('header').height()

            # Render the chart using d3.js
            chart = new Charts.MultipleBars.Vertical(
                'el':      $(@el).find("div.content")
                'data':    data
                'width':   420
                'height':  height
                'onclick': @barAction
            )
            chart.render()

        else
            # Render no results.
            $(@el).find("div.content").html $ @template "noresults"

    # Event listener on bar chart click.
    barAction: (color, category, seriesIndex, value) =>
        # Determine which bar we are in.
        description = '' ; resultsPq = @response.pathQuery ; quickPq = @response.simplePathQuery
        
        description += category
        # Replace `%category` in PathQueries.
        resultsPq = resultsPq.replace "%category", category ; quickPq = quickPq.replace "%category", category
        # Replace `%series` in PathQuery.
        description += ' ' + @response.seriesLabels.split(',')[seriesIndex]
        series = @response.seriesValues?.split(',')[seriesIndex]
        resultsPq = resultsPq.replace("%series", series) ; quickPq = resultsPq.replace("%series", series)

        # Turn into JSON object?
        resultsPq = JSON?.parse resultsPq ; quickPq = JSON?.parse quickPq

        # Remove any previous.
        if @barView? then @barView.close()

        # We may have deselected a bar.
        if description
            # Create `View`
            $(@el).find('div.content').append (@barView = new ChartPopoverView(
                "description": description
                "template":    @template
                "resultsPq":   resultsPq
                "resultsCb":   @options.resultsCb
                "listCb":      @options.listCb
                "matchCb":     @options.matchCb
                "quickPq":     quickPq
                "imService":   @widget.imService()
                "type":        @response.type
            )).el

    # On form select option change, set the new options and re-render.
    formAction: (e) =>
        @widget.formOptions[$(e.target).attr("name")] = $(e.target[e.target.selectedIndex]).attr("value")
        @widget.render()