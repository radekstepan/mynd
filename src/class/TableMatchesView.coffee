### Table Widget table row matches box.###

class TableMatchesView extends Backbone.View

    # How many characters can we display in the description?
    descriptionLimit: 50

    # How many objects do we show before ending with an ellipsis?
    valuesLimit: 5

    events:
        "click a.match":   "matchAction"
        "click a.results": "resultsAction"
        "click a.list":    "listAction"
        "click a.close":   "close"

    initialize: (o) ->
        @[k] = v for k, v of o

        @render()

    render: =>
        $(@el).css 'position':'relative'
        $(@el).html @template "table.matches",
            "description":      @description
            "descriptionLimit": @descriptionLimit

        # Modify JSON to constrain on these matches.
        @pathQuery = JSON.parse @pathQuery
        # Add the ONE OF constraint.
        @pathQuery.where.push
            "path":   @pathConstraint
            "op":     "ONE OF"
            "values": @identifiers

        # Grab the data.
        values = []
        @imjs.query(@pathQuery, (q) =>
            console.log q.toXML()
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
        $(@el).find('div.values').html @template "values", 'values': values, 'type': @type, 'valuesLimit': @valuesLimit

    # Onclick the individual match, execute the callback.
    matchAction: (e) =>
        @matchCb $(e.target).text(), @type
        e.preventDefault()

    # View results action callback.
    resultsAction: => @resultsCb @pathQuery

    # Create a list action.
    listAction: => @listCb @pathQuery

    # Switch off.
    close: => $(@el).remove()