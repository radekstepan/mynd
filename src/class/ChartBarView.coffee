### Chart Widget bar onclick box.###

class ChartBarView extends Backbone.View

    # How many characters can we display in the description?
    descriptionLimit: 50

    events:
        "click a.close":   "close"

    initialize: (o) ->
        @[k] = v for k, v of o

        @render()

    render: =>
        $(@el).html @template "chart.bar",
            "description":      @description
            "descriptionLimit": @descriptionLimit

        @

    # Build PathQuery for resultsAction and listAction.
    getPq: =>
        # Translate view series into PathQuery series (Expressed/Not Expressed into true/false).
        translate = (response, series) ->
            response.seriesValues.split(',')[response.seriesLabels.split(',').indexOf(series)]

        # PathQuery attr.
        pq = @response.pathQuery
        for item in chart.getSelection()
            if item.row?
                # Replace `%category` in PathQuery.
                pq = pq.replace "%category", @response.results[item.row + 1][0]
                # Replace `%series` in PathQuery.
                if item.column?
                    pq = pq.replace("%series", translate @response, @response.results[0][item.column])
                # Turn into JSON object?
                pq = JSON?.parse pq
                # Make the callback.
                @options.selectCb pq

    # Switch off.
    close: => $(@el).remove()