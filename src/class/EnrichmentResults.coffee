class EnrichmentRow extends Backbone.Model    

    spec:
        "description": type.isString
        "item":        type.isString
        "matches":     type.isArray
        "p-value":     type.isInteger
        "selected":    type.isBoolean

    defaults:
        "selected":    false # Is the row selected?

    initialize: (row, @widget) -> @validate row

    # Validate type.
    validate: (row) => @widget.validateType row, @spec

    # Toggle the `selected` state of this row item.
    toggleSelected: => @set(selected: not @get("selected"))


class EnrichmentResults extends Backbone.Collection

    model: EnrichmentRow

    # Filter down the collection of all lists that are selected.
    selected: -> @filter( (row) -> row.get "selected" )

    # (De-)select all.
    toggleSelected: ->
        if @models.length - @selected().length
            # Select all.
            model.set "selected": true for model in @models
        else
            # Deselect all.
            model.set "selected": false for model in @models