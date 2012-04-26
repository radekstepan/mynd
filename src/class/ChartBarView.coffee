### Chart Widget bar onclick box.###

class ChartBarView extends Backbone.View

    # How many characters can we display in the description?
    descriptionLimit: 50

    # How many objects do we show before ending with an ellipsis?
    valuesLimit: 5

    events:
        "click a.results": "resultsAction"
        "click a.close":   "close"

    initialize: (o) ->
        @[k] = v for k, v of o

        @render()

    render: =>
        # Skeleton.
        $(@el).html @template "chart.bar",
            "description":      @description
            "descriptionLimit": @descriptionLimit

        # Grab the data for this bar.
        values = []
        @imjs.query(@quickPq, (q) =>
            q.rows (response) =>
                for object in response
                    values.push do (object) ->
                        for column in object
                            return column if column.length > 0

                @renderValues values
        )

        @

    # Render the values from imjs request.
    renderValues: (values) =>
        $(@el).find('div.values').html @template "chart.bar.values", 'values': values, 'type': @type, 'valuesLimit': @valuesLimit

    # View results action callback.
    resultsAction: => @resultsCb @resultsPq

    # Switch off.
    close: => $(@el).remove()