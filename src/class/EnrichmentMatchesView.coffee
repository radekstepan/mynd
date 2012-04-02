### Enrichment Widget table row matches box.###

class EnrichmentMatchesView extends Backbone.View

    events:
        "click a.match": "matchAction"
        "click a.close": "hide"

    initialize: (o) ->
        @[k] = v for k, v of o

        # New **Collection**.
        @collection = new EnrichmentMatches @matches

        @render()

    render: =>
        $(@el).html @template "enrichment.matches", "matches": @collection.toJSON()
        @

    # Onclick the individual match, execute the callback.
    matchAction: (e) =>
        @callback $(e.target).text(), @type
        e.preventDefault()

    # Hide me.
    hide: => $(@el).hide()