class EnrichmentRowView extends Backbone.View

    tagName: "tr"

    events:
        "click td.check input": "selectAction"

    initialize: (o) ->
        @[k] = v for k, v of o

        @model.bind('change', @render)

        @render()

    render: =>
        $(@el).html @template "enrichment.row", "row": @model.toJSON()
        @

    selectAction: => @model.toggleSelected()