### View maintaining Table Widget.###

class TableView extends Backbone.View

    initialize: (o) ->
        @[k] = v for k, v of o

        # New **Collection**.
        @collection = new TableResults()

        @render()

    render: ->
        # Render the widget template.
        $(@el).html @template "table.normal",
            "title":       if @options.title then @response.title else ""
            "description": if @options.description then @response.description else ""
            "notAnalysed": @response.notAnalysed

        # Results?
        if @response.results.length > 0
            # Render the table, we have results.
            @renderTable()
        else
            # Render no results
            $(@el).find("div.content").html $ @template "noresults"

        @

    # Render the table of results using Document Fragment to prevent browser reflows.
    renderTable: =>
        # Render the table.
        $(@el).find("div.content").html(
            $ @template "table.table", "columns": @response.columns.split(',')
        )

        # Table rows **Models** and a subsequent **Collection**.
        table = $(@el).find("div.content table")
        for i in [0...@response.results.length] then do (i) =>            
            # New **Model**.
            row = new TableRow @response.results[i], @widget
            @collection.add row

        # Render row **Views**.
        @renderTableBody table

        # How tall should the table be? Whole height - header - faux header.
        console.log "whole height", $(@el).height()
        console.log "header height", $(@el).find('header').height()
        console.log "content head height", $(@el).find('div.content div.head').height()
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
            fragment.appendChild new TableRowView(
                "model":     row
                "template":  @template
                "response":  @response
            ).el

        # Append the fragment to trigger the browser reflow.
        table.find('tbody').html fragment