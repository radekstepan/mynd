    class EnrichmentWidget extends InterMineWidget

        formOptions:
            errorCorrection: "Holm-Bonferroni"
            pValue:          0.05

        errorCorrections: [ "Holm-Bonferroni", "Benjamini Hochberg", "Bonferroni", "None" ]
        pValues: [ 0.05, 0.10, 1.00 ]

        # Spec for a successful and correct JSON response.
        spec:
            response:
                "title":         type.isString
                "description":   type.isString
                "error":         type.isNull
                "list":          type.isString
                "notAnalysed":   type.isInteger
                "requestedAt":   type.isString
                "results":       type.isArray
                "label":         type.isString
                "statusCode":    type.isHTTPSuccess
                "title":         type.isString
                "type":          type.isString
                "wasSuccessful": type.isBoolean
            resultRow:
                "description": type.isString
                "item":        type.isString
                "matches":     type.isArray
                "p-value":     type.isInteger

        # Set the params on us and render.
        # `service`:       http://aragorn.flymine.org:8080/flymine/service/
        # `token`:         token for accessing user's lists
        # `id`:            widgetId
        # `bagName`:       myBag
        # `el`:            #target
        # `widgetOptions`: { "title": true/false, "description": true/false, "matchCb": function() {} }
        constructor: (@service, @token, @id, @bagName, @el, @widgetOptions = {
            "title":       true
            "description": true
            # By default, the select callback will dump the match id into the console.
            matchCb: (id) => console?.log id
        }) ->
            super() # Luke... I am your father!
            @render()

        # Visualize the displayer.
        render: =>
            $.ajax
                url:      "#{@service}list/enrichment"
                dataType: "json"
                data:
                    widget:     @id
                    list:       @bagName
                    correction: @formOptions.errorCorrection
                    maxp:       @formOptions.pValue
                    token:      @token
                
                success: (response) =>
                    # We have response, validate.
                    @validateType response, @spec.response
                    # We have results.
                    if response.wasSuccessful
                        # Render the widget template.
                        $(@el).html @template "enrichment.normal",
                            "title":       if @widgetOptions.title then response.title else ""
                            "description": if @widgetOptions.description then response.description else ""
                            "notAnalysed": response.notAnalysed

                        # Callback for actions.
                        $(@el).find("div.actions a.export").click (e) => @exportClick e

                        # Form options.
                        $(@el).find("div.form").html @template "enrichment.form",
                            "options":          @formOptions
                            "errorCorrections": @errorCorrections
                            "pValues":          @pValues
                        
                        # Extra attributes (DataSets)?
                        if response.extraAttributeLabel?
                            $(@el).find('div.form form').append @template "enrichment.extra",
                                "label":    response.extraAttributeLabel
                                "possible": response.extraAttributePossibleValues
                                "selected": response.extraAttributeSelectedValue

                        # Results?
                        if response.results.length > 0
                            # How tall should the table be? Whole height - header - table head - some extra space
                            height = $(@el).height() - $(@el).find('header').height() - 30 - 18

                            # Render the table.
                            $(@el).find("div.content").html(
                                $ @template "enrichment.table", "label": response.label
                            ).find('div.wrapper').css 'height', "#{height}px"

                            # (De-)Select all.
                            $(@el).find('div.content div.head input.check').click (e) => @selectAllClick e

                            # Table rows.
                            table = $(@el).find("div.content table")
                            for i in [0...response.results.length] then do (i) =>
                                row = response.results[i]
                                # Validate type.
                                @validateType row, @spec.resultRow
                                # Append.
                                table.append tr = $ @template "enrichment.row", "row": row
                                # Events.
                                td = tr.find("td.matches .count").click => @matchesClick td, row["matches"], @widgetOptions.matchCb
                                tr.find("td.check input").click => @checkboxClick i, row

                            # Fix the `div.head` element width.
                            table.find('thead th').each (i, th) =>
                                $(@el).find("div.content div.head div:eq(#{i})").width $(th).width()
                            
                        else
                            # Render no results
                            $(@el).find("div.content").html $ @template "noresults"

                        # Set behaviors.
                        $(@el).find("form select").change @formClick
                
                error: (err) => @error "AJAXTransport", err

            @

        # On form select option change, set the new options and re-render.
        formClick: (e) =>
            @formOptions[$(e.target).attr("name")] = $(e.target[e.target.selectedIndex]).attr("value")
            @render()

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

        # Button toolbar 'View' click.
        viewAction: ->
            console.log 'viewAction triggered thanks to Backbone'

        # Button toolbar 'Export' click.
        exportClick: (e) =>
            # Create a tab delimited string.
            result = []
            for key, value of @selected
                result.push [ value.item, value['p-value'] ].join("\t") + "\t" + [ match.displayed for match in value.matches ].join(',')

            if result.length # Can be empty.
                # Create.
                ex = new Exporter $(e.target), result.join("\n"), "#{@bagName} #{@id}.tsv"
                # Cleanup.
                window.setTimeout (->
                    ex.destroy()
                ), 5000