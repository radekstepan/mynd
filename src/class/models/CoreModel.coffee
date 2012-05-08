### Core Model for Enrichment and Table Models.###

#### Model
class CoreModel extends Backbone.Model    

    defaults:
        "selected":    false # Is the row selected?

    # Call the validation on us.
    initialize: (row, @widget) -> @validate row

    # Validate type (@throws Error).
    validate: (row) => @widget.validateType row, @spec

    # Toggle the `selected` state of this row item.
    toggleSelected: => @set(selected: not @get("selected"))


#### Collection
class CoreCollection extends Backbone.Collection

    model: CoreModel

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


### Models underpinning Enrichment Widget results.###

#### Enrichment Row Model
class EnrichmentRow extends CoreModel

    # Spec for validating the object data types.
    spec:
        "description":  type.isString
        "identifier":   type.isString
        "matches":      type.isInteger
        "p-value":      type.isInteger
        "selected":     type.isBoolean
        "externalLink": type.isString


#### Enrichment Rows Collection
class EnrichmentResults extends CoreCollection

    model: EnrichmentRow


### Models underpinning Table Widget results.###

#### Table Row Model
class TableRow extends CoreModel

    # Spec for validating the object data types.
    spec:
        "matches":      type.isInteger
        "identifier":   type.isInteger
        "descriptions": type.isArray
        "selected":     type.isBoolean


#### Table Rows Collection
class TableResults extends CoreCollection

    model: TableRow