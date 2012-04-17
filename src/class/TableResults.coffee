### Models underpinning Table Widget results.###

#### Table Row Model
class TableRow extends Backbone.Model    

    # Spec for validating the object data types.
    spec:
        "matches":      type.isInteger
        "identifier":   type.isInteger
        "descriptions": type.isArray

    # Call the validation on us.
    initialize: (row, @widget) -> @validate row

    # Validate type (@throws Error).
    validate: (row) => @widget.validateType row, @spec


#### Table Rows Collection
class TableResults extends Backbone.Collection

    model: TableRow