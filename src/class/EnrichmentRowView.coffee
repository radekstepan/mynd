### Enrichment Widget table row.###

class EnrichmentRowView extends Backbone.View

    tagName: "tr"

    events:
        "click td.check input":     "selectAction"
        "click td.matches a.count": "toggleMatchesAction"

    initialize: (o) ->
        @[k] = v for k, v of o

        @model.bind('change', @render)

        @render()

    render: =>
        $(@el).html @template "enrichment.row", "row": @model.toJSON()
        @

    # Toggle the `selected` attr of this row object.
    selectAction: => @model.toggleSelected()

    # Show matches.
    toggleMatchesAction: =>
        if not @matchesView?
            $(@el).find('td.matches a.count').after (@matchesView = new EnrichmentMatchesView(
                "matches":     @model.get "matches"
                "description": @model.get "description"
                "template":    @template
                "type":        @type
                "callback":    @matchCb
            )).el
        else @matchesView.toggle()