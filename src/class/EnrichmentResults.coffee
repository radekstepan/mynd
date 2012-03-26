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