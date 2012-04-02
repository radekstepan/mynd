### View maintaining Enrichment Widget.###

class EnrichmentView extends Backbone.View

    events:
        "click div.actions a.view":      "viewAction"
        "click div.actions a.export":    "exportAction"
        "change div.form select":        "formAction"
        "click div.content input.check": "selectAllAction"

    initialize: (o) ->
        @[k] = v for k, v of o

        # New **Collection**.
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
            # Render the actions toolbar, we have results.
            @renderToolbar()

            @renderTable()
        else
            # Render no results
            $(@el).find("div.content").html $ @template "noresults"

        @

    # Render the actions toolbar based on how many collection model rows are selected.
    renderToolbar: =>
        $(@el).find("div.actions").html(
            $ @template "enrichment.actions", "disabled": @collection.selected().length is 0
        )

    # Render the table of results using Document Fragment to prevent browser reflows.
    renderTable: =>
            # Render the table.
            $(@el).find("div.content").html(
                $ @template "enrichment.table", "label": @response.label
            )

            # Table rows **Models** and a subsequent **Collection**.
            table = $(@el).find("div.content table")
            for i in [0...@response.results.length] then do (i) =>
                # New **Model**.
                row = new EnrichmentRow @response.results[i], @widget
                @collection.add row

            # Render row **Views**.
            @renderTableBody table

            # How tall should the table be? Whole height - header - faux header.
            height = $(@el).height() - $(@el).find('header').height() - $(@el).find('div.content div.head').height()
            $(@el).find("div.content div.wrapper").css 'height', "#{height}px"

            # Determine the width of the faux head element.
            $(@el).find("div.content div.head").css "width", $(@el).find("div.content table").width() + "px"

            # Fix the `div.head` elements width.
            table.find('thead th').each (i, th) =>
                $(@el).find("div.content div.head div:eq(#{i})").width $(th).width()

            # Fix the `table` margin to hide gap after invisible `thead` element.
            table.css 'margin-top': '-' + table.find('thead').height() + 'px'

    # Render `<tbody>` from a @collection (use to achieve single re-flow of row Views).
    renderTableBody: (table) =>
        # Create a Document Fragment for the content that follows.
        fragment = document.createDocumentFragment()

        # Table rows.
        for row in @collection.models
            # Render.
            fragment.appendChild new EnrichmentRowView(
                "model":    row
                "template": @template
                "type":     @response.type
                "matchCb":  @options.matchCb
            ).el

        # Append the fragment to trigger the browser reflow.
        table.find('tbody').html fragment

    # On form select option change, set the new options and re-render.
    formAction: (e) =>
        @widget.formOptions[$(e.target).attr("name")] = $(e.target[e.target.selectedIndex]).attr("value")
        @widget.render()

    # (De-)select all.
    selectAllAction: =>
        @collection.toggleSelected()
        @renderToolbar()
        @renderTableBody $(@el).find("div.content table")

    # Export selected rows into a file.
    exportAction: (e) =>
        # Create a tab delimited string.
        result = []
        for model in @collection.selected()
            result.push [ model.get('description'), model.get('p-value') ].join("\t") + "\t" + ( match.displayed for match in model.get('matches') ).join()

        if result.length # Can be empty.
            # Create.
            try
                ex = new Exporter $(e.target), result.join("\n"), "#{@widget.bagName} #{@widget.id}.tsv"
            catch TypeError
                ex = new PlainExporter result.join("\n")
            # Cleanup.
            window.setTimeout (->
                ex.destroy()
            ), 5000

    # Selecting table rows and clicking on **View** should get us all ids of matches.
    viewAction: =>
        # Get all the matches in selected rows.
        result = []
        for model in @collection.selected()
            Array::push.apply result, ( match.displayed for match in model.get('matches') )

        if result.length # Can be empty.
            pq = @response.pathQuery
            # JSON should have been validated by now.
            pq = JSON.parse pq
            # Add the ONE OF constraint.
            pq.where.push
                "path":   @response.pathConstraint
                "op":     "ONE OF"
                "values": result
            # Callback.
            @options.viewCb pq