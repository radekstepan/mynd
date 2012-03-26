class EnrichmentView extends Backbone.View

    events:
        "click div.actions a.view":      "viewAction"
        "click div.actions a.view":      "viewAction"
        "change div.form select":        "formAction"
        "click div.content input.check": "selectAllAction"

    initialize: (o) ->
        @[k] = v for k, v of o

        # New Collection.
        @collection = new EnrichmentResults
        @collection.bind('change', @renderToolbar) # Re-render toolbar on change.

        @render()

    render: ->
        # Render the widget template.
        $(@el).html @template "enrichment.normal",
            "title":       if @options.title then @response.title else ""
            "description": if @options.description then @response.description else ""
            "notAnalysed": @response.notAnalysed

        # Form options.
        $(@el).find("div.form").html @template "enrichment.form",
            "options":          @form.options
            "pValues":          @form.pValues
            "errorCorrections": @form.errorCorrections

        # Extra attributes (DataSets)?
        if @response.extraAttributeLabel?
            $(@el).find('div.form form').append @template "enrichment.extra",
                "label":    @response.extraAttributeLabel
                "possible": @response.extraAttributePossibleValues
                "selected": @response.extraAttributeSelectedValue

        # Results?
        if @response.results.length > 0
            # How tall should the table be? Whole height - header - table head - some extra space
            height = $(@el).height() - $(@el).find('header').height() - 30 - 18

            # Render the actions toolbar, we have results.
            @renderToolbar()

            # Render the table.
            $(@el).find("div.content").html(
                $ @template "enrichment.table", "label": @response.label
            ).find('div.wrapper').css 'height', "#{height}px"

            # Table rows.
            table = $(@el).find("div.content table")
            for i in [0...@response.results.length] then do (i) =>
                # New Model.
                row = new EnrichmentRow @response.results[i], @widget
                @collection.add row

                # Render.
                table.append $ new EnrichmentRowView(
                    "model":    row
                    "template": @template
                ).el

            # Fix the `div.head` element width.
            table.find('thead th').each (i, th) =>
                $(@el).find("div.content div.head div:eq(#{i})").width $(th).width()
            
        else
            # Render no results
            $(@el).find("div.content").html $ @template "noresults"

        @

    # Render the actions toolbar based on how many collection model rows are selected.
    renderToolbar: =>
        $(@el).find("div.actions").html(
            $ @template "enrichment.actions", "disabled": @collection.selected().length is 0
        )

    # On form select option change, set the new options and re-render.
    formAction: (e) =>
        @widget.formOptions[$(e.target).attr("name")] = $(e.target[e.target.selectedIndex]).attr("value")
        @widget.render()

    # (De-)select all.
    selectAllAction: => @collection.toggleSelected()


    # ------------------------------------------------


    viewAction: -> console.log "viewAction!"

    exportAction: ->
        console.log "exportAction!"

        # Create a tab delimited string.
        result = []
        for key, value of @selected
            result.push [ value.item, value['p-value'] ].join("\t") + "\t" + ( match.displayed for match in value.matches ).join()

        if result.length # Can be empty.
            # Create.
            ex = new Exporter $(e.target), result.join("\n"), "#{@bagName} #{@id}.tsv"
            # Cleanup.
            window.setTimeout (->
                ex.destroy()
            ), 5000

    # Append to or remove from a list of selected rows.
    checkboxClick: (key, row) =>
        if not @selected? then @selected = {}
        if @selected[key]? then delete @selected[key] else @selected[key] = row

        # Update the action buttons.
        for key, value of @selected
            $(@el).find('div.actions a.btn.disabled').removeClass 'disabled'
            return
        $(@el).find('div.actions a.btn').addClass 'disabled'

    # (De-)Select all items in a table
    selectAllClick: (e) =>
        if not @selected? then @selected = {}
        
        # Select all.
        if $(e.target).is(':checked')
            $(@el).find('div.content table tbody tr').each (i, row) =>
                $(row).find('td.check input:not(:checked)').attr 'checked', true
                @selected[i] = row
            $(@el).find('div.actions a.btn').removeClass 'disabled'
        # Deselect all.
        else
            @selected = {}
            $(@el).find('div.content table tbody tr td.check input:checked').each (i, input) -> $(input).attr 'checked', false
            $(@el).find('div.actions a.btn').addClass 'disabled'

    # Show matches.
    matchesClick: (target, matches, matchCb) =>
        target.after modal = $ @template "enrichment.matches", "matches": matches
        modal.find("a.close").click -> modal.remove()
        # Individual match click behavior.
        modal.find("div.popover-content a").click (e) ->
            matchCb $(@).text()
            e.preventDefault()