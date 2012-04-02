### Models underpinning Enrichment Widget results.###

#### Enrichment Row Match Model
class EnrichmentMatch extends Backbone.Model


#### Enrichment Row Matches Collection
class EnrichmentMatches extends Backbone.Collection

    model: EnrichmentMatch


#### Enrichment Row Model
class EnrichmentRow extends Backbone.Model    

    defaults:
        "selected":    false # Is the row selected?

    # Spec for validating the object data types.
    spec:
        "description": type.isString
        "identifier":  type.isString
        "matches":     type.isArray
        "p-value":     type.isInteger
        "selected":    type.isBoolean

    # Call the validation on us.
    initialize: (row, @widget) -> @validate row

    # Validate type (@throws Error).
    validate: (row) => @widget.validateType row, @spec

    # Toggle the `selected` state of this row item.
    toggleSelected: => @set(selected: not @get("selected"))


#### Enrichment Rows Collection
class EnrichmentResults extends Backbone.Collection

    model: EnrichmentRow

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