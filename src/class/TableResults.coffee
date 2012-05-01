### Models underpinning Table Widget results.###

#### Table Row Model
class TableRow extends Backbone.Model    

    defaults:
        "selected":    false # Is the row selected?

    # Spec for validating the object data types.
    spec:
        "matches":      type.isInteger
        "identifier":   type.isInteger
        "descriptions": type.isArray
        "selected":     type.isBoolean

    # Call the validation on us.
    initialize: (row, @widget) -> @validate row

    # Validate type (@throws Error).
    validate: (row) => @widget.validateType row, @spec

    # Toggle the `selected` state of this row item.
    toggleSelected: => @set(selected: not @get("selected"))

#### Table Rows Collection
class TableResults extends Backbone.Collection

    model: TableRow

    # Filter down the **Collection** of all lists that are `selected`.
    selected: -> @filter( (row) -> row.get "selected" )

    # Silently! (de-)select all.
    toggleSelected: ->
        if @models.length - @selected().length
            # Select all.
            model.set {"selected": true}, {'silent': true} for model in @models
        else
            # Deselect all.
            model.set {"selected": false}, {'silent': true} for model in @models