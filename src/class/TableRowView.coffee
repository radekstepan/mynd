### Table Widget table row.###

class TableRowView extends Backbone.View

    tagName: "tr"

    initialize: (o) ->
        @[k] = v for k, v of o

        @model.bind('change', @render)

        @render()

    render: =>
        $(@el).html @template "table.row", "row": @model.toJSON()
        @