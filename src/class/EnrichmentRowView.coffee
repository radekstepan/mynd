### Enrichment Widget table row.###

class EnrichmentRowView extends Backbone.View

    tagName: "tr"

    events:
        "click td.check input":  "selectAction"
        "click td.matches span": "matchesAction"

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
    matchesAction: =>
        $(@el).find('td.matches span').after new EnrichmentMatchesView(
            "matches":  @model.get "matches"
            "template": @template
            "type":     @type
            "callback": @matchCb
        ).el