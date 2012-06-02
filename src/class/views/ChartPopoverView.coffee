### Chart Widget bar onclick box.###

class ChartPopoverView extends Backbone.View

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
        # Skeleton.
        $(@el).html @template "popover",
            "description":      @description
            "descriptionLimit": @descriptionLimit
            "style":            'width:300px'

        # Grab the data for this bar.
        values = []
        @imService.query(@quickPq, (q) =>
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
        $(@el).find('div.values').html @template "popover.values"
            'values':      values
            'type':        @type
            'valuesLimit': @valuesLimit

    # Onclick the individual match, execute the callback.
    matchAction: (e) =>
        @matchCb $(e.target).text(), @type
        e.preventDefault()

    # View results action callback.
    resultsAction: => @resultsCb @resultsPq

    # Create a list action.
    listAction: => @listCb @resultsPq

    # Switch off.
    close: => $(@el).remove()