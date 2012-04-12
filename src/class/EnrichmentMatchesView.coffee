### Enrichment Widget table row matches box.###

class EnrichmentMatchesView extends Backbone.View

    # How many matches do we show before ending with an ellipsis?
    limit: 5

    events:
        "click a.match": "matchAction"
        "click a.close": "toggle"

    initialize: (o) ->
        @[k] = v for k, v of o

        # New **Collection**.
        @collection = new EnrichmentMatches @matches

        @render()

    render: =>
        $(@el).css 'position':'relative'
        $(@el).html @template "enrichment.matches",
            "description": @description
            "type":        @type
            "matches":     @collection.toJSON()
            "limit":       @limit
        @

    # Onclick the individual match, execute the callback.
    matchAction: (e) =>
        @callback $(e.target).text(), @type
        e.preventDefault()

    # Toggle me on/off.
    toggle: => $(@el).toggle()