### Enrichment Widget table row matches box.###

class EnrichmentMatchesView extends Backbone.View

    # How many characters can we display in the description?
    descriptionLimit: 50

    # How many matches do we show before ending with an ellipsis?
    matchesLimit: 5

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
        $(@el).html @template "enrichment.matches",
            "description":      @description
            "descriptionLimit": @descriptionLimit
            "type":             @type
            "matches":          @collection.toJSON()
            "matchesLimit":     @matchesLimit
            "style":            @style or "width:300px;margin-left:-300px"

        @

    # Toggle me on/off.
    toggle: => $(@el).toggle()

    # Onclick the individual match, execute the callback.
    matchAction: (e) =>
        @callback $(e.target).text(), @type
        e.preventDefault()

    # View results action.
    resultsAction: => console.log "resultsAction"

    # Create a list action.
    listAction: => console.log "listAction"