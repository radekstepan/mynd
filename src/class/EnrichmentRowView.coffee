class EnrichmentRowView extends Backbone.View

    tagName: "tr"

    initialize: (o) ->
        @[k] = v for k, v of o
        @render()

    render: ->
        $(@el).html @template "enrichment.row", "row": @model.toJSON()
        @