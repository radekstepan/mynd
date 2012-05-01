### Enrichment Widget table row matches box.###

class EnrichmentMatchesView extends Backbone.View

    # How many characters can we display in the description?
    descriptionLimit: 50

    # How many matches do we show before ending with an ellipsis?
    valuesLimit: 5

    events:
        "click a.match":   "matchAction"
        "click a.results": "resultsAction"
        "click a.list":    "listAction"
        "click a.close":   "toggle"

    initialize: (o) ->
        @[k] = v for k, v of o

        @render()

    render: =>
        $(@el).css 'position':'relative'
        $(@el).html @template "popover",
            "description":      @description
            "descriptionLimit": @descriptionLimit
            "style":            @style or "width:300px;margin-left:-300px"

        # Fill in the values.
        $(@el).find('div.values').html @template "popover.values",
            'values':      ( x['displayed'] for x in @matches )
            'type':        @response.type
            'valuesLimit': @valuesLimit

        @

    # Toggle me on/off.
    toggle: => $(@el).toggle()

    # Build PathQuery for resultsAction and listAction.
    getPq: =>
        # Form PathQuery.
        pq = @response.pathQuery
        # JSON should have been validated by now.
        @pq = JSON.parse pq
        # Add the ONE OF constraint.
        @pq.where.push
            "path":   @response.pathConstraint
            "op":     "ONE OF"
            "values": @identifiers

    # Onclick the individual match, execute the callback.
    matchAction: (e) =>
        @matchCb $(e.target).text(), @response.type
        e.preventDefault()

    # View results action.
    resultsAction: =>
        @getPq() unless @pq?

        # Callback.
        @resultsCb @pq

    # Create a list action.
    listAction: =>
        @getPq() unless @pq?

        # Callback.
        @listCb @pq